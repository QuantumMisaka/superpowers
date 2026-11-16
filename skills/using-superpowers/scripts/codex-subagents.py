#!/usr/bin/env python3
"""Install the bundled role catalog without changing the host's model or services.

Requires Python 3.11+. No personal checkout, Codex executable, or network needed.
Only this installer's marked registrations and content-addressed catalog are owned.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile
import tomllib


BEGIN = "# BEGIN superpowers-subagents v1 "
END = "# END superpowers-subagents\n"
ROUTE_KEYS = {"model", "model_provider", "model_reasoning_effort"}
ROLE_ID = re.compile(r"[a-z][a-z0-9]*(?:-[a-z0-9]+)*\Z")
HEADER = re.compile(r"# BEGIN superpowers-subagents v1 (gpt|deepseek) ([a-f0-9]{64})\n")


class InstallError(Exception):
    pass


def require(condition, message):
    if not condition:
        raise InstallError(message)


def parse_toml(text, source):
    try:
        return tomllib.loads(text)
    except tomllib.TOMLDecodeError as exc:
        raise InstallError(f"Invalid TOML in {source}: {exc}") from exc


def load_toml(path):
    return parse_toml(path.read_text(encoding="utf-8"), path)


def canonical(value):
    return (json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n").encode("utf-8")


def digest(value):
    return hashlib.sha256(canonical(value)).hexdigest()


def quote(value):
    # JSON string escapes are valid TOML basic-string escapes.
    return json.dumps(value, ensure_ascii=False)


def validate_route(route, label, partial=False):
    require(isinstance(route, dict), f"{label} must be a table")
    require(set(route) <= ROUTE_KEYS, f"Unknown routing field in {label}: {set(route) - ROUTE_KEYS}")
    if not partial:
        require(set(route) == ROUTE_KEYS, f"Missing routing field in {label}")
    for key, value in route.items():
        require(isinstance(value, str) and value.strip(), f"{label}.{key} must be a nonempty string")


def validate_overrides(data, roles):
    require(isinstance(data, dict) and set(data) <= {"defaults", "roles"},
            "Overrides accept only [defaults] and [roles.<role-id>] tables")
    validate_route(data.get("defaults", {}), "overrides.defaults", partial=True)
    local_roles = data.get("roles", {})
    require(isinstance(local_roles, dict), "overrides.roles must be a table")
    require(set(local_roles) <= set(roles), f"Unknown override roles: {set(local_roles) - set(roles)}")
    for role_id, route in local_roles.items():
        validate_route(route, f"overrides.roles.{role_id}", partial=True)
    return data


def sources(skill, family):
    metadata = load_toml(skill / "assets/subagents/roles.toml")
    preset = load_toml(skill / f"assets/subagents/presets/{family}.toml")
    require(metadata.get("schema_version") == 1 and preset.get("schema_version") == 1,
            "Unsupported role/preset schema_version")
    require(preset.get("family") == family, "Preset family does not match selection")
    prefix = {"gpt": "gpt", "deepseek": "ds"}[family]
    require(preset.get("name_prefix") == prefix, "Unexpected preset name_prefix")
    roles = metadata.get("roles")
    require(isinstance(roles, dict) and roles, "Role metadata must contain roles")
    require(isinstance(preset.get("roles"), dict) and set(roles) == set(preset["roles"]),
            "Preset and metadata role IDs do not match")
    bodies = {}
    for role_id, role in roles.items():
        require(ROLE_ID.fullmatch(role_id), f"Invalid role ID: {role_id}")
        require(isinstance(role, dict) and set(role) == {"description", "sandbox_mode"},
                f"Invalid metadata for {role_id}")
        require(isinstance(role["description"], str) and role["description"].strip(),
                f"Missing role description: {role_id}")
        require(isinstance(role["sandbox_mode"], str)
                and role["sandbox_mode"] in {"read-only", "workspace-write"},
                f"Unsupported role sandbox: {role_id}")
        validate_route(preset["roles"][role_id], f"preset.roles.{role_id}")
        path = skill / f"references/roles/{role_id}.md"
        require(not path.is_symlink(), f"Role source must be self-contained: {path}")
        bodies[role_id] = path.read_text(encoding="utf-8")
        require(bodies[role_id].strip(), f"Empty role body: {role_id}")
    return roles, preset, bodies


def payload_for(family, roles, preset, bodies, overrides, config):
    files, descriptions = {}, {}
    providers = config.get("model_providers", {})
    require(isinstance(providers, dict), "model_providers must be a table")
    for role_id, role in roles.items():
        route = dict(preset["roles"][role_id])
        route.update(overrides.get("defaults", {}))
        route.update(overrides.get("roles", {}).get(role_id, {}))
        provider = route["model_provider"]
        require(provider == "openai" or isinstance(providers.get(provider), dict),
                f"Provider {provider!r} for {role_id} is missing from target config's model_providers; "
                "configure it or supply --overrides")
        name = preset["name_prefix"] + "_" + role_id.replace("-", "_")
        descriptions[name] = role["description"]
        content = "# Generated by Superpowers codex-subagents.py; use --overrides for local routing.\n"
        content += "".join(f"{key} = {quote(route[key])}\n" for key in sorted(route))
        content += f"sandbox_mode = {quote(role['sandbox_mode'])}\n"
        content += f"developer_instructions = {quote(bodies[role_id])}\n"
        parse_toml(content, name)
        files[name + ".toml"] = content
    return {"family": family, "overrides": overrides, "files": files, "descriptions": descriptions}


def registrations(payload, version, config_path):
    return {name: {"description": description,
                   "config_file": os.path.relpath(version / (name + ".toml"), config_path.parent)}
            for name, description in payload["descriptions"].items()}


def block_for(payload, version, config_path):
    block = BEGIN + payload["family"] + " " + version.name + "\n"
    for name, agent in sorted(registrations(payload, version, config_path).items()):
        block += f"\n[agents.{name}]\n"
        block += f"description = {quote(agent['description'])}\nconfig_file = {quote(agent['config_file'])}\n"
    return block + END


def validate_payload(payload):
    require(isinstance(payload, dict) and set(payload) == {"family", "overrides", "files", "descriptions"},
            "Invalid managed catalog manifest")
    require(isinstance(payload["family"], str) and payload["family"] in {"gpt", "deepseek"},
            "Invalid managed catalog family")
    prefix = {"gpt": "gpt_", "deepseek": "ds_"}[payload["family"]]
    descriptions, files = payload["descriptions"], payload["files"]
    require(isinstance(descriptions, dict) and descriptions and isinstance(files, dict),
            "Invalid managed catalog entries")
    require(set(files) == {name + ".toml" for name in descriptions}, "Invalid managed catalog files")
    for name, description in descriptions.items():
        require(re.fullmatch(re.escape(prefix) + r"[a-z][a-z0-9_]*", name)
                and isinstance(description, str) and isinstance(files[name + ".toml"], str),
                "Invalid managed catalog role")


def verify_version(version, payload):
    require(not version.is_symlink(), f"Managed catalog directory modified: {version}")
    require(canonical(payload) == (version / "manifest.json").read_bytes(),
            f"Managed catalog manifest modified: {version}")
    for filename, content in payload["files"].items():
        path = version / filename
        require(not path.is_symlink() and path.read_bytes() == content.encode("utf-8"),
                f"Managed role file modified: {path}; move local model choices to --overrides")


def existing_install(text, config, catalog, config_path):
    lines = text.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if line.startswith(BEGIN)]
    ends = [i for i, line in enumerate(lines) if line.rstrip("\r\n") == END.rstrip("\n")]
    require(len(starts) == len(ends) and len(starts) <= 1,
            "Managed registration block modified or duplicated")
    if not starts:
        return None, text
    start, end = starts[0], ends[0]
    match = HEADER.fullmatch(lines[start])
    require(match is not None and end > start, "Managed registration header modified")
    family, version_hash = match.groups()
    version = catalog / version_hash
    try:
        payload = json.loads((version / "manifest.json").read_bytes())
    except (OSError, ValueError) as exc:
        raise InstallError(f"Managed catalog manifest missing or modified: {version}") from exc
    validate_payload(payload)
    require(digest(payload) == version_hash and payload["family"] == family,
            "Managed catalog manifest modified")
    verify_version(version, payload)
    block = "".join(lines[start:end + 1])
    require(block == block_for(payload, version, config_path), "Managed registration block modified")
    actual_agents = config.get("agents", {})
    expected_agents = registrations(payload, version, config_path)
    require(isinstance(actual_agents, dict)
            and all(actual_agents.get(name) == agent for name, agent in expected_agents.items()),
            "Managed registration semantics modified")
    base_text = "".join(lines[:start] + lines[end + 1:])
    base_config = parse_toml(base_text, config_path)
    # Removing our block must remove exactly our agent entries, never host settings.
    expected_config = dict(config)
    remaining_agents = {k: v for k, v in actual_agents.items() if k not in expected_agents}
    if remaining_agents or "agents" in base_config:
        expected_config["agents"] = remaining_agents
    else:
        expected_config.pop("agents", None)
    require(base_config == expected_config, "Managed registration block overlaps unrelated configuration")
    return payload, base_text


def feature_notice(config):
    features = config.get("features", {})
    agents = config.get("agents", {})
    restart = " Restart Codex / start a new session to load role changes."
    if features.get("multi_agent_v2") is True:
        return "features.multi_agent_v2 is enabled; it takes precedence over agents.enabled=false." + restart
    if agents.get("enabled") is False:
        return ("agents.enabled=false disables multi-agent because features.multi_agent_v2 is not enabled; "
                "no feature or agent settings were changed." + restart)
    if features.get("multi_agent") is True:
        return ("features.multi_agent=true selects the deprecated legacy/V1 fallback, not multi_agent_v2; "
                "check your installed Codex version's supported feature settings." + restart)
    return ("features.multi_agent_v2 is absent or disabled; no feature or agent settings were changed. "
            "Check your installed Codex version's supported multi-agent settings if required." + restart)


def effective_settings(home, config_path, target):
    """Codex's alternate profile files inherit provider/feature tables from home.

    Read only the base settings relevant to this installer. The explicit target
    still owns every registration, and this does not select a startup profile.
    """
    base_path = (home / "config.toml").resolve()
    base = load_toml(base_path) if base_path != config_path and base_path.exists() else {}
    effective = {}
    for key in ("model_providers", "features"):
        inherited, local = base.get(key, {}), target.get(key, {})
        require(isinstance(inherited, dict) and isinstance(local, dict), f"{key} must be a table")
        effective[key] = {**inherited, **local}
    inherited_agents, local_agents = base.get("agents", {}), target.get("agents", {})
    require(isinstance(inherited_agents, dict) and isinstance(local_agents, dict), "agents must be a table")
    effective["agents"] = {key: value for key, value in
                           {**inherited_agents, **local_agents}.items() if key == "enabled"}
    return effective


def write_version(catalog, payload):
    version = catalog / digest(payload)
    if version.exists():
        verify_version(version, payload)
        return
    catalog.mkdir(parents=True, exist_ok=True)
    # Staging and immutable versions live outside Codex's active agents directory.
    staging = Path(tempfile.mkdtemp(prefix=".preparing-", dir=catalog))
    for filename, content in payload["files"].items():
        (staging / filename).write_bytes(content.encode("utf-8"))
    (staging / "manifest.json").write_bytes(canonical(payload))
    os.rename(staging, version)


def replace_config(config_path, previous, replacement):
    # Recheck immediately before committing; abort if another process changed it.
    current = config_path.read_bytes() if config_path.exists() else None
    require(current == previous, "Target config changed concurrently; rerun preview")
    config_path.parent.mkdir(parents=True, exist_ok=True)
    if previous is not None:
        backup = config_path.with_name(config_path.name + ".superpowers-backup-" + hashlib.sha256(previous).hexdigest()[:16])
        if backup.exists():
            require(backup.read_bytes() == previous, f"Backup conflict: {backup}")
        else:
            descriptor = os.open(backup, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(descriptor, "wb") as stream:
                stream.write(previous)
    descriptor, temporary = tempfile.mkstemp(prefix=".superpowers-config-", dir=config_path.parent)
    with os.fdopen(descriptor, "wb") as stream:
        stream.write(replacement)
        stream.flush()
        os.fsync(stream.fileno())
    if config_path.exists():
        os.chmod(temporary, stat.S_IMODE(config_path.stat().st_mode))
    require((config_path.read_bytes() if config_path.exists() else None) == previous,
            "Target config changed concurrently; prepared config was not activated")
    os.replace(temporary, config_path)


def run(args):
    skill = Path(__file__).resolve().parent.parent
    home = args.codex_home.expanduser().resolve()
    config_path = (args.config.expanduser() if args.config else home / "config.toml").resolve()
    config_id = hashlib.sha256(str(config_path).encode()).hexdigest()[:16]
    catalog = home / "superpowers-subagents" / config_id / "versions"
    previous = config_path.read_bytes() if config_path.exists() else None
    text = previous.decode("utf-8") if previous is not None else ""
    config = parse_toml(text, config_path)
    installed, base_text = existing_install(text, config, catalog, config_path)
    require(installed is None or installed["family"] == args.family,
            "This target config already manages another family; use a separate --config for the other family")
    roles, preset, bodies = sources(skill, args.family)
    overrides = (load_toml(args.overrides.expanduser()) if args.overrides
                 else installed["overrides"] if installed else {})
    validate_overrides(overrides, roles)
    base_config = parse_toml(base_text, config_path)
    settings = effective_settings(home, config_path, base_config)
    payload = payload_for(args.family, roles, preset, bodies, overrides, settings)
    agents = base_config.get("agents", {})
    require(isinstance(agents, dict), "agents must be a table")
    conflicts = set(agents) & set(payload["descriptions"])
    require(not conflicts, f"Same-name unmanaged agents would be overwritten: {', '.join(sorted(conflicts))}")
    version = catalog / digest(payload)
    new_block = block_for(payload, version, config_path)
    # Preserve every unrelated byte, including comments, order and line endings.
    candidate = base_text + ("\n" if base_text and not base_text.endswith("\n") else "") + new_block
    candidate_config = parse_toml(candidate, "proposed target config")
    require(all(candidate_config.get("agents", {}).get(name) == agent
                for name, agent in registrations(payload, version, config_path).items()),
            "Proposed config does not register the expected agents")
    replacement = candidate.encode("utf-8")
    changed = replacement != previous
    if args.action == "check":
        require(installed is not None, "Selected family is not installed; run preview then apply")
        require(not changed, "Installed roles or routes are stale; run preview then apply")
        print(f"Static configuration valid: {len(roles)} {args.family} roles in {config_path}")
    else:
        print(f"{args.action}: {config_path}\nFamily: {args.family}; {len(roles)} roles; "
              + ("changes required" if changed else "already current"))
        print("Roles: " + ", ".join(sorted(payload["descriptions"])))
        print(f"Catalog: {version}")
        if args.action == "preview":
            for name in sorted(payload["descriptions"]):
                route = parse_toml(payload["files"][name + ".toml"], name)
                print(f"  {name}: {route['model_provider']} / {route['model']} / "
                      f"effort={route['model_reasoning_effort']} / {route['sandbox_mode']}")
        if args.action == "apply" and changed:
            # All parse/provider/conflict checks have completed before the first write.
            write_version(catalog, payload)
            replace_config(config_path, previous, replacement)
            print("Applied; previous configuration backed up when present.")
    print(feature_notice(settings))
    print("Effective child sandbox: not verified. Codex 0.169.0 V2 was observed inheriting "
          "the parent sandbox despite a role's read-only setting; see references/subagent-install.md.")
    print("Real model invocation: not verified. This command performs static validation only.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("preview", "apply", "check"))
    parser.add_argument("--family", choices=("gpt", "deepseek"), required=True)
    parser.add_argument("--codex-home", type=Path, default=Path("~/.codex"))
    parser.add_argument("--config", type=Path, help="Explicit target configuration; defaults to CODEX_HOME/config.toml")
    parser.add_argument("--overrides", type=Path, help="Local routing TOML; copied into managed catalog for future updates")
    args = parser.parse_args()
    try:
        run(args)
    except (InstallError, OSError, UnicodeError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

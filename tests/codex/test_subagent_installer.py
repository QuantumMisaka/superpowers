"""Public CLI acceptance tests; all writes stay in a temporary collaborator home."""
import argparse
import contextlib
import importlib.util
import io
import shutil
import subprocess
import sys
import tempfile
import tomllib
import unittest
from unittest.mock import patch
from pathlib import Path


SKILL = Path(__file__).resolve().parents[2] / "skills/using-superpowers"


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.skill = self.root / "isolated-skill"
        shutil.copytree(SKILL, self.skill)
        self.script = self.skill / "scripts/codex-subagents.py"
        self.home = self.root / "codex"
        self.config = self.home / "config.toml"

    def run_cli(self, action, family="gpt", *args, ok=True):
        result = subprocess.run(
            [sys.executable, str(self.script), action, "--family", family,
             "--codex-home", str(self.home), *map(str, args)],
            capture_output=True, text=True, cwd=self.root,
        )
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def write_config(self, text):
        self.config.parent.mkdir(parents=True, exist_ok=True)
        self.config.write_text(text)

    def snapshot(self):
        return {str(p.relative_to(self.root)): p.read_bytes()
                for p in self.root.rglob("*") if p.is_file()}

    def test_preview_and_check_never_write(self):
        before = self.snapshot()
        self.run_cli("preview")
        result = self.run_cli("check", ok=False)
        self.assertIn("not installed", result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_both_families_generate_and_register(self):
        for family, prefix, provider in (("gpt", "gpt", "openai"),
                                         ("deepseek", "ds", "deepseek")):
            with self.subTest(family=family):
                self.home = self.root / family
                self.config = self.home / "config.toml"
                self.write_config('[model_providers.deepseek]\nname = "DeepSeek"\nbase_url = "https://example.test"\n')
                self.run_cli("apply", family)
                config = tomllib.loads(self.config.read_text())
                self.assertEqual(len(config["agents"]), 13)
                agent = config["agents"][prefix + "_standard_worker"]
                path = self.config.parent / agent["config_file"]
                self.assertNotIn("agents", Path(agent["config_file"]).parts)
                rendered = tomllib.loads(path.read_text())
                self.assertEqual(rendered["model_provider"], provider)
                self.assertEqual(rendered["sandbox_mode"], "workspace-write")
                self.assertEqual(rendered["developer_instructions"],
                                 (self.skill / "references/roles/standard-worker.md").read_text())
                result = self.run_cli("check", family)
                self.assertIn("static", result.stdout.lower())
                self.assertIn("not verified", result.stdout.lower())

    def test_preserves_unrelated_bytes_and_idempotent(self):
        original = ('# collaborator settings\nmodel = "own-model"\r\n'
                    'model_provider = "openai"\n[features]\nmulti_agent = true\n'
                    '[mcp_servers.example]\ncommand = "example"\n'
                    '[agents.local]\ndescription = "mine"\nconfig_file = "local.toml"\n')
        self.write_config(original)
        before = self.config.read_bytes()
        self.run_cli("apply")
        self.assertTrue(self.config.read_bytes().startswith(before))
        self.assertTrue(list(self.home.glob("config.toml.superpowers-backup-*")))
        installed = self.snapshot()
        self.run_cli("apply")
        self.assertEqual(installed, self.snapshot())

    def test_unmanaged_conflict_refuses_without_writes(self):
        self.write_config('[agents.gpt_standard_worker]\ndescription = "mine"\n')
        before = self.snapshot()
        result = self.run_cli("apply", ok=False)
        self.assertIn("unmanaged", result.stderr)
        self.assertEqual(before, self.snapshot())

    def test_persists_copied_overrides(self):
        self.write_config('[model_providers.local]\nname = "local"\nbase_url = "https://example.test"\n')
        override = self.root / "override.toml"
        override.write_text('[defaults]\nmodel_provider = "local"\nmodel = "local-model"\n'
                            '[roles.monitor]\nmodel_reasoning_effort = "low"\n')
        self.run_cli("apply", "gpt", "--overrides", override)
        override.write_text("invalid input")
        self.run_cli("apply")
        self.run_cli("check")
        config = tomllib.loads(self.config.read_text())
        route = self.config.parent / config["agents"]["gpt_monitor"]["config_file"]
        data = tomllib.loads(route.read_text())
        self.assertEqual(data["model"], "local-model")
        self.assertEqual(data["model_provider"], "local")
        self.assertEqual(data["model_reasoning_effort"], "low")

    def test_missing_provider_and_malformed_input_do_not_write(self):
        before = self.snapshot()
        self.run_cli("apply", "deepseek", ok=False)
        self.assertEqual(before, self.snapshot())
        self.write_config("bad = [\n")
        before = self.snapshot()
        self.run_cli("apply", ok=False)
        self.assertEqual(before, self.snapshot())

    def test_invalid_override_keeps_installed_config_usable(self):
        self.run_cli("apply")
        override = self.root / "override.toml"
        override.write_text('[roles.unknown]\nmodel = "bad"\n')
        before = self.snapshot()
        self.run_cli("apply", "gpt", "--overrides", override, ok=False)
        self.assertEqual(before, self.snapshot())
        self.run_cli("check")

    def test_managed_file_or_registration_edit_is_diagnosed(self):
        self.run_cli("apply")
        original = self.config.read_text()
        route = self.config.parent / tomllib.loads(original)["agents"]["gpt_monitor"]["config_file"]
        body = route.read_text()
        route.write_text(body + "# local edit\n")
        before = self.snapshot()
        self.assertIn("modified", self.run_cli("apply", ok=False).stderr)
        self.assertEqual(before, self.snapshot())
        route.write_text(body)
        self.config.write_text(original.replace('description = ', 'description= ', 1))
        self.assertIn("modified", self.run_cli("apply", ok=False).stderr)

    def test_cannot_silently_replace_other_family(self):
        self.write_config('[model_providers.deepseek]\nname = "DeepSeek"\n')
        self.run_cli("apply")
        before = self.snapshot()
        self.assertIn("family", self.run_cli("apply", "deepseek", ok=False).stderr)
        self.assertEqual(before, self.snapshot())

    def test_alternate_config_relative_paths_and_feature_notice(self):
        alternate = self.root / "alternate" / "chosen.toml"
        result = self.run_cli("apply", "gpt", "--config", alternate)
        self.assertIn("multi_agent", result.stdout)
        self.assertIn("restart", result.stdout.lower())
        config = tomllib.loads(alternate.read_text())
        self.assertNotIn("features", config)
        for agent in config["agents"].values():
            self.assertTrue((alternate.parent / agent["config_file"]).is_file())
        self.assertFalse(self.config.exists())
        self.run_cli("check", "gpt", "--config", alternate)

    def test_update_role_keeps_previous_version_and_config_backup(self):
        self.run_cli("apply")
        previous = self.config.read_text()
        old_route = self.config.parent / tomllib.loads(previous)["agents"]["gpt_monitor"]["config_file"]
        source = self.skill / "references/roles/monitor.md"
        source.write_text(source.read_text() + "\nUpdated role.\n")
        self.run_cli("check", ok=False)
        self.run_cli("apply")
        self.assertTrue(old_route.exists())
        self.assertNotEqual(previous, self.config.read_text())
        self.run_cli("check")

    def test_failed_config_activation_keeps_old_references_usable(self):
        self.run_cli("apply")
        previous = self.config.read_bytes()
        source = self.skill / "references/roles/monitor.md"
        source.write_text(source.read_text() + "\nNew instructions.\n")
        spec = importlib.util.spec_from_file_location("installer", self.script)
        installer = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(installer)
        args = argparse.Namespace(action="apply", family="gpt", codex_home=self.home,
                                  config=None, overrides=None)
        with contextlib.redirect_stdout(io.StringIO()), \
                patch.object(installer.os, "replace", side_effect=OSError("simulated disk failure")):
            with self.assertRaisesRegex(OSError, "simulated disk failure"):
                installer.run(args)
        self.assertEqual(previous, self.config.read_bytes())
        for agent in tomllib.loads(previous.decode())["agents"].values():
            self.assertTrue((self.config.parent / agent["config_file"]).is_file())
        self.run_cli("apply")
        self.run_cli("check")

    def test_unowned_catalog_collision_refuses_without_config_write(self):
        result = self.run_cli("preview")
        version = Path(next(line.removeprefix("Catalog: ") for line in result.stdout.splitlines()
                            if line.startswith("Catalog: ")))
        version.mkdir(parents=True)
        sentinel = version / "manifest.json"
        sentinel.write_text("collaborator file\n")
        before = self.snapshot()
        self.run_cli("apply", ok=False)
        self.assertEqual(before, self.snapshot())

    def test_malformed_source_does_not_change_installed_config(self):
        self.run_cli("apply")
        source = self.skill / "assets/subagents/roles.toml"
        source.write_text(source.read_text().replace('sandbox_mode = "read-only"',
                                                    'sandbox_mode = ["read-only"]', 1))
        before = self.snapshot()
        result = self.run_cli("apply", ok=False)
        self.assertNotIn("Traceback", result.stderr)
        self.assertEqual(before, self.snapshot())

    def test_alternate_profile_inherits_providers_and_features_without_modifying_base(self):
        self.write_config('[features]\nmulti_agent = true\n'
                          '[model_providers.deepseek]\nname = "DeepSeek"\n')
        original = self.config.read_bytes()
        alternate = self.home / "profiles" / "deepseek.toml"
        preview = self.run_cli("preview", "deepseek", "--config", alternate)
        self.assertIn("ds_monitor: deepseek / deepseek-flash / effort=low / read-only", preview.stdout)
        self.assertFalse(alternate.exists())
        self.run_cli("apply", "deepseek", "--config", alternate)
        result = self.run_cli("check", "deepseek", "--config", alternate)
        self.assertIn("deprecated legacy/V1 fallback", result.stdout)
        self.assertEqual(self.config.read_bytes(), original)

    def test_malformed_base_profile_prevents_alternate_install(self):
        self.write_config("broken = [\n")
        before = self.snapshot()
        self.run_cli("apply", "gpt", "--config", self.home / "profiles/gpt.toml", ok=False)
        self.assertEqual(before, self.snapshot())

    def test_feature_notice_distinguishes_v2_disabled_and_legacy_routes(self):
        cases = (
            ('[features]\nmulti_agent_v2 = true\n[agents]\nenabled = false\n',
             'multi_agent_v2 is enabled; it takes precedence'),
            ('[features]\nmulti_agent = true\n[agents]\nenabled = false\n',
             'agents.enabled=false disables multi-agent'),
            ('[features]\nmulti_agent = true\n', 'deprecated legacy/V1 fallback'),
            ('[features]\nmulti_agent_v2 = false\n', 'multi_agent_v2 is absent or disabled'),
        )
        for settings, expected in cases:
            with self.subTest(expected=expected):
                self.write_config(settings)
                before = self.snapshot()
                result = self.run_cli("preview")
                self.assertIn(expected, result.stdout)
                self.assertEqual(before, self.snapshot())

    def test_alternate_profile_inherits_agent_disabled_setting(self):
        self.write_config('[features]\nmulti_agent = true\n[agents]\nenabled = false\n')
        alternate = self.home / "profiles/gpt.toml"
        result = self.run_cli("preview", "gpt", "--config", alternate)
        self.assertIn("agents.enabled=false disables multi-agent", result.stdout)
        alternate.parent.mkdir(parents=True)
        alternate.write_text('[features]\nmulti_agent_v2 = true\n')
        result = self.run_cli("preview", "gpt", "--config", alternate)
        self.assertIn("multi_agent_v2 is enabled; it takes precedence", result.stdout)


if __name__ == "__main__":
    unittest.main()

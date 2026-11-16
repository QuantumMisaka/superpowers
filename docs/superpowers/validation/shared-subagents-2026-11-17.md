# Shared Codex roles — 2026-11-17 validation

The QuantumMisaka fork now carries 13 role definitions, shared metadata, GPT and DeepSeek routing presets, and a standalone Codex installer inside `skills/using-superpowers/`. The personal configuration repository consumes this source through generated compatibility snapshots.

## Configuration and consumer checks

- Installer suite: 18 tests passed. Covers both families, standalone copied skill, preview/check without writes, idempotence, unrelated settings, conflicting unmanaged roles, local override persistence, provider inheritance, feature notices, modified managed files, malformed inputs, and failed activation preserving the previous configuration and references.
- Personal integration: 56 tests and 12 subtests passed across shared-source migration, agent matrix, dsh catalog/runtime and OpenCode GLM/Gemini adapters. All 104 effective role configurations and 13 role bodies match the pre-migration local baseline. Generator check: 104 role files and eight registration blocks match.
- The personal runtime source was deployed in explicit standalone snapshot mode. Runtime generator and matrix checks passed. Existing personal models and role bodies were preserved.
- Skill structure and relative-link checks passed. Package verification is recorded below after building the committed source.

## Actual Codex calls

Codex CLI 0.169.0 loaded a new home configured by a copied standalone skill. Its tool description advertised the installed roles. A bounded task spawned `gpt_context_analyst` on GPT-6.1 Sol/medium and `gpt_routine_worker` on GPT-6 Luna/high. Both child sessions completed; the analyst returned the fixture sum, and the worker implemented addition. The outer process separately verified the implementation.

A second home with no named roles spawned a generic child after the parent read the copied context-analyst definition. The child ran on the configured generic GPT-6 Luna/medium route and returned the expected fixture answer. The runtime encrypts the spawn brief in its raw trace, so this observation does not independently verify every byte of the delivered instructions.

The native runs also discovered the host's existing skills. They verify native registration, delegation and model/effort selection; package self-containment is established separately by the isolated installer tests. DeepSeek installation was tested with controlled provider configuration; no DeepSeek account connectivity claim is made.

## Observed permission limitation

The native context analyst was configured with `sandbox_mode = "read-only"`, but its actual turn context used the parent's `workspace-write`. A separate neutral probe, with a read-only role configuration and an explicit disposable file-write test, successfully created the file and recorded the inherited writable sandbox.

Thus Codex 0.169.0 V2 role configuration did not enforce sandbox narrowing in this test. The installer and installation guide report this limitation. Read-only role prose remains a responsibility contract; tasks requiring enforced read-only access should run from a read-only parent and have their effective permissions checked. The static installer does not claim to validate runtime sandbox enforcement.

An independent final reviewer found no Important/Critical installer or personal integration defects, and identified this permission validation gap. The additional probe confirmed the boundary and the documentation/output were corrected before publication.

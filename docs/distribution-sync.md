# Distribution Sync

Use this guide when refreshing public Agent Kit distribution artifacts from the
source repo. Normal refreshes are generated PRs from the Agent Kit publish
workflow. Use these commands for local validation or manual fallback.

## Repo Boundary

| Repo | Owns |
| --- | --- |
| [🐙 The Endor Labs Agent Kit](https://github.com/endorlabs/endor-labs-agent-kit/tree/main) | Source recipes, compiler and publication code, guardrails, tests, provenance, generated catalog, and source documentation. |
| [🐙 Endor Labs AI Plugins](https://github.com/endorlabs/ai-plugins/tree/main) | Public host metadata, Cursor package metadata, root Cursor agents, support skills, advisory hooks, Cursor SDK automation package, release-facing README, and checked-in distribution artifacts. |

Normal package sync should make `ai-plugins/plugins/` byte-for-byte identical to
`endor-labs-agent-kit/plugins/`. Cursor package sync should make
`ai-plugins/.cursor-plugin/`, generated root workflow `agents/`, generated root
workflow `skills/`, generated root advisory `hooks/`, and `assets/logo.png`
match the source repo. Cursor SDK sync should make `ai-plugins/cursor-sdk/`
match the source repo. The root `CHANGELOG.md` is also synced so release notes
travel with generated distribution PRs.

## Automated Publication

New agents, skills, hooks, action contracts, and generated package behavior are
authored in Agent Kit. After an Agent Kit maintainer merges to `main`, the
source workflow validates, regenerates, verifies provenance, syncs generated
distribution surfaces, and opens or updates an `ai-plugins` PR.

That workflow does not automatically increment package versions. The source
`pyproject.toml` version changes only when maintainers intentionally bump it for
a release.

Generated PRs should include:

- source Agent Kit commit
- `CHANGELOG.md`
- `provenance/agent-kit-catalog.intoto.json`
- `provenance/manifest.sha256`
- validation evidence in the PR body

Direct PRs that change generated behavior here should be redirected to Agent
Kit source first.

## Regenerate Source Artifacts

Run from your local checkout of
[🐙 The Endor Labs Agent Kit](https://github.com/endorlabs/endor-labs-agent-kit/tree/main):

```bash
PYTHONPATH=src python3 -m endor_agent_kit.cli publish source/agents/*/recipe.yaml --dest . --prune --include-plugins
PYTHONPATH=src python3 -m pytest -q
PYTHONPATH=src python3 -m endor_agent_kit.cli check-guardrails --catalog-root .
PYTHONPATH=src python3 -m endor_agent_kit.cli verify-provenance --catalog-root .
git diff --check
```

If the `endor-agent-kit` console script is installed and points at the same
checkout, using it is equivalent.

## Sync The Mirror

Run from your local checkout of
[🐙 Endor Labs AI Plugins](https://github.com/endorlabs/ai-plugins/tree/main)
after source regeneration and validation are clean:

```bash
AGENT_KIT_REPO="/path/to/endor-labs-agent-kit"

python3 "$AGENT_KIT_REPO/scripts/sync_ai_plugins_distribution.py" \
  --source "$AGENT_KIT_REPO" \
  --target .
```

Do not copy the Agent Kit root README into this repo. The mirror root README is
distribution-specific and should explain public install paths, release checks,
and the source boundary.

Do not copy the Agent Kit root `skills/create-endor-labs-agent/` helper into
`ai-plugins`. Do not treat root `GEMINI.md` as a Cursor package file or as an
installable Gemini extension manifest; Gemini CLI uses
`plugins/gemini/endor-labs-agent-kit/`. The sync script removes stale root
`gemini-extension.json` files from `ai-plugins` because the multi-host repo root
is not a Gemini extension root. The sync script copies `CHANGELOG.md`; update it
in Agent Kit source before release-oriented syncs.

## Validate The Mirror

Run from your local checkout of
[🐙 Endor Labs AI Plugins](https://github.com/endorlabs/ai-plugins/tree/main):

```bash
AGENT_KIT_REPO="/path/to/endor-labs-agent-kit"

for skill in skills/*; do python3 scripts/quick_validate.py "$skill"; done
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
python3 -m json.tool .agents/plugins/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/plugin.json >/dev/null
python3 -m json.tool cursor-sdk/agent_definitions.json >/dev/null
python3 -m json.tool hooks/hooks.json >/dev/null
python3 -m json.tool plugins/claude/endor-labs-agent-kit/hooks/hooks.json >/dev/null
python3 -m json.tool plugins/codex/endor-labs-agent-kit/hooks/hooks.json >/dev/null
python3 -m json.tool plugins/gemini/endor-labs-agent-kit/hooks/hooks.json >/dev/null
python3 -m json.tool plugins/antigravity/endor-labs-agent-kit/hooks.json >/dev/null
test ! -e plugins/claude/ai-plugins/hooks
for hook_script in hooks/*.sh plugins/*/*/hooks/*.sh; do bash -n "$hook_script"; done
python3 - <<'PY'
import py_compile

py_compile.compile("cursor-sdk/run_cursor_agent.py", cfile="/tmp/run_cursor_agent.pyc", doraise=True)
PY
test ! -e gemini-extension.json
test -f plugins/gemini/endor-labs-agent-kit/gemini-extension.json
test ! -e plugins/gemini/endor-labs-agent-kit.zip
diff -qr "$AGENT_KIT_REPO/plugins" ./plugins
diff -qr "$AGENT_KIT_REPO/.cursor-plugin" ./.cursor-plugin
diff -qr "$AGENT_KIT_REPO/agents" ./agents
diff -qr "$AGENT_KIT_REPO/cursor-sdk" ./cursor-sdk
diff -qr "$AGENT_KIT_REPO/hooks" ./hooks
for skill in "$AGENT_KIT_REPO"/skills/*; do
  name=${skill##*/}
  [ "$name" = "create-endor-labs-agent" ] && continue
  diff -qr "$skill" "./skills/$name"
done
diff -q "$AGENT_KIT_REPO/assets/logo.png" assets/logo.png
diff -q "$AGENT_KIT_REPO/CHANGELOG.md" CHANGELOG.md
git diff --check
```

Provider CLI validation is release-gated by the relevant host CLIs and public
refs. Use `docs/plugin-release-checklist.md` for the full release matrix.

## Expected Diff Shape

A normal documentation sync may include:

- root `README.md`
- root `CHANGELOG.md`
- `docs/`
- `llms.txt`
- package READMEs generated from Agent Kit
- `.cursor-plugin/`, generated root workflow `agents/`, generated root workflow
  `skills/`, generated root advisory `hooks/`, `cursor-sdk/`, and
  `assets/logo.png`
- package manifest checksum updates from Agent Kit

A normal generated package sync should not include hand-edited differences
inside `plugins/`.

## Safety Notes

- Do not create or publish a Gemini zip artifact.
- Do not enable both Claude package ids in the same profile for normal use.
- Do not couple Cursor package sync to Gemini CLI extension files.
- Do not add plugin-wide MCP unless a source decision and provider validation
  explicitly support it.
- The root `.mcp.json` file may declare the source-approved `endor-cli-tools`
  MCP server so users can opt into Endor MCP setup. Do not generate a root
  `gemini-extension.json`; Gemini discovers bundled skills from the installed
  extension root's `skills/` directory, and the repository root's `skills/`
  directory is the Cursor package surface. Generated host package manifests
  under `plugins/*/endor-labs-agent-kit/` must still stay MCP-free unless that
  host package explicitly validates MCP. Setup guidance remains CLI-first and
  must not start, register, or rely on MCP without explicit user approval.
- Do not run live `endorctl api` smoke tests without explicit approval and
  namespace provenance.

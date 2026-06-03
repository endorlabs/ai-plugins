# Distribution Sync

Use this guide when refreshing public Agent Kit distribution artifacts from the
source repo.

## Repo Boundary

| Repo | Owns |
| --- | --- |
| [🐙 The Endor Labs Agent Kit](https://github.com/endorlabs/endor-labs-agent-kit/tree/main) | Source recipes, compiler and publication code, guardrails, tests, provenance, generated catalog, and source documentation. |
| [🐙 Endor Labs AI Plugins](https://github.com/endorlabs/ai-plugins/tree/main) | Public host metadata, Cursor package metadata, root Cursor agents and support skills, Cursor SDK automation package, release-facing README, and checked-in distribution artifacts. |

Normal package sync should make `ai-plugins/plugins/` byte-for-byte identical to
`endor-labs-agent-kit/plugins/`. Cursor package sync should make
`ai-plugins/.cursor-plugin/`, generated root workflow `agents/`, generated root
workflow `skills/`, and `assets/logo.svg` match the source repo. Cursor SDK
sync should make `ai-plugins/cursor-sdk/` match the source repo.

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

rsync -a --delete "$AGENT_KIT_REPO/plugins/" ./plugins/
cp "$AGENT_KIT_REPO/.claude-plugin/marketplace.json" .claude-plugin/marketplace.json
cp "$AGENT_KIT_REPO/.agents/plugins/marketplace.json" .agents/plugins/marketplace.json
rsync -a --delete "$AGENT_KIT_REPO/.cursor-plugin/" ./.cursor-plugin/
rsync -a --delete "$AGENT_KIT_REPO/agents/" ./agents/
rsync -a --delete "$AGENT_KIT_REPO/cursor-sdk/" ./cursor-sdk/
for skill in ai-sast-triage endor-agent-kit-setup endor-troubleshooter probe-droid sca-remediation; do
  rsync -a --delete "$AGENT_KIT_REPO/skills/$skill/" "./skills/$skill/"
done
mkdir -p assets
cp "$AGENT_KIT_REPO/assets/logo.svg" assets/logo.svg
```

Do not copy the Agent Kit root README into this repo. The mirror root README is
distribution-specific and should explain public install paths, release checks,
and the source boundary.

Do not copy the Agent Kit root `skills/create-endor-labs-agent/` helper into
`ai-plugins`. Do not treat root `GEMINI.md` or root `gemini-extension.json` as
Cursor package files; Gemini CLI uses `plugins/gemini/endor-labs-agent-kit/`.

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
python3 -m py_compile cursor-sdk/run_cursor_agent.py
python3 -m json.tool gemini-extension.json >/dev/null
test -f plugins/gemini/endor-labs-agent-kit/gemini-extension.json
test ! -e plugins/gemini/endor-labs-agent-kit.zip
diff -qr "$AGENT_KIT_REPO/plugins" ./plugins
diff -qr "$AGENT_KIT_REPO/.cursor-plugin" ./.cursor-plugin
diff -qr "$AGENT_KIT_REPO/agents" ./agents
diff -qr "$AGENT_KIT_REPO/cursor-sdk" ./cursor-sdk
for skill in ai-sast-triage endor-agent-kit-setup endor-troubleshooter probe-droid sca-remediation; do
  diff -qr "$AGENT_KIT_REPO/skills/$skill" "./skills/$skill"
done
diff -q "$AGENT_KIT_REPO/assets/logo.svg" assets/logo.svg
git diff --check
```

Provider CLI validation is release-gated by the relevant host CLIs and public
refs. Use `docs/plugin-release-checklist.md` for the full release matrix.

## Expected Diff Shape

A normal documentation sync may include:

- root `README.md`
- `docs/`
- `llms.txt`
- package READMEs generated from Agent Kit
- `.cursor-plugin/`, generated root workflow `agents/`, generated root workflow
  `skills/`, `cursor-sdk/`, and `assets/logo.svg`
- package manifest checksum updates from Agent Kit

A normal generated package sync should not include hand-edited differences
inside `plugins/`.

## Safety Notes

- Do not create or publish a Gemini zip artifact.
- Do not enable both Claude package ids in the same profile for normal use.
- Do not couple Cursor package sync to Gemini CLI extension files.
- Do not add plugin-wide MCP unless a source decision and provider validation
  explicitly support it.
- Do not run live `endorctl api` smoke tests without explicit approval and
  namespace provenance.

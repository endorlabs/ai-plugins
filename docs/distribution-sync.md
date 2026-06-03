# Distribution Sync

Use this guide when refreshing public Agent Kit distribution artifacts from the
source repo.

## Repo Boundary

| Repo | Owns |
| --- | --- |
| `/Users/mattbrown/AURI/endor-labs-agent-kit` | Source recipes, compiler and publication code, guardrails, tests, provenance, generated catalog, and source documentation. |
| `/Users/mattbrown/AURI/ai-plugins` | Public host metadata, Cursor package metadata, root Cursor agents and support skills, release-facing README, and checked-in distribution artifacts. |

Normal package sync should make `ai-plugins/plugins/` byte-for-byte identical to
`endor-labs-agent-kit/plugins/`. Cursor package sync should make
`ai-plugins/.cursor-plugin/`, generated root workflow `agents/`, generated root
workflow `skills/`, and `assets/logo.svg` match the source repo.

## Regenerate Source Artifacts

Run from `/Users/mattbrown/AURI/endor-labs-agent-kit`:

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

Run from `/Users/mattbrown/AURI/ai-plugins` after source regeneration and
validation are clean:

```bash
rsync -a --delete /Users/mattbrown/AURI/endor-labs-agent-kit/plugins/ ./plugins/
cp /Users/mattbrown/AURI/endor-labs-agent-kit/.claude-plugin/marketplace.json .claude-plugin/marketplace.json
cp /Users/mattbrown/AURI/endor-labs-agent-kit/.agents/plugins/marketplace.json .agents/plugins/marketplace.json
rsync -a --delete /Users/mattbrown/AURI/endor-labs-agent-kit/.cursor-plugin/ ./.cursor-plugin/
rsync -a --delete /Users/mattbrown/AURI/endor-labs-agent-kit/agents/ ./agents/
for skill in ai-sast-triage endor-agent-kit-setup endor-troubleshooter probe-droid sca-remediation; do
  rsync -a --delete "/Users/mattbrown/AURI/endor-labs-agent-kit/skills/$skill/" "./skills/$skill/"
done
mkdir -p assets
cp /Users/mattbrown/AURI/endor-labs-agent-kit/assets/logo.svg assets/logo.svg
```

Do not copy the Agent Kit root README into this repo. The mirror root README is
distribution-specific and should explain public install paths, release checks,
and the source boundary.

Do not copy the Agent Kit root `skills/create-endor-labs-agent/` helper into
`ai-plugins`. Do not treat root `GEMINI.md` or root `gemini-extension.json` as
Cursor package files; Gemini CLI uses `plugins/gemini/endor-labs-agent-kit/`.

## Validate The Mirror

Run from `/Users/mattbrown/AURI/ai-plugins`:

```bash
for skill in skills/*; do python3 scripts/quick_validate.py "$skill"; done
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
python3 -m json.tool .agents/plugins/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/plugin.json >/dev/null
python3 -m json.tool gemini-extension.json >/dev/null
test -f plugins/gemini/endor-labs-agent-kit/gemini-extension.json
test ! -e plugins/gemini/endor-labs-agent-kit.zip
diff -qr /Users/mattbrown/AURI/endor-labs-agent-kit/plugins ./plugins
diff -qr /Users/mattbrown/AURI/endor-labs-agent-kit/.cursor-plugin ./.cursor-plugin
diff -qr /Users/mattbrown/AURI/endor-labs-agent-kit/agents ./agents
for skill in ai-sast-triage endor-agent-kit-setup endor-troubleshooter probe-droid sca-remediation; do
  diff -qr "/Users/mattbrown/AURI/endor-labs-agent-kit/skills/$skill" "./skills/$skill"
done
diff -q /Users/mattbrown/AURI/endor-labs-agent-kit/assets/logo.svg assets/logo.svg
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
  `skills/`, and `assets/logo.svg`
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

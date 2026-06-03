# Agent Kit Distribution Release Checklist

Use this checklist before publishing Endor Labs Agent Kit packages from
`endorlabs/ai-plugins`.

## Scope

Release all provider packages together unless the release notes explicitly
state a narrower provider-only fix.

Distribution roots:

- Claude Code: `.claude-plugin/marketplace.json` and
  `plugins/claude/endor-labs-agent-kit/`
- Claude Code legacy compatibility: `plugins/claude/ai-plugins/`
- Codex: `.agents/plugins/marketplace.json` and
  `plugins/codex/endor-labs-agent-kit/`
- Gemini CLI: `plugins/gemini/endor-labs-agent-kit/`
- Antigravity CLI: `plugins/antigravity/endor-labs-agent-kit/`
- Cursor/root skill-compatible hosts: `.cursor-plugin/`, `skills/`,
  `gemini-extension.json`, and `GEMINI.md`

## Source Sync

Agent behavior is source-owned by `endorlabs/endor-labs-agent-kit`.
Read `docs/distribution-sync.md` before syncing generated package artifacts and
`docs/for-agents.md` before asking an agent to review or edit this mirror.

Regenerate in the Agent Kit source repo:

```bash
endor-agent-kit publish source/agents/*/recipe.yaml --dest . --prune --include-plugins
pytest
endor-agent-kit check-guardrails --catalog-root .
endor-agent-kit verify-provenance --catalog-root .
git diff --check
```

Then sync generated artifacts into `ai-plugins`:

```bash
rsync -a --delete /path/to/endor-labs-agent-kit/plugins/ ./plugins/
cp /path/to/endor-labs-agent-kit/.claude-plugin/marketplace.json .claude-plugin/marketplace.json
cp /path/to/endor-labs-agent-kit/.agents/plugins/marketplace.json .agents/plugins/marketplace.json
```

The root Cursor/root skill-compatible package should be refreshed from the
generated common skill package while preserving root host wording.

## Local Validation

Run these from the `ai-plugins` repo root:

```bash
for skill in skills/*; do python3 scripts/quick_validate.py "$skill"; done
claude plugin validate plugins/claude/endor-labs-agent-kit
claude plugin validate plugins/claude/ai-plugins
python3 /Users/mattbrown/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/codex/endor-labs-agent-kit
test -f plugins/gemini/endor-labs-agent-kit/gemini-extension.json
test ! -e plugins/gemini/endor-labs-agent-kit.zip
antigravity plugin validate plugins/antigravity/endor-labs-agent-kit
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
python3 -m json.tool .agents/plugins/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/plugin.json >/dev/null
python3 -m json.tool gemini-extension.json >/dev/null
git diff --check
```

Compare generated package drift:

```bash
diff -qr /path/to/endor-labs-agent-kit/plugins ./plugins
```

Normal distribution sync should be byte-for-byte identical.

## Safety Gates

- Setup must not run scans.
- Setup must not run `endorctl host-check`.
- Setup must not install tools, edit shell profiles, write credentials, or
  configure MCP globally without explicit user approval.
- Live `endorctl api` smoke tests require explicit approval and must record
  namespace provenance.
- Repository-scoped Endor evidence must preserve
  `context.type==CONTEXT_TYPE_MAIN` defaults unless the user explicitly asks
  for PR, CI-run, commit, or all-context scope.
- Project lookup failures in a proven namespace must retry with `--traverse`
  before reporting project-not-found.

## Public Release Checks

Run public host install checks only after the branch and tag exist.

Claude Code:

```text
/plugin marketplace add endorlabs/ai-plugins@<tag>
/plugin install endor-labs-agent-kit@endorlabs
/plugin install ai-plugins@endorlabs
/plugin list
/agents
```

`ai-plugins@endorlabs` is retained for existing Claude Code users. Do not enable
both Claude plugin ids in the same profile for normal use because they expose
the same setup skill and agents. Release notes and install docs must state that
new installs should prefer `endor-labs-agent-kit@endorlabs`, existing users do
not need an automatic migration, and the plugin does not auto-disable,
uninstall, or edit Claude settings for either id.

Codex:

```bash
codex plugin marketplace add endorlabs/ai-plugins --ref <tag> --sparse .agents --sparse plugins/codex/endor-labs-agent-kit
codex plugin list --marketplace endor-labs-agent-kit
codex plugin add endor-labs-agent-kit@endor-labs-agent-kit
codex plugin remove endor-labs-agent-kit@endor-labs-agent-kit
```

Gemini CLI:

```bash
gemini extensions install https://github.com/endorlabs/ai-plugins --ref <tag>
gemini extensions list
gemini extensions uninstall endor-labs-agent-kit
```

Antigravity CLI:

```bash
antigravity plugin install /absolute/path/to/ai-plugins/plugins/antigravity/endor-labs-agent-kit
antigravity plugin list
antigravity plugin uninstall endor-labs-agent-kit
```

Cursor/root skill-compatible hosts:

```bash
for skill in skills/*; do python3 scripts/quick_validate.py "$skill"; done
python3 -m json.tool .cursor-plugin/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/plugin.json >/dev/null
```

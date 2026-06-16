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
- Cursor: `.cursor-plugin/`, generated root workflow `agents/`, generated root
  workflow `skills/`, generated root advisory `hooks/`, and `assets/logo.png`
- Cursor SDK: `cursor-sdk/`
- Root MCP/Gemini support context: `.mcp.json` and non-installable `GEMINI.md`

Package versions are not bumped automatically by Agent Kit maintainer merges.
The source `pyproject.toml` version is the release version for generated package
metadata; maintainers update it intentionally, regenerate artifacts, and keep
`CHANGELOG.md` current.

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

Then sync generated artifacts into `ai-plugins` with the source-owned mirror
sync script:

```bash
AGENT_KIT_REPO="/path/to/endor-labs-agent-kit"

python3 "$AGENT_KIT_REPO/scripts/sync_ai_plugins_distribution.py" \
  --source "$AGENT_KIT_REPO" \
  --target .
```

Do not sync root `GEMINI.md` as Cursor package output, and do not create a root
`gemini-extension.json`. Root `.mcp.json` and `GEMINI.md` are support context;
Gemini CLI uses `plugins/gemini/endor-labs-agent-kit/` as the installable
extension.

## Local Validation

Run these from the `ai-plugins` repo root:

```bash
for skill in skills/*; do python3 scripts/quick_validate.py "$skill"; done
claude plugin validate plugins/claude/endor-labs-agent-kit
claude plugin validate plugins/claude/ai-plugins
CODEX_PLUGIN_VALIDATOR="${CODEX_PLUGIN_VALIDATOR:-/path/to/plugin-creator/scripts/validate_plugin.py}"
python3 "$CODEX_PLUGIN_VALIDATOR" plugins/codex/endor-labs-agent-kit
test -f plugins/gemini/endor-labs-agent-kit/gemini-extension.json
test ! -e plugins/gemini/endor-labs-agent-kit.zip
antigravity plugin validate plugins/antigravity/endor-labs-agent-kit
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
python3 -m json.tool .mcp.json >/dev/null
test -f GEMINI.md
test ! -e gemini-extension.json
python3 - <<'PY'
import json
from pathlib import Path

definitions = json.loads(Path("cursor-sdk/agent_definitions.json").read_text(encoding="utf-8"))
for agent in definitions["agents"]:
    agent_name = agent["agent_name"]
    skill_id = agent["id"]
    assert Path("agents", f"{agent_name}.md").is_file(), agent_name
    assert Path("skills", skill_id, "SKILL.md").is_file(), skill_id
    assert Path("cursor-sdk", agent["prompt_file"]).is_file(), agent["prompt_file"]
PY
test -f skills/ai-sast-triage/architecture.svg
test -f skills/findings-browser/architecture.svg
test -f skills/malware-response/architecture.svg
test -f skills/sca-remediation/actions.yaml
test -f CHANGELOG.md
git diff --check
```

Compare generated package drift:

```bash
diff -qr /path/to/endor-labs-agent-kit/plugins ./plugins
diff -qr /path/to/endor-labs-agent-kit/.cursor-plugin ./.cursor-plugin
diff -qr /path/to/endor-labs-agent-kit/agents ./agents
diff -qr /path/to/endor-labs-agent-kit/cursor-sdk ./cursor-sdk
diff -qr /path/to/endor-labs-agent-kit/hooks ./hooks
for skill in /path/to/endor-labs-agent-kit/skills/*; do
  name=${skill##*/}
  [ "$name" = "create-endor-labs-agent" ] && continue
  diff -qr "$skill" "./skills/$name"
done
diff -q /path/to/endor-labs-agent-kit/assets/logo.png assets/logo.png
```

Normal provider package sync should be byte-for-byte identical, and Cursor
metadata/root workflow agents, support skills, and advisory hooks should match
the source-generated Cursor package. The root `CHANGELOG.md` should also match
the source repo so release notes travel with generated distribution PRs.

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

## Tag The Release

The release tag is created on `endorlabs/ai-plugins` (this repository), not on
the Agent Kit source repository. Public Codex and Gemini CLI installs resolve
the tag directly, so create it only after the release content is merged to
`main`:

```bash
VERSION="$(python3 -c "import json; print(next(p['version'] for p in json.load(open('.claude-plugin/marketplace.json'))['plugins'] if p['name'] == 'endor-labs-agent-kit'))")"
gh release create "$VERSION" --repo endorlabs/ai-plugins --target main \
  --title "Endor Labs Agent Kit $VERSION" --notes "See CHANGELOG.md."
```

The tag is the exact package version with no `v` prefix. Deriving `VERSION`
from this repository's `.claude-plugin/marketplace.json` keeps the tag equal to
the generated package metadata; do not compute it from an Agent Kit checkout,
and do not run `gh release create` from an Agent Kit checkout without
`--repo endorlabs/ai-plugins` (it would tag the private source repository).

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
git clone --depth 1 --branch <tag> https://github.com/endorlabs/ai-plugins ai-plugins-gemini-release
gemini extensions install ./ai-plugins-gemini-release/plugins/gemini/endor-labs-agent-kit
gemini extensions list
gemini extensions uninstall endor-labs-agent-kit
```

As of 2026-06-16, Google documents that Gemini CLI access for unpaid, Google
One, Google AI Pro, and Google AI Ultra consumer users transitions to
Antigravity CLI on 2026-06-18. Keep Gemini package validation for supported
enterprise/API-key users and extension compatibility, and run the Antigravity
validation below as the forward-path CLI check for affected consumer users.

Antigravity CLI:

```bash
antigravity plugin install /absolute/path/to/ai-plugins/plugins/antigravity/endor-labs-agent-kit
antigravity plugin list
antigravity plugin uninstall endor-labs-agent-kit
```

Cursor package and root workflow skills:

```bash
for skill in skills/*; do python3 scripts/quick_validate.py "$skill"; done
python3 -m json.tool .cursor-plugin/marketplace.json >/dev/null
python3 -m json.tool .cursor-plugin/plugin.json >/dev/null
python3 - <<'PY'
import json
from pathlib import Path

definitions = json.loads(Path("cursor-sdk/agent_definitions.json").read_text(encoding="utf-8"))
for agent in definitions["agents"]:
    agent_name = agent["agent_name"]
    skill_id = agent["id"]
    assert Path("agents", f"{agent_name}.md").is_file(), agent_name
    assert Path("skills", skill_id, "SKILL.md").is_file(), skill_id
PY
test -f skills/ai-sast-triage/architecture.svg
test -f skills/findings-browser/architecture.svg
test -f skills/malware-response/architecture.svg
test -f skills/sca-remediation/actions.yaml
test -f hooks/hooks.json
test -f assets/logo.png
```

Keep Cursor validation separate from Gemini validation. Cursor uses
`.cursor-plugin/`, `agents/`, `skills/`, `hooks/`, and `assets/logo.png`;
Gemini CLI uses `plugins/gemini/endor-labs-agent-kit/`.

The public Cursor Marketplace listing
([cursor.com/marketplace/endorlabs](https://cursor.com/marketplace/endorlabs))
is not updated automatically by pushes or tags on this repository. After
tagging, refresh or resubmit the listing through the Cursor marketplace
submission process, then verify from Cursor Agent chat that
`/add-plugin endorlabs` installs the released package version. A stale listing
is invisible to the drift checks above, so do not skip this step.

Cursor SDK automation:

```bash
python3 -m json.tool cursor-sdk/agent_definitions.json >/dev/null
python3 - <<'PY'
import py_compile

py_compile.compile("cursor-sdk/run_cursor_agent.py", cfile="/tmp/run_cursor_agent.pyc", doraise=True)
PY
test -f cursor-sdk/requirements.txt
test -f cursor-sdk/agents/endor-agent-kit-setup-agent.md
test -f cursor-sdk/agents/endor-malware-response-agent.md
test -f cursor-sdk/agents/endor-probe-droid-agent.md
```

Do not run Cursor SDK local or cloud smoke tests without explicit approval for
`CURSOR_API_KEY` use, target repository, namespace provenance, and any possible
workflow side effects.

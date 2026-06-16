# 🧩 Endor Labs AI Plugins

Public distribution repository for Endor Labs Agent Kit packages across Claude
Code, Codex, Gemini CLI, Antigravity CLI, Cursor IDE, Cursor SDK, and root MCP
support context.

> [!IMPORTANT]
> This repo is the distribution mirror. Agent behavior, generated package
> shape, guardrails, tests, and source documentation are owned by
> [🐙 The Endor Labs Agent Kit](https://github.com/endorlabs/endor-labs-agent-kit/tree/main).

Current generated Agent Kit package version: `2.1.0`. Agent Kit maintainer
merges open or update generated distribution PRs in this repo, but they do not
automatically bump package versions. Version bumps are intentional release
actions from the source repo.

## 🚦 Start Here

| I want to... | Go here |
| --- | --- |
| 🚀 Install a host package | [Quick Start](#-quick-start) |
| 🧾 See what changed | [`CHANGELOG.md`](CHANGELOG.md) |
| 🖱️ Use Cursor IDE agents | [Cursor IDE](#cursor-ide) |
| 🐍 Run Cursor SDK automation | [`cursor-sdk/README.md`](cursor-sdk/README.md) |
| 🤖 Ask an agent to review this mirror | [`docs/for-agents.md`](docs/for-agents.md) |
| 📦 Sync from Agent Kit source | [`docs/distribution-sync.md`](docs/distribution-sync.md) |
| ✅ Prepare a release | [`docs/plugin-release-checklist.md`](docs/plugin-release-checklist.md) |

A machine-readable index is available in [`llms.txt`](llms.txt).

## 🧭 Browse The Distribution

| Area | What is inside |
| --- | --- |
| 🧑‍💻 Claude Code | `.claude-plugin/marketplace.json`, `plugins/claude/endor-labs-agent-kit/`, legacy `plugins/claude/ai-plugins/` |
| 🧠 Codex | `.agents/plugins/marketplace.json`, `plugins/codex/endor-labs-agent-kit/` |
| 💎 Gemini CLI | `plugins/gemini/endor-labs-agent-kit/` |
| 🛫 Antigravity CLI | `plugins/antigravity/endor-labs-agent-kit/` |
| 🖱️ Cursor IDE | `.cursor-plugin/`, root `agents/`, root `skills/`, root advisory `hooks/`, `assets/logo.png` |
| 🐍 Cursor SDK | `cursor-sdk/` Python launcher, generated prompts, and agent definitions |
| 🔁 Root support | `.mcp.json`, `GEMINI.md` |
| 🧾 Release docs | `docs/`, `llms.txt`, `plugins/README.md` |

## 🚀 Quick Start

Pick your host, install the package, then run setup. Setup checks local
readiness and does not run scans.

```text
Use the endor-agent-kit-setup skill to check Endor Agent Kit readiness. Do not run scans.
```

### Claude Code

Install the preferred package id:

```text
/plugin marketplace add endorlabs/ai-plugins
/plugin install endor-labs-agent-kit@endorlabs
/reload-plugins
/agents
```

Existing Claude Code users pinned to the historical id can keep using:

```text
/plugin marketplace add endorlabs/ai-plugins
/plugin install ai-plugins@endorlabs
/reload-plugins
/agents
```

Do not enable `endor-labs-agent-kit@endorlabs` and `ai-plugins@endorlabs` in
the same Claude profile for normal use. They expose the same setup skill and
agents.

Details: [`plugins/claude/endor-labs-agent-kit/README.md`](plugins/claude/endor-labs-agent-kit/README.md).

### Codex

Add the Endor Labs marketplace, restart Codex, then install **Endor Labs Agent
Kit** from the Codex plugin directory:

```bash
codex plugin marketplace add endorlabs/ai-plugins \
  --sparse .agents/plugins \
  --sparse plugins/codex/endor-labs-agent-kit
```

After installation, start a new Codex thread and ask setup to install or update
the bundled Endor custom agents:

```text
Use the endor-agent-kit-setup skill to check readiness and install the bundled Codex custom agents.
```

Details: [`plugins/codex/endor-labs-agent-kit/README.md`](plugins/codex/endor-labs-agent-kit/README.md).

### Cursor IDE

Install the current public Cursor Marketplace package from Cursor Agent chat:

```text
/add-plugin endorlabs
```

Marketplace page: [`cursor.com/marketplace/endorlabs`](https://cursor.com/marketplace/endorlabs).

Open the target project folder, reload Cursor if prompted, then run setup:

```text
Use the endor-agent-kit-setup skill to set up endorctl.
```

### Cursor SDK

Use the SDK lane for Python automation, CI, orchestration, backend services, or
Cursor cloud agents:

```bash
python3 -m pip install -r cursor-sdk/requirements.txt
export CURSOR_API_KEY="crsr_..."
python cursor-sdk/run_cursor_agent.py endor-probe-droid-agent \
  --workspace /path/to/repo \
  "Explain what evidence you need to assess GitHub onboarding gaps. Keep it read-only."
```

Cloud run shape:

```bash
python cursor-sdk/run_cursor_agent.py endor-sca-remediation-agent \
  --mode cloud \
  --repo-url https://github.com/your-org/your-repo \
  --ref main \
  "Prepare a remediation plan only. Do not edit files or open a PR."
```

### Gemini CLI

Install the generated Gemini extension package from the public repository:

```bash
git clone https://github.com/endorlabs/ai-plugins
gemini extensions install ./ai-plugins/plugins/gemini/endor-labs-agent-kit
gemini extensions list
```

For local validation from a checkout, install the generated extension directory:

```bash
gemini extensions install ./plugins/gemini/endor-labs-agent-kit
```

Restart Gemini CLI after installing or reinstalling the extension.

Google documents Antigravity CLI as the consumer transition path for Gemini
CLI. Use the Gemini package for supported Gemini CLI environments and
compatibility checks; use the Antigravity package below for affected Gemini CLI
consumer accounts.

Details: [`plugins/gemini/endor-labs-agent-kit/README.md`](plugins/gemini/endor-labs-agent-kit/README.md).

### Antigravity CLI

Clone the distribution repo, then install the generated plugin directory:

```bash
git clone https://github.com/endorlabs/ai-plugins
cd ai-plugins
agy plugin validate ./plugins/antigravity/endor-labs-agent-kit
agy plugin install ./plugins/antigravity/endor-labs-agent-kit
agy plugin list
```

Some Antigravity installs expose the command as `antigravity` instead of `agy`;
use the same `plugin validate`, `plugin install`, and `plugin list` subcommands.
Restart Antigravity CLI if newly installed skills or subagents are not visible.

Details: [`plugins/antigravity/endor-labs-agent-kit/README.md`](plugins/antigravity/endor-labs-agent-kit/README.md).

## ⚡ Agent Quick Starts

| Agent | Best for | Cursor / SDK name | Safety | First prompt |
| --- | --- | --- | --- | --- |
| 🔎 AI SAST Triage | Triage Endor AI SAST findings and prepare approved change requests | `endor-ai-sast-triage-agent` | approval-gated mutating | `Triage AI SAST findings for this repository. Do not edit files, open a PR/MR, create a ticket, or write an Endor policy until I approve the specific gate.` |
| 🧭 CI/CD And Supply Chain Posture | Assess CI/CD and supply chain posture from existing Endor findings and read-only GitHub configuration evidence | `endor-cicd-posture-agent` | read-only | `Assess CI/CD and supply chain posture for namespace <namespace>. Keep it read-only and validate the deterministic score.` |
| ⚖️ Dependency Decision Helper | Decide whether to add, upgrade to, or keep a specific package version | `endor-dependency-decision-helper-agent` | read-only | `Assess whether we should use npm lodash version 4.17.20. Keep it read-only.` |
| 📊 Package Risk Summary | Summarize the risk profile of a specific package version | `endor-package-risk-summary-agent` | read-only | `Summarize npm lodash version 4.17.20 with verified Endor evidence. Keep it read-only.` |
| 📚 Repository Dependency Reviewer | Review local dependency manifests with read-only file inspection and Endor evidence | `endor-repository-dependency-reviewer-agent` | read-only | `Review this repository's dependency manifests with read-only evidence only.` |
| ⬆️ Upgrade Impact Analysis | Analyze Endor platform upgrade impact with VersionUpgrade, CIA, findings, and manifest context | `endor-upgrade-impact-analysis-agent` | read-only | `Show the safest upgrade path for repository <owner>/<repo> package lodash. Keep it read-only.` |
| 💬 Vulnerability Explainer | Understand a specific CVE, GHSA, or Endor vulnerability and what to do next | `endor-vulnerability-explainer-agent` | read-only | `Explain CVE-2021-44228 using verified Endor evidence. Keep it read-only.` |
| 🧯 Endor Troubleshooter | Diagnose setup, scan, auth, policy, or integration issues | `endor-troubleshooter-agent` | read-only | `Diagnose this Endor issue from redacted error text and read-only tenant evidence. Keep it read-only.` |
| 🔍 Findings Browser | Browse, filter, and summarize existing Endor findings | `endor-findings-browser-agent` | read-only | `Show the critical and high reachable findings for namespace <namespace>. Keep it read-only.` |
| 🤖 Malware Response | Correlate supply-chain malware intelligence against tenant inventory | `endor-malware-response-agent` | read-only | `Use the malware-response workflow. Keep it within its generated safety contract.` |
| 📡 Probe Droid | Assess GitHub onboarding and monitored-branch coverage gaps | `endor-probe-droid-agent` | read-only | `Explain what evidence you need to assess GitHub onboarding gaps for this repository. Keep it read-only.` |
| 🗺️ Remediation Planner | Preview safe dependency remediation options without opening PRs | `endor-remediation-planner-agent` | read-only | `Preview remediation options for this repository. Do not edit files or open a PR/MR.` |
| 🛠️ SCA Remediation | Find safe dependency remediation paths with Endor SCA evidence | `endor-sca-remediation-agent` | approval-gated mutating | `Inspect this repository and prepare a remediation plan only. Do not edit files, create branches, push, open a PR/MR, create a ticket, or write Endor policy.` |
| 🧰 Setup | Check host, auth, namespace, `endorctl`, `gh`, and workflow readiness | `endor-agent-kit-setup-agent` | read-only | `Check Endor Agent Kit readiness for this repository. Do not run scans.` |

The provider packages expose the same generated workflow set from Agent Kit
source recipes. Use the host package README for exact install and invocation
syntax.

## 📦 Distribution Paths

| Host | Distribution path | Notes |
| --- | --- | --- |
| Claude Code | `.claude-plugin/marketplace.json`, `plugins/claude/endor-labs-agent-kit/`, `plugins/claude/ai-plugins/` | Preferred package plus legacy compatibility. |
| Codex | `.agents/plugins/marketplace.json`, `plugins/codex/endor-labs-agent-kit/` | Skills, custom-agent TOML files, and installer script. |
| Gemini CLI | `plugins/gemini/endor-labs-agent-kit/` | Directory install locally; tagged GitHub repo for public installs. |
| Antigravity CLI | `plugins/antigravity/endor-labs-agent-kit/` | Package directory with root `plugin.json`. |
| Cursor IDE | `.cursor-plugin/`, `agents/`, `skills/`, `hooks/`, `assets/logo.png` | Source-generated Cursor plugin agents, support skills, and advisory hooks. |
| Cursor SDK | `cursor-sdk/` | Python SDK launcher, generated prompts, and local/cloud run instructions. |
| Root support | `.mcp.json`, `GEMINI.md` | Optional MCP support context; the repository root is not a Gemini extension root. |

## 🔒 Safety Rules

- Setup is readiness guidance; it must not run scans or mutate repositories.
- Setup must not run `endorctl host-check`.
- Install, update, auth, namespace, and host-specific package steps must be
  explicit and evidence-backed.
- Do not print, persist, or copy secret values. Report credential presence only
  by variable or key name.
- Live Endor API evidence requires explicit approval and namespace provenance.
- Mutating workflows split file edits, branch pushes, PR/MR creation, comments,
  tickets, approval verification, and Endor policy writes into separate gates.

## 🔁 Source Sync

Do not change generated Agent Kit behavior by editing package files in this
repo. Make behavior changes in the Agent Kit source repo, regenerate there,
then let the Agent Kit publish workflow open a generated PR here.

Generated sync PRs should include:

- source Agent Kit commit in the PR body
- `provenance/agent-kit-catalog.intoto.json`
- `provenance/manifest.sha256`
- validation evidence for root skills, advisory hooks, JSON metadata, Cursor
  SDK, Gemini no-zip, byte-for-byte generated-surface diffs, and
  `git diff --check`

Manual fallback uses the Agent Kit sync script:

```bash
AGENT_KIT_REPO="/path/to/endor-labs-agent-kit"

python3 "$AGENT_KIT_REPO/scripts/sync_ai_plugins_distribution.py" \
  --source "$AGENT_KIT_REPO" \
  --target .
```

## ✅ Validation

```bash
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
git diff --check
```

These checks also run automatically on every pull request via
[`.github/workflows/validate.yml`](.github/workflows/validate.yml).

Generated drift checks:

```bash
AGENT_KIT_REPO="/path/to/endor-labs-agent-kit"

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
```

## 🗂️ Repository Reference

```text
.agents/plugins/marketplace.json
.claude-plugin/marketplace.json
.cursor-plugin/
agents/
assets/logo.png
cursor-sdk/
docs/
hooks/
.mcp.json
GEMINI.md
llms.txt
plugins/
scripts/
skills/
```

## License

This repository includes the existing `LICENSE` file and Endor Labs plugin
metadata for the public distribution packages. Confirm final marketplace,
license, and host metadata requirements before public submission.

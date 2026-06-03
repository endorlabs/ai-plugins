# Endor Labs AI Plugins

Public distribution repository for Endor Labs Agent Kit packages across AI
coding hosts.

This repo mirrors the generated package outputs from
`endorlabs/endor-labs-agent-kit`. The Agent Kit source repo owns recipes,
compiler code, guardrails, tests, provenance checks, and generated artifact
publication. This repo owns public host metadata, install documentation, and
checked-in distribution artifacts.

Current generated Agent Kit package version: `0.1.0`.

## Start Here

| Reader | Start With | Outcome |
| --- | --- | --- |
| Human installer | [Quick Start](#quick-start) | Install the right host package, run setup, and try a workflow. |
| Agent installer or reviewer | `docs/for-agents.md` | Understand what can be copied, what is generated, and when to stop for approval. |
| Distribution maintainer | `docs/distribution-sync.md` | Sync generated packages from `endor-labs-agent-kit` without drifting the mirror. |
| Release operator | `docs/plugin-release-checklist.md` | Validate local packages and public host install paths before tagging or publishing. |

This repo is the public distribution surface. Behavior changes belong in the
Agent Kit source repo first, then this repo is refreshed from generated outputs.
A machine-readable index is available in `llms.txt`.

## Quick Start

Use `endor-agent-kit-setup` first after installing a package. Setup checks local
readiness, guides `endorctl` authentication and namespace selection, reports
`gh` and toolchain gaps, and offers host-specific self-checks before live Endor
lookups.

Claude Code marketplace install for new users:

```text
/plugin marketplace add endorlabs/ai-plugins
/plugin install endor-labs-agent-kit@endorlabs
/reload-plugins
/agents
```

Existing Claude Code users with the historical plugin id can keep using the
legacy compatibility package:

```text
/plugin marketplace add endorlabs/ai-plugins
/plugin install ai-plugins@endorlabs
/reload-plugins
/agents
```

Do not enable `endor-labs-agent-kit@endorlabs` and `ai-plugins@endorlabs` in
the same Claude profile for normal use. They expose the same setup skill and
agents; `ai-plugins@endorlabs` exists to avoid breaking existing installs. The
plugin does not auto-disable, uninstall, or edit Claude settings for either id.

Local Claude Code validation from this checkout:

```text
/plugin marketplace add ./
/plugin install endor-labs-agent-kit@endorlabs
/plugin install ai-plugins@endorlabs
/reload-plugins
/agents
```

Codex marketplace metadata is available at `.agents/plugins/marketplace.json`
and points at `plugins/codex/endor-labs-agent-kit/`.

Gemini and Antigravity packages are staged under `plugins/`. Gemini installs
from the generated extension directory for local validation and from the tagged
GitHub repository for public distribution; no zip artifact is published.

Cursor uses the repository root package metadata in `.cursor-plugin/` and the
root Agent Kit skill set in `skills/`.

## Distribution Paths

| Host | Distribution path | Notes |
| --- | --- | --- |
| Claude Code | `.claude-plugin/marketplace.json`, `plugins/claude/endor-labs-agent-kit/`, `plugins/claude/ai-plugins/` | Marketplace exposes preferred `endor-labs-agent-kit` plus legacy `ai-plugins` compatibility. |
| Codex | `.agents/plugins/marketplace.json`, `plugins/codex/endor-labs-agent-kit/` | Package includes skills, custom-agent TOML files, and installer script. |
| Gemini CLI | `plugins/gemini/endor-labs-agent-kit/` | Directory is for local validation; public installs use the tagged GitHub repository. |
| Antigravity CLI | `plugins/antigravity/endor-labs-agent-kit/` | Installs from the package directory with root `plugin.json`. |
| Cursor | `.cursor-plugin/`, `skills/`, `assets/logo.svg` | Root skill package mirrors Agent Kit's common workflows. |
| Root skill-compatible hosts | `gemini-extension.json`, `GEMINI.md`, `skills/` | Compatibility surface for hosts that load root skill directories. |

## Capabilities

| Job | Claude Code | Codex | Gemini CLI | Antigravity CLI | Cursor/root |
| --- | --- | --- | --- | --- | --- |
| Set up this machine and self-check readiness | Skill `endor-agent-kit-setup` | Skill `endor-agent-kit-setup` | Skill `endor-agent-kit-setup` | Skill `endor-agent-kit-setup` | Skill `endor-agent-kit-setup` |
| Triage Endor AI SAST findings | Agent `endor-labs-agent-kit:ai-sast-triage` | Skill `ai-sast-triage`, custom agent `endor-ai-sast-triage-agent` | Skill/subagent `ai-sast-triage` | Skill/subagent `ai-sast-triage` | Skill `ai-sast-triage` |
| Diagnose Endor setup, scan, or integration issues | Agent `endor-labs-agent-kit:endor-troubleshooter` | Skill `endor-troubleshooter`, custom agent `endor-troubleshooter-agent` | Skill/subagent `endor-troubleshooter` | Skill/subagent `endor-troubleshooter` | Skill `endor-troubleshooter` |
| Assess GitHub onboarding gaps | Agent `endor-labs-agent-kit:probe-droid` | Skill `probe-droid`, custom agent `endor-probe-droid-agent` | Skill/subagent `probe-droid` | Skill/subagent `probe-droid` | Skill `probe-droid` |
| Find safe SCA remediation paths | Agent `endor-labs-agent-kit:sca-remediation` | Skill `sca-remediation`, custom agent `endor-sca-remediation-agent` | Skill/subagent `sca-remediation` | Skill/subagent `sca-remediation` | Skill `sca-remediation` |
| Use Claude-only read-only package and dependency helpers | Claude agents in `plugins/claude/endor-labs-agent-kit/agents/` | Not packaged in v1 | Not packaged in v1 | Not packaged in v1 | Not packaged in v1 |

The legacy Claude package `plugins/claude/ai-plugins/` contains the same Claude
agents and setup skill for existing `ai-plugins@endorlabs` users. New users
should prefer `endor-labs-agent-kit@endorlabs`; existing users do not need an
automatic migration.

## Safety Rules

- Setup is readiness and configuration guidance; setup must not run scans or
  mutate repositories.
- Setup must not run `endorctl host-check`.
- Install, update, auth, namespace, and host-specific package steps must be
  explicit and evidence-backed.
- Do not print, persist, or copy secret values. Report credential presence only
  by variable or key name.
- Do not auto-install `gh`, language runtimes, package managers, Docker, JDKs,
  or build tooling.
- Do not run live `endorctl api` commands unless the user explicitly needs that
  evidence and approves it.
- Do not claim a file edit, branch push, PR/MR, ticket, policy write, or
  approval unless the host or adapter returned evidence.

## Endor Lookup Defaults

Generated Agent Kit workflows preserve these lookup requirements:

- Repository-scoped Endor evidence defaults to
  `context.type==CONTEXT_TYPE_MAIN` unless the user explicitly asks for PR,
  CI-run, commit, or all-context scope.
- If a project is not found in a proven namespace, workflows retry the same
  read-only project lookup with `--traverse` before reporting
  project-not-found.
- If traverse resolution finds a child namespace, workflows record namespace
  provenance and use the child namespace for subsequent scoped reads when
  available.

## Agent Catalog

| Agent | Use it when you want to... | Claude Code | Codex | Gemini | Antigravity | Cursor/root |
| --- | --- | --- | --- | --- | --- | --- |
| AI SAST Triage | Triage Endor AI SAST findings, use exploit/remediation context, and open requested change requests | `plugins/claude/endor-labs-agent-kit/agents/ai-sast-triage.md` | `plugins/codex/endor-labs-agent-kit/skills/ai-sast-triage/` | `plugins/gemini/endor-labs-agent-kit/skills/ai-sast-triage/` | `plugins/antigravity/endor-labs-agent-kit/skills/ai-sast-triage/` | `skills/ai-sast-triage/` |
| Endor Troubleshooter | Diagnose Endor Labs errors, warnings, scan failures, missing integrations, SSO, containers, policy, and reachability issues | `plugins/claude/endor-labs-agent-kit/agents/endor-troubleshooter.md` | `plugins/codex/endor-labs-agent-kit/skills/endor-troubleshooter/` | `plugins/gemini/endor-labs-agent-kit/skills/endor-troubleshooter/` | `plugins/antigravity/endor-labs-agent-kit/skills/endor-troubleshooter/` | `skills/endor-troubleshooter/` |
| Probe Droid | Probe GitHub.com onboarding gaps and prescribe Endor setup actions | `plugins/claude/endor-labs-agent-kit/agents/probe-droid.md` | `plugins/codex/endor-labs-agent-kit/skills/probe-droid/` | `plugins/gemini/endor-labs-agent-kit/skills/probe-droid/` | `plugins/antigravity/endor-labs-agent-kit/skills/probe-droid/` | `skills/probe-droid/` |
| SCA Remediation | Remediate dependency vulnerabilities with Endor SCA findings, UIA evidence, risk decisions, validation, and approved PR/MR creation | `plugins/claude/endor-labs-agent-kit/agents/sca-remediation.md` | `plugins/codex/endor-labs-agent-kit/skills/sca-remediation/` | `plugins/gemini/endor-labs-agent-kit/skills/sca-remediation/` | `plugins/antigravity/endor-labs-agent-kit/skills/sca-remediation/` | `skills/sca-remediation/` |
| Dependency Decision Helper | Decide whether to add, upgrade to, or keep a package version | `plugins/claude/endor-labs-agent-kit/agents/dependency-decision-helper.md` | - | - | - | - |
| Package Risk Summary | Summarize package-version risk | `plugins/claude/endor-labs-agent-kit/agents/package-risk-summary.md` | - | - | - | - |
| Repository Dependency Reviewer | Review local dependency manifests with read-only Endor evidence | `plugins/claude/endor-labs-agent-kit/agents/repository-dependency-reviewer.md` | - | - | - | - |
| Upgrade Impact Analysis | Analyze Endor platform upgrade impact with VersionUpgrade, CIA, findings, and manifest context | `plugins/claude/endor-labs-agent-kit/agents/upgrade-impact-analysis.md` | - | - | - | - |
| Vulnerability Explainer | Understand a CVE, GHSA, or Endor vulnerability and next actions | `plugins/claude/endor-labs-agent-kit/agents/vulnerability-explainer.md` | - | - | - | - |
| Remediation Planner | Preview safe dependency remediation options without opening PRs | `plugins/claude/endor-labs-agent-kit/agents/remediation-planner.md` | - | - | - | - |

## Cursor And Root Package

The old root `endor-setup` skill has been replaced by the Agent Kit root skill
package. Existing Cursor users who need the former behavior should stay pinned
to their existing SHA.

The current Cursor/root package contains:

```text
.cursor-plugin/
  marketplace.json
  plugin.json
assets/
  logo.svg
skills/
  ai-sast-triage/
  endor-agent-kit-setup/
  endor-troubleshooter/
  probe-droid/
  sca-remediation/
GEMINI.md
gemini-extension.json
```

The root package mirrors the common generated Agent Kit skills and normalizes
host framing for skill-compatible hosts. It does not include Claude-only agents
or Codex custom-agent TOML files.

## Package Generation

Do not change generated Agent Kit behavior by editing package files in this
repo. Make behavior changes in the Agent Kit source repo, regenerate there,
then sync generated distribution artifacts here.

Agents should read `docs/for-agents.md` before modifying this repo and
`docs/distribution-sync.md` before touching generated package directories.

Source repo command:

```bash
endor-agent-kit publish source/agents/*/recipe.yaml --dest . --prune --include-plugins
```

Generated artifacts to sync into this repo:

- `plugins/`
- `.claude-plugin/marketplace.json`
- `.agents/plugins/marketplace.json`

The root Cursor/skill-compatible package is derived from the generated common
skill package and should preserve the same safety-critical workflow body.

## Validation

Run the distribution checks from this repo before commit:

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

Compare generated packages against the Agent Kit source repo:

```bash
diff -qr /path/to/endor-labs-agent-kit/plugins ./plugins
```

The only acceptable difference should be an explicitly documented distribution
decision. A normal sync should be byte-for-byte identical.

## Release Checklist

Use `docs/plugin-release-checklist.md` before publishing. Keep local validation
separate from public release validation:

- Local package validation can run without Endor API calls.
- Public Claude/Codex/Gemini/Antigravity install checks require pushed refs,
  tags, or host-specific marketplaces.
- Live tenant lookups and `endorctl api` smoke tests require explicit approval
  and should record namespace provenance.

## MCP Usage

MCP is not configured by default. AI SAST Triage, SCA Remediation, Probe Droid,
and Endor Troubleshooter use documented Endor API or `endorctl api` lookup
paths only when the selected workflow needs evidence and the user approves live
Endor access.

Claude-only read-only helper agents may still mention Endor MCP where their
source recipes require package or vulnerability lookups. If MCP is unavailable,
they must record the missing signal in `data_gaps` rather than fabricating
evidence.

## Example Prompts

Claude Code:

```text
@agent-endor-labs-agent-kit:ai-sast-triage triage AI SAST findings for this repository
@agent-endor-labs-agent-kit:endor-troubleshooter diagnose this Endor scan failure from redacted error text
@agent-endor-labs-agent-kit:probe-droid probe GitHub org <org> for Endor onboarding gaps
@agent-endor-labs-agent-kit:sca-remediation check this repository for P0 SCA findings I can start remediating
```

Codex, Cursor, Gemini, Antigravity, or root skill-compatible hosts:

```text
Use the endor-agent-kit-setup skill to check Endor Agent Kit readiness.
Use the ai-sast-triage skill to triage AI SAST findings for this repository.
Use the endor-troubleshooter skill to diagnose this Endor issue from redacted evidence.
Use the probe-droid skill to probe GitHub org <org> for Endor onboarding gaps.
Use the sca-remediation skill to check this repository for P0 SCA findings I can start remediating.
```

## Repository Reference

```text
.agents/plugins/marketplace.json
.claude-plugin/marketplace.json
.cursor-plugin/
assets/logo.svg
docs/
  distribution-sync.md
  for-agents.md
  plugin-release-checklist.md
GEMINI.md
gemini-extension.json
llms.txt
plugins/
  README.md
  claude/
  codex/
  gemini/
  antigravity/
scripts/
skills/
```

## License

This repository includes the existing `LICENSE` file and Endor Labs plugin
metadata for the public distribution packages. Confirm final marketplace,
license, and host metadata requirements before public submission.

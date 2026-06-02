# Endor Labs AI Plugins

Published Endor Labs plugin distribution for AI coding hosts.

This repository is the public distribution surface for Endor Labs AI plugins.
It now carries generated Endor Labs Agent Kit plugin packages beside the
existing setup skill that the Cursor plugin still depends on.

Use this repository in three ways:

- **Install Claude Code plugins** from the published `endorlabs` marketplace.
- **Use staged Agent Kit packages** for Claude Code, Codex, Gemini CLI, and Antigravity CLI.
- **Preserve legacy setup/Cursor support** while Agent Kit package generation
  continues to live in `endorlabs/endor-labs-agent-kit`.

Agent Kit source recipes, compiler code, tests, guardrails, and generated
artifact provenance live in the Agent Kit source repository. Generated files
under `plugins/` should be refreshed from that source repo rather than edited
by hand here.

## Table Of Contents

- [Plugin Quick Start](#plugin-quick-start)
- [Capabilities And Skills](#capabilities-and-skills)
- [Boundaries And Rules](#boundaries-and-rules)
- [Agent Catalog](#agent-catalog)
- [Which Directory Do I Use?](#which-directory-do-i-use)
- [Cursor Compatibility](#cursor-compatibility)
- [Supported Hosts](#supported-hosts)
- [Already Have Your Own Tech Stack Or Workflows Wired?](#already-have-your-own-tech-stack-or-workflows-wired)
- [MCP Usage](#mcp-usage)
- [Plugin Packaging Route](#plugin-packaging-route)
- [Release Checklist](#release-checklist)
- [Configure Endor Access](#configure-endor-access)
- [Example Prompts](#example-prompts)
- [Output Contract](#output-contract)
- [Safety Model](#safety-model)
- [Contribute Or Change An Agent](#contribute-or-change-an-agent)
- [Repository Reference](#repository-reference)
- [Release And License](#release-and-license)

## Plugin Quick Start

Current generated Agent Kit plugin package version: `0.1.0`.

The Claude Code marketplace is `endorlabs`. It exposes the existing setup
plugin plus the generated Agent Kit plugin package:

| Plugin | Purpose |
| --- | --- |
| `ai-plugins` | Legacy Endor setup skill for installing and authenticating `endorctl`. |
| `endor-labs-agent-kit` | Generated Claude Code agents and setup skill for Endor Labs security workflows. |

Install the generated Agent Kit plugin from Claude Code:

```text
/plugin marketplace add endorlabs/ai-plugins
/plugin install endor-labs-agent-kit@endorlabs
/reload-plugins
/agents
```

The legacy setup plugin remains available:

```text
/plugin marketplace add endorlabs/ai-plugins
/plugin install ai-plugins@endorlabs
```

Local Claude Code validation from a checkout:

```text
/plugin marketplace add ./
/plugin install endor-labs-agent-kit@endorlabs
/reload-plugins
/agents
```

Codex, Gemini, and Antigravity Agent Kit packages are staged in this repository under
`plugins/`, but this slice does not change their published root install path.
Use their package READMEs while validating provider-specific behavior.

| Host | Plugin package | First install path |
| --- | --- | --- |
| Claude Code | `plugins/claude/endor-labs-agent-kit/` | Read `plugins/claude/endor-labs-agent-kit/README.md`, then install `endor-labs-agent-kit@endorlabs` from the `endorlabs` marketplace. |
| Codex | `plugins/codex/endor-labs-agent-kit/` | Read `plugins/codex/endor-labs-agent-kit/README.md`, then use a local Codex marketplace add during validation. |
| Gemini CLI | `plugins/gemini/endor-labs-agent-kit/` | Read `plugins/gemini/endor-labs-agent-kit/README.md`, then validate the local extension directory or release archive. |
| Antigravity CLI | `plugins/antigravity/endor-labs-agent-kit/` | Read `plugins/antigravity/endor-labs-agent-kit/README.md`, then validate and install the generated plugin directory with Antigravity CLI. |

After installing a generated Agent Kit plugin, ask the host to use the
`endor-agent-kit-setup` skill first. Setup checks local readiness, guides
`endorctl` authentication and namespace selection, reports `gh` and toolchain
gaps, and offers host-specific self-checks before live Endor lookups.

## Capabilities And Skills

When a generated Agent Kit plugin package is loaded, start from the user job
and let the host map to the generated skill or agent name.

| Job | Claude Code | Codex | Gemini CLI | Antigravity CLI |
| --- | --- | --- | --- | --- |
| Set up this machine and self-check readiness | Skill `endor-agent-kit-setup` | Skill `endor-agent-kit-setup` | Skill `endor-agent-kit-setup` | Skill `endor-agent-kit-setup` |
| Triage Endor AI SAST findings | Agent `endor-labs-agent-kit:ai-sast-triage` | Skill `ai-sast-triage`, custom agent `endor-ai-sast-triage-agent` | Skill/subagent `ai-sast-triage` | Skill/subagent `ai-sast-triage` |
| Diagnose Endor setup, scan, or integration issues | Agent `endor-labs-agent-kit:endor-troubleshooter` | Skill `endor-troubleshooter`, custom agent `endor-troubleshooter-agent` | Skill/subagent `endor-troubleshooter` | Skill/subagent `endor-troubleshooter` |
| Assess GitHub onboarding gaps | Agent `endor-labs-agent-kit:probe-droid` | Skill `probe-droid`, custom agent `endor-probe-droid-agent` | Skill/subagent `probe-droid` | Skill/subagent `probe-droid` |
| Find safe SCA remediation paths | Agent `endor-labs-agent-kit:sca-remediation` | Skill `sca-remediation`, custom agent `endor-sca-remediation-agent` | Skill/subagent `sca-remediation` | Skill/subagent `sca-remediation` |
| Use Claude-only read-only package and dependency helpers | Agents `dependency-decision-helper`, `package-risk-summary`, `repository-dependency-reviewer`, `remediation-planner`, `upgrade-impact-analysis`, `vulnerability-explainer` | Not packaged in v1 | Not packaged in v1 | Not packaged in v1 |

The legacy `endor-setup` skill remains at `skills/endor-setup/SKILL.md` for
the existing setup plugin and Cursor compatibility.

## Boundaries And Rules

- Always preserve the generated recipe safety contract, approval gates, and evidence requirements.
- Always treat setup as readiness and configuration guidance; setup must not run scans or mutate repositories.
- Always report namespace, authentication, MCP, `endorctl`, `gh`, or toolchain gaps before live Endor work.
- Never print, persist, or copy secret values; report credential presence only by variable or key name.
- Never run `endorctl host-check` from setup or generated plugin guidance.
- Never auto-install `gh`, language runtimes, or package managers in v1.
- Never claim a file edit, branch push, PR/MR, ticket, policy write, or approval unless the host or adapter returned evidence.

## Agent Catalog

Generated Agent Kit package artifacts are checked in under `plugins/` so users
can install or validate packages without running the Agent Kit builder. The
source recipes live in `endorlabs/endor-labs-agent-kit/source/agents/` and are
the maintainer-facing source of truth.

| Agent | Use it when you want to... | Claude Code plugin | Codex plugin | Gemini plugin | Antigravity plugin |
| --- | --- | --- | --- | --- | --- |
| AI SAST Triage | Triage Endor AI SAST findings, use exploit and remediation context, and open requested change requests | `plugins/claude/endor-labs-agent-kit/agents/ai-sast-triage.md` | `plugins/codex/endor-labs-agent-kit/skills/ai-sast-triage/` | `plugins/gemini/endor-labs-agent-kit/skills/ai-sast-triage/` | `plugins/antigravity/endor-labs-agent-kit/skills/ai-sast-triage/` |
| Dependency Decision Helper | Decide whether to add, upgrade to, or keep a specific package version | `plugins/claude/endor-labs-agent-kit/agents/dependency-decision-helper.md` | - | - | - |
| Endor Labs Package Risk Summary | Summarize the risk profile of a specific package version | `plugins/claude/endor-labs-agent-kit/agents/package-risk-summary.md` | - | - | - |
| Endor Labs Repository Dependency Reviewer | Review local dependency manifests with read-only file inspection and Endor evidence | `plugins/claude/endor-labs-agent-kit/agents/repository-dependency-reviewer.md` | - | - | - |
| Endor Labs Upgrade Impact Analysis | Analyze Endor platform upgrade impact with VersionUpgrade, CIA, findings, and manifest context | `plugins/claude/endor-labs-agent-kit/agents/upgrade-impact-analysis.md` | - | - | - |
| Endor Labs Vulnerability Explainer | Understand a specific CVE, GHSA, or Endor vulnerability and what to do next | `plugins/claude/endor-labs-agent-kit/agents/vulnerability-explainer.md` | - | - | - |
| Endor Troubleshooter | Diagnose Endor Labs errors, warnings, scan failures, slow scans, missing integrations, SSO, containers, policy, and reachability issues | `plugins/claude/endor-labs-agent-kit/agents/endor-troubleshooter.md` | `plugins/codex/endor-labs-agent-kit/skills/endor-troubleshooter/` | `plugins/gemini/endor-labs-agent-kit/skills/endor-troubleshooter/` | `plugins/antigravity/endor-labs-agent-kit/skills/endor-troubleshooter/` |
| Probe Droid | Probe GitHub.com onboarding gaps and prescribe Endor scan profiles, toolchains, package integrations, and reachability setup | `plugins/claude/endor-labs-agent-kit/agents/probe-droid.md` | `plugins/codex/endor-labs-agent-kit/skills/probe-droid/` | `plugins/gemini/endor-labs-agent-kit/skills/probe-droid/` | `plugins/antigravity/endor-labs-agent-kit/skills/probe-droid/` |
| Remediation Planner | Preview safe dependency remediation options without opening PRs | `plugins/claude/endor-labs-agent-kit/agents/remediation-planner.md` | - | - | - |
| SCA Remediation | Remediate dependency vulnerabilities with Endor SCA findings, UIA evidence, low-risk PR lanes, deterministic risk decisions, validation, and approved PR/MR creation | `plugins/claude/endor-labs-agent-kit/agents/sca-remediation.md` | `plugins/codex/endor-labs-agent-kit/skills/sca-remediation/` | `plugins/gemini/endor-labs-agent-kit/skills/sca-remediation/` | `plugins/antigravity/endor-labs-agent-kit/skills/sca-remediation/` |

## Which Directory Do I Use?

| Goal | Start Here | You Do Not Need |
| --- | --- | --- |
| Install the Claude Code Agent Kit plugin package | `plugins/claude/endor-labs-agent-kit/README.md` | Agent Kit source recipes, compiler code, or tests |
| Install the Codex Agent Kit plugin package locally | `plugins/codex/endor-labs-agent-kit/README.md` | Cursor plugin files or legacy setup package scripts |
| Install the Gemini CLI Agent Kit extension locally | `plugins/gemini/endor-labs-agent-kit/README.md` | Cursor plugin files or legacy setup package scripts |
| Install the Antigravity CLI Agent Kit plugin locally | `plugins/antigravity/endor-labs-agent-kit/README.md` | Cursor plugin files or legacy setup package scripts |
| Use the legacy Endor setup plugin | `skills/endor-setup/SKILL.md` | Generated Agent Kit packages |
| Validate the existing Cursor plugin | `.cursor-plugin/` and `skills/endor-setup/` | Generated Agent Kit packages |
| Modify or contribute an Agent Kit workflow | `endorlabs/endor-labs-agent-kit/source/agents/<agent>/` | Generated files in this distribution repo as the first edit |

## Cursor Compatibility

The existing Cursor plugin depends on the current root setup skill and Cursor
metadata:

```text
.cursor-plugin/
skills/endor-setup/
assets/logo.svg
```

Do not move, rename, or rewrite those files when syncing Agent Kit packages.
Generated Agent Kit content should live under `plugins/` unless Cursor support
is intentionally redesigned and validated separately.

The Cursor plugin is not part of the Agent Kit v1 package migration. Treat it
as a compatibility surface: validate that it still sees `endor-setup`, but do
not add generated Agent Kit agents to Cursor in this repo until Cursor support
has its own design and acceptance tests.

## Supported Hosts

| Host | Current distribution path | Typical install target |
| --- | --- | --- |
| Claude Code | `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`, `plugins/claude/endor-labs-agent-kit/` | Published `endorlabs` marketplace with `ai-plugins@endorlabs` and `endor-labs-agent-kit@endorlabs` |
| Cursor | `.cursor-plugin/`, `skills/endor-setup/` | Existing Cursor plugin path, unchanged |
| Codex | `plugins/codex/endor-labs-agent-kit/` | Local Codex plugin validation; publication wiring remains staged in v1 |
| Gemini | `gemini-extension.json`, `plugins/gemini/endor-labs-agent-kit/` | Root legacy skill extension remains; generated Gemini package is staged until provider-specific install behavior is verified |
| Antigravity | `plugins/antigravity/endor-labs-agent-kit/` | Local Antigravity plugin validation and install from the generated plugin directory |
| Generic skill-compatible hosts | `skills/endor-setup/` | Existing setup-skill install path |

## Already Have Your Own Tech Stack Or Workflows Wired?

Use the portable bundles in `endorlabs/endor-labs-agent-kit/portable/` when
your organization already has an agent runtime, repository workflow, ticketing
workflow, approval system, credential controls, and audit pipeline.

This distribution repo does not currently stage portable bundles. It stages
provider plugin packages. Portable integrations should be sourced from the
Agent Kit source repository so runtime adapters, approval controls, and output
contracts are reviewed together.

## MCP Usage

MCP is not used by the mutating remediation workflows. AI SAST Triage, SCA
Remediation, Remediation Planner, Upgrade Impact Analysis, Probe Droid, and
the Codex skills use documented Endor API or `endorctl api` paths instead.

MCP remains relevant only where the current public recipe still depends on
Endor package/vulnerability lookup tools that do not yet have an `endorctl api`
contract in the Agent Kit:

| Agent | MCP use | Non-MCP path in same artifact |
| --- | --- | --- |
| Dependency Decision Helper | Package risk, vulnerability list, and vulnerability enrichment. | `endorctl api` for package scores, license, and similar-package signals. |
| Endor Labs Package Risk Summary | Package risk, vulnerability list, and vulnerability enrichment. | `endorctl api` for package scores, license, and similar-package signals. |
| Endor Labs Repository Dependency Reviewer | Per-dependency risk and vulnerability checks after local read-only manifest inspection. | None in v0. |
| Endor Labs Vulnerability Explainer | Vulnerability detail lookup. | None in v0. |

If MCP is unavailable, those agents must record the missing signal in
`data_gaps` rather than blocking install or fabricating evidence.

## Plugin Packaging Route

This repo is a distribution target, not the Agent Kit builder.

Agent Kit package generation happens in `endorlabs/endor-labs-agent-kit`:

```bash
endor-agent-kit publish source/agents/*/recipe.yaml --dest . --prune --include-plugins
```

After generation, sync the generated `plugins/` tree into this repo. The
current staged packages include:

- `plugins/claude/endor-labs-agent-kit/`: Claude Code plugin agents, setup
  skill, and plugin manifest.
- `plugins/codex/endor-labs-agent-kit/`: Codex plugin skills, bundled
  custom-agent TOML files, setup skill, installer script, and Codex metadata.
- `plugins/gemini/endor-labs-agent-kit/`: Gemini CLI extension with setup
  skill, Gemini workflow skills, preview subagents, minimal context, and a
  generated release archive at `plugins/gemini/endor-labs-agent-kit.zip`.
- `plugins/antigravity/endor-labs-agent-kit/`: Antigravity CLI plugin with
  setup skill, Antigravity workflow skills, subagents, minimal assets, and a
  root `plugin.json`.

All generated plugin packages preserve the same recipe source, action
metadata, and approval gates as the Agent Kit source catalog.

## Release Checklist

Before publishing or submitting changes from this repository:

```bash
python3 scripts/quick_validate.py skills/endor-setup
claude plugin validate .
claude plugin validate plugins/claude/endor-labs-agent-kit
python3 /mnt/c/Users/mbrow/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/codex/endor-labs-agent-kit
unzip -t plugins/gemini/endor-labs-agent-kit.zip
/home/mbrown/.local/bin/antigravity plugin validate plugins/antigravity/endor-labs-agent-kit
git diff --check
git diff -- .cursor-plugin skills/endor-setup assets/logo.svg
```

Expected Cursor check result: no diff for `.cursor-plugin/`,
`skills/endor-setup/`, or `assets/logo.svg` unless a Cursor-specific release
explicitly scopes and validates that change.

For generated package drift, compare this repo against the Agent Kit source
repo:

```bash
diff -qr /path/to/endor-labs-agent-kit/plugins ./plugins
```

## Configure Endor Access

| Access path | Used by | Notes |
| --- | --- | --- |
| Endor MCP | Agents whose generated artifact declares an MCP server | Configure it through the target host's MCP mechanism only when the selected agent requires it. |
| `endorctl api` or direct Endor API | Agents that need tenant, project, finding, or policy data without MCP | The generated prompts constrain commands to documented lookups and writes. Agent package READMEs link setup guidance when needed. |
| GitHub read-only inventory credentials | Probe Droid | Required when the agent compares GitHub.com repository inventory with Endor projects without cloning or mutating repositories. |
| Git and source-provider credentials | Mutating Claude Code agents such as AI SAST Triage and SCA Remediation | Required when the agent is expected to apply patches, open change requests, read PR/MR approval evidence, or post PR/MR comments. |
| Codex terminal and file-editing tools | Codex skills for mutating agents such as AI SAST Triage and SCA Remediation | The skill keeps file edits, branch pushes, PR/MR creation, PR/MR comments, and Endor policy writes behind separate approval gates. |
| Endor policy-write access | AI SAST Triage standalone exceptions | Required only when a verified AppSec PR/MR approval should create a scoped Endor exception policy. The agent must show the policy spec and ask for confirmation before writing. |

## Example Prompts

Claude Code plugin agents:

```text
@agent-endor-labs-agent-kit:ai-sast-triage triage AI SAST findings for this repository
@agent-endor-labs-agent-kit:endor-troubleshooter diagnose this Endor scan failure from redacted error text and read-only tenant evidence
@agent-endor-labs-agent-kit:probe-droid probe GitHub org <org> for Endor monitored-branch onboarding gaps and setup prescriptions
@agent-endor-labs-agent-kit:sca-remediation check this repository for P0 SCA findings I can start remediating
@agent-endor-labs-agent-kit:upgrade-impact-analysis show the safest upgrade path for repository <owner>/<repo> package lodash
```

Codex plugin skills:

```text
Use the endor-agent-kit-setup skill to check Endor Agent Kit readiness.
Use the ai-sast-triage skill to triage AI SAST findings for this repository.
Use the endor-troubleshooter skill to diagnose this Endor issue from redacted error text and read-only tenant evidence.
Use the probe-droid skill to probe GitHub org <org> for Endor monitored-branch onboarding gaps and setup prescriptions.
Use the sca-remediation skill to check this repository for P0 SCA findings I can start remediating.
```

Legacy setup skill:

```text
Set up endorctl and authenticate with Endor Labs.
Switch to namespace <namespace>.
Re-authenticate endorctl with a different account.
```

## Output Contract

Generated Agent Kit agents return concise prose plus a JSON block. The exact
schema depends on the agent. If a signal is unavailable because of setup,
authentication, account tier, or tooling, agents record that in `data_gaps`
instead of inventing evidence.

Mechanical output validators live in the Agent Kit source repository. Use that
repo for `endor-agent-kit validate-*`, render, lint, and `check-install`
commands. This distribution repo should carry generated package artifacts, not
the builder CLI.

For `sca-remediation`, keep the three remediation lanes distinct:

- P0/exploited remediation candidates: rank reachable or exploited critical/high findings and require UIA evidence before naming a best fix.
- Other non-breaking low-risk UIA-backed PRs: list only low-risk, CIA-clean recommendations with zero introduced findings and enough repo metadata to open a PR/MR.
- Risky or indeterminate upgrades: use `risk_decision` from Endor evidence plus local source usage before applying or opening a change request.

Validation commands must come from the repository's actual manifest and
package-manager layout; the agent must not assume Java, Maven, npm, Python,
Go, .NET, Ruby, Rust, or any other ecosystem from prior runs.

## Safety Model

Most generated Agent Kit agents are read-only. Recipes in the Agent Kit source
repo declare safety class and host capabilities explicitly.

Read-only agents do not:

- edit files
- create pull requests
- run scans
- dismiss findings
- create policies
- mutate Endor Labs state

Mutating agents are published only when their recipe declares the required host
capabilities. AI SAST Triage and SCA Remediation may fetch source context,
write patch files, run git/source-provider commands, and open a change request
when the user asks for that workflow and the target repository credentials are
available.

Setup is separate from remediation. Setup can guide installation,
authentication, namespace selection, and self-checks; setup does not run scans
or perform remediation actions.

## Contribute Or Change An Agent

Do not change generated Agent Kit behavior by editing files in this repository.

Change the Agent Kit source repository instead:

1. Edit `endorlabs/endor-labs-agent-kit/source/agents/<agent>/recipe.yaml`.
2. Edit the source instructions, evals, action contracts, and diagrams there.
3. Regenerate and validate the Agent Kit catalog there.
4. Sync the generated `plugins/` tree back into this distribution repo.
5. Verify this repo's Claude marketplace, legacy setup skill, Cursor no-diff
   invariant, Codex package, and Gemini archive.

## Repository Reference

### Layout

```text
.claude-plugin/
  marketplace.json
  plugin.json
.cursor-plugin/
  marketplace.json
  plugin.json
assets/
  logo.svg
skills/
  endor-setup/
    SKILL.md
plugins/
  README.md
  claude/
    .claude-plugin/marketplace.json
    endor-labs-agent-kit/
  codex/
    .agents/plugins/marketplace.json
    endor-labs-agent-kit/
  gemini/
    endor-labs-agent-kit/
    endor-labs-agent-kit.zip
scripts/
  package_skill.py
  quick_validate.py
gemini-extension.json
```

### Generated Package Records

The `plugins/` tree is copied from the Agent Kit source repo. Keep it
byte-for-byte comparable to `endorlabs/endor-labs-agent-kit/plugins` unless a release
explicitly documents why this distribution repo must diverge.

### Legacy Setup Skill

The root `skills/endor-setup/SKILL.md` is the existing setup skill used by the
legacy Claude plugin, Cursor plugin, Gemini root extension, and generic skill
install flows. It is not the same as generated
`plugins/*/endor-labs-agent-kit/skills/endor-agent-kit-setup/SKILL.md`.

## Release And License

This repository currently includes a `LICENSE` file and legacy plugin metadata
from the existing `ai-plugins` publication. Confirm final license and metadata
requirements for generated Agent Kit package publication before public release
or marketplace submission.

---
name: endor-upgrade-impact
description: "Use when user asks about upgrade impact, breaking changes, safe dependency versions, 'should I upgrade', or 'what should I upgrade'. Also use when user asks to analyze risk of upgrading a specific package, or wants Endor Labs upgrade recommendations."
---

# Endor Labs Upgrade Impact Analysis

Find safe dependency upgrades using pre-computed data from the Endor Labs platform — no scanning required.

## Prerequisites

- Endor Labs authenticated (run `/endor-setup` if not)

## Key Concepts

| Field | Meaning |
|-------|---------|
| `is_best` | Endor Labs' recommended upgrade — best balance of fixes vs. risk |
| `worth_it` | Whether the upgrade provides meaningful security improvement |
| `upgrade_risk` | LOW (safe), MEDIUM (review needed), HIGH (breaking code changes via call graphs) |
| `total_findings_fixed` | Vulnerability findings resolved by upgrading |
| `total_findings_introduced` | New findings introduced (e.g., from new transitive deps) |
| `cia_results` | Code-level breaking changes for HIGH-risk upgrades (fetched on demand) |

## Workflow

### Step 1: Resolve Namespace

Before making ANY `endorctl api` call, you MUST resolve the namespace.

```bash
export ENDOR_NAMESPACE="${ENDOR_NAMESPACE:-$(grep -E '^ENDOR_NAMESPACE:' ~/.endorctl/config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"')}"
echo "ENDOR_NAMESPACE=$ENDOR_NAMESPACE"
```

If empty, automatically run `/endor-setup` to authenticate and set the namespace.

### Step 2: Find the Project UUID

Get the git remote URL, then query for the project. **Only run this after Step 1 succeeds.**

```bash
GIT_URL=$(git remote get-url origin 2>/dev/null)
endorctl api list --resource Project -n $ENDOR_NAMESPACE \
  --filter "spec.git.http_clone_url=='$GIT_URL'" \
  --field-mask="uuid,meta.name" 2>&1 | tee /tmp/endor_list_project_output.txt
```

Run this command ONCE with the exact git remote URL. Do NOT retry with URL variations (removing `.git`, changing protocol, listing all projects, etc.). If the project is not found, see Error Handling.

### Step 3: Get Best Upgrade Recommendations

Query pre-computed safe upgrades. **Do NOT run a scan** — data is already available from prior scans.

```bash
endorctl api list -r VersionUpgrade -n $ENDOR_NAMESPACE \
  --filter="context.type==CONTEXT_TYPE_MAIN and spec.project_uuid==\"{PROJECT_UUID}\" and spec.upgrade_info.is_best==true and spec.upgrade_info.worth_it==true" \
  --field-mask="uuid,spec.name,spec.upgrade_info.is_best,spec.upgrade_info.is_latest,spec.upgrade_info.from_version,spec.upgrade_info.to_version,spec.upgrade_info.to_version_age_in_days,spec.upgrade_info.total_findings_fixed,spec.upgrade_info.total_findings_introduced,spec.upgrade_info.score_explanation,spec.upgrade_info.worth_it,spec.upgrade_info.upgrade_risk,spec.upgrade_info.direct_dependency_package" \
  --list-all 2>&1 | tee /tmp/endor_version_upgrade_output.txt
```

Always use `2>/dev/null` to prevent stderr from corrupting JSON output.

If user asked about a **specific package**, filter results to that package. If they asked generally ("what should I upgrade?"), present all.

If the VersionUpgrade API returns an empty response (no upgrades), say ONLY this exact message and nothing else: "No upgrade recommendations are available for this project at this moment." Do NOT add any explanation, speculation, bullet points, possible reasons, or follow-up suggestions. Just that one sentence and stop.

### Step 4: Present Results

Pick the best upgrade per package (most `total_findings_fixed`, lowest `upgrade_risk`). Present as:

- **Summary table**: Package, From, To, Findings Fixed, Risk, Best?, Latest?
- **Per-package details** (if few packages): findings fixed/introduced, risk, version age, score explanation
- **Recommendation by risk level**:
  - **LOW**: Safe to upgrade — provide the install command for the project's package manager
  - **MEDIUM**: Review changes carefully, test thoroughly before deploying
  - **HIGH**: Breaking code-level changes detected — offer to fetch CIA details (Step 4)

### Step 5: Evaluate High-Risk Upgrades (On Request Only)

Fetch CIA details only when the user asks to evaluate a HIGH-risk upgrade.

```bash
endorctl api list -r VersionUpgrade -n $ENDOR_NAMESPACE \
  --filter="context.type==CONTEXT_TYPE_MAIN and spec.project_uuid==\"{PROJECT_UUID}\" and uuid==\"{UUID}\"" \
  --field-mask="spec.upgrade_info.cia_results" 2>&1 | tee /tmp/endor_version_upgrade_output.txt
```

Summarize: API changes, removed functions, signature changes, behavioral changes. List specific action items and whether to proceed.

## Data Sources — Endor Labs Only

**CRITICAL: ALL upgrade/vulnerability data MUST come from the Endor Labs VersionUpgrade API or MCP tools. NEVER supplement with external sources** (package registries, GitHub, CVE databases, changelogs, blogs, etc.).

If data is unavailable, tell the user and suggest checking [app.endorlabs.com](https://app.endorlabs.com) directly.

## Error Handling

| Error | Action |
|-------|--------|
| License/permission error | Inform user: "Upgrade Impact Analysis requires Endor Labs **OSS Pro** license. Visit [app.endorlabs.com](https://app.endorlabs.com) or contact your administrator." |
| Project not found | Run endor scan to scan the project on the namespace, then run `/endor-upgrade-impact` again |
| Package not in results | Package may have no recommended upgrades or is already at the best version |
| Auth error | Run `/endor-setup` |

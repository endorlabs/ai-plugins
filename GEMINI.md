# Endor Labs Agent Kit Root Package

Use Endor Labs Agent Kit workflows only within their generated safety
contracts. If setup, authentication, namespace, Endor MCP, `endorctl`, `gh`, or
repository tooling is missing, use the `endor-agent-kit-setup` skill before
live Endor work.

User jobs mapped to root skills:

- Triage AI SAST findings: use skill `ai-sast-triage`.
- Diagnose Endor setup and scan issues: use skill `endor-troubleshooter`.
- Assess GitHub onboarding gaps: use skill `probe-droid`.
- Find safe SCA remediation paths: use skill `sca-remediation`.

Setup must not run scans, run `endorctl host-check`, edit shell profiles,
auto-install `gh`, install language tooling, or collect/write API secrets.

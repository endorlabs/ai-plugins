# Endor Labs Setup Skill

Endor Labs helps developers spend less time dealing with security issues and more time accelerating development through safe Open Source Software (OSS) adoption. Our Dependency Lifecycle Management™ Solution helps organizations maximize software reuse by enabling security and development teams to select, secure, and maintain OSS at scale.

The Endor Labs Setup Skill automates the installation, authentication, and namespace configuration of endorctl across multiple AI coding platforms. Once set up, endorctl is ready for security scans and other Endor Labs operations.

## Required Parameters and Pre-requisites

The following pre-requisites are required for the Endor Labs Setup Skill to successfully run:

- One of the following AI coding agents:
  - Claude Code
  - OpenCode
  - Cursor-cli
  - Codex
  - Other skill-compatible AI agents
- The skill must be able to authenticate to the Endor Labs API through either:
  - Browser/Google OAuth (Recommended)
  - Endor Labs API key and secret
- The Endor Labs namespace to authenticate against
- Access to the Endor Labs API
- Supported platforms: macOS (Intel & ARM), Linux, Windows


## Get Started

Choose one of the following ways to get started:


### Option 1: Install using the skills (recommended)

**Install skill dependency**

Install the [skills](https://www.npmjs.com/package/skills) dependency if not already installed:

```bash
npm install -g skills
```

**Add skill to agents**

Add the skill to OpenCode, Claude Code, Codex, Cursor, Cursor-cli and other agents:

```bash
npx skills add endorlabs/endor-skills
```

### Option 2: Build locally

**1. Build the Skill**

```bash
# Clone this repository
git clone <your-repo-url>
cd endor-skills

# Build the skill
chmod +x build.sh
./build.sh
```

This creates `endor-setup.skill` in the `dist/` directory.

**2. Install the Skill (for Claude Code)**

```bash
# Install globally (recommended)
mkdir -p ~/.claude/skills
unzip dist/endor-setup.skill -d ~/.claude/skills/endor-setup

# Or install for a specific project
mkdir -p <repo_path>/.claude/skills
unzip dist/endor-setup.skill -d <repo_path>/.claude/skills/endor-setup
```

**Install for other agents:** Follow your specific AI agent's skill installation documentation.

---

## Usage Examples

The skill responds to natural language requests.

**Example (using Claude Code):**

```bash
# Set up endorctl
claude "set up endorctl"

# Install and authenticate
claude "install endorctl and authenticate with Endor Labs"

# Change namespace
claude "switch to namespace my-company.my-project"

# Re-authenticate
claude "re-authenticate endorctl with a different account"
```
---

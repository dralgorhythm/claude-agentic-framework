# Claude Agentic Framework

A drop-in framework for optimized Claude Code workflows with specialized personas, reusable skills, and swarm coordination.

## Quick Start

### Option 1: Automated Installation (Recommended)

```bash
# Clone the framework
git clone https://github.com/anthropics/claude-agentic-framework.git

# Run the initialization script in your project directory
cd /path/to/your/project
/path/to/claude-agentic-framework/scripts/init-framework.sh .
```

The script will:
- Copy `.claude/`, `.devcontainer/`, `templates/`, `.gitattributes`, and `.mcp.json`
- Create `artifacts/` directory
- Optionally copy `.beads/` and `.serena/` configuration templates
- Create `CLAUDE.md` if it doesn't exist (won't overwrite existing files)
- Install hook dependencies automatically
- Prompt before overwriting any existing framework files

### Option 2: Manual Installation

```bash
# Clone as a starting point
git clone https://github.com/anthropics/claude-agentic-framework.git my-project

# OR copy into existing project
cp -r claude-agentic-framework/.claude your-project/
cp -r claude-agentic-framework/.devcontainer your-project/
cp -r claude-agentic-framework/templates your-project/
mkdir -p your-project/artifacts
cp claude-agentic-framework/.gitattributes your-project/
cp claude-agentic-framework/.mcp.json your-project/
cp claude-agentic-framework/CLAUDE.md your-project/

# Optional: Copy MCP server configurations
cp -r claude-agentic-framework/.beads your-project/
cp -r claude-agentic-framework/.serena your-project/

# Install hook dependencies
cd your-project/.claude/hooks && npm install
```

### Getting Started

After installation, start using slash commands to adopt specialized personas:

```
/architect           - System design and technical specs
/builder             - Code implementation
/product-manager     - Requirements and PRDs
```

## Post-Installation Checklist

First time using this framework? Complete these steps:

- [ ] **Customize CLAUDE.md** - Update project name, description, and team conventions
- [ ] **Review Tech Strategy** - Adjust `.claude/rules/tech-strategy.md` for your stack
- [ ] **Test a Persona** - Try `/architect design-topic` to verify setup
- [ ] **Initialize Beads** - Run `bd init` to enable AI-native issue tracking
- [ ] **Create First Artifact** - Use `/product-manager my-feature` to generate a PR-FAQ
- [ ] **Review Hooks** - Check `.claude/settings.json` to understand automation

Optional customizations:
- [ ] Add project-specific rules to `.claude/rules/`
- [ ] Create custom skills in `.claude/skills/`
- [ ] Extend personas with new commands in `.claude/commands/`

## Features

### 9 Specialized Personas

Access domain-expert personas via slash commands:

| Command | Persona | Best For |
|---------|---------|----------|
| `/architect` | Principal Architect | System design, API contracts, trade-off analysis |
| `/builder` | Software Engineer | Code implementation, debugging, TDD |
| `/product-manager` | Product Manager | PRDs, user stories, requirements |
| `/qa-engineer` | QA Engineer | Test strategy, automation, verification |
| `/reviewer` | Code Reviewer | Code review, security checks |
| `/refactoring-engineer` | Refactoring Engineer | Code cleanup, optimization |
| `/sre` | Site Reliability Engineer | Infrastructure, observability, incidents |
| `/security-auditor` | Security Auditor | Security review, threat modeling |
| `/ui-ux-designer` | UI/UX Designer | Interface design, accessibility |

### 50 Reusable Skills

Skills are model-invoked based on context (keywords, intent patterns):

**Architecture**: designing-systems, designing-apis, domain-driven-design, cloud-native-patterns, capacity-planning, defense-in-depth, writing-adrs

**Core Engineering**: implementing-code, debugging, refactoring-code, optimizing-code, testing, test-driven-development, dependency-management, data-management

**Languages**: typescript, python, go, rust, swift, kotlin, bash, terraform

**Product**: writing-prds, decomposing-tasks, estimating-work, requirements-analysis, documentation, execution-roadmaps, brainstorming, agile-methodology

**Operations**: infrastructure, observability, incident-management, chaos-engineering, deploy-railway, swarm-coordination, beads-workflow

**Security**: application-security, threat-modeling, security-review, compliance, identity-access

**Design**: interface-design, accessibility, visual-assets, design-systems

### 8 Swarm Workers

Lightweight agents for parallel task execution with slim context:

| Worker | Model | Purpose |
|--------|-------|---------|
| `worker-explorer` | Haiku | Fast codebase search |
| `worker-builder` | Sonnet | Implementation tasks |
| `worker-reviewer` | Sonnet | Code review |
| `worker-tester` | Sonnet | Test writing |
| `worker-researcher` | Sonnet | Web research, API docs |
| `worker-architect` | Opus | Complex design decisions |
| `worker-security` | Sonnet | Vulnerability analysis |
| `worker-refactor` | Sonnet | Code cleanup, optimization |

### 8 Automated Hooks

| Event | Hook | Purpose |
|-------|------|---------|
| SessionStart | session-start-loader | Load Beads status, swarm state |
| UserPromptSubmit | skill-activation-prompt | Auto-suggest relevant skills |
| PreToolUse | pre-tool-use-validator | File locking, secret detection |
| PreToolUse | pre-commit-verification | Run tests/linting before commits |
| PostToolUse | post-tool-use-tracker | File modification log |
| PostToolUse | post-tool-use-beads-tracker | Beads integration |
| Stop | stop-validator | Release locks, sync state |
| SubagentStop | subagent-stop-validator | Log subagent completion |

## Directory Structure

```
your-project/
├── CLAUDE.md                    # Project memory (customize this!)
├── .claude/
│   ├── settings.json            # Claude Code settings & hooks
│   ├── rules/                   # Auto-loaded coding standards
│   │   ├── core-directives.md   # Critical development rules
│   │   ├── code-quality.md      # SOLID, DRY, testing
│   │   ├── security.md          # Security requirements
│   │   ├── tech-strategy.md     # Technology golden paths
│   │   └── swarm-workers.md     # Multi-agent guidelines
│   ├── commands/                # Slash commands (personas)
│   │   └── [persona].md         # /persona command
│   ├── agents/                  # Swarm worker definitions
│   │   └── worker-[type].md     # Lightweight workers
│   ├── hooks/                   # Automation scripts
│   │   ├── *.sh                 # Hook shell scripts
│   │   └── *.ts                 # TypeScript processors
│   └── skills/                  # Model-invoked workflows
│       ├── skill-rules.json     # Skill activation triggers
│       ├── architecture/
│       ├── core-engineering/
│       ├── design/
│       ├── languages/
│       ├── operations/
│       ├── product/
│       └── security/
├── artifacts/                   # Generated planning documents
├── templates/                   # Templates for extending
│   ├── command.template.md      # Persona command template
│   ├── skill.template.md        # Skill template
│   ├── rule.template.md         # Rule template
│   ├── agent.template.md        # Swarm worker template
│   ├── hook.template.sh         # Hook script template
│   └── artifacts/               # Artifact templates
│       ├── pr_faq.template.md   # Vision (Working Backwards)
│       ├── prd.template.md      # Product Requirements
│       ├── adr.template.md      # Architecture Decision Record
│       ├── design_spec.template.md
│       ├── roadmap.template.md
│       ├── plan.template.md
│       ├── system_design.template.md
│       ├── security_audit.template.md
│       └── postmortem.template.md  # Incident Post-Mortems
├── .devcontainer/               # Dev container setup
│   └── Dockerfile               # Includes Claude & Beads
├── .beads/                      # Beads issue tracking (optional)
│   └── config.yaml              # Beads configuration template
└── .serena/                     # Serena MCP server (optional)
    └── project.yml              # Language server configuration
```

## Core Directives

This framework enforces key development practices:

1. **Trunk-Based Development**: Work on branches, never commit to main
2. **Test-Driven Design**: Write tests first, run before commit
3. **Single Source of Truth**: Tech Strategy defines all technology choices
4. **Skill-First**: Use defined skills over ad-hoc generation
5. **Artifact Storage**: All planning docs go in `./artifacts/`

## Artifact Naming

| Type | Pattern | Example | Template |
|------|---------|---------|----------|
| Vision (PR-FAQ) | `pr_faq_[feature].md` | `pr_faq_authentication.md` | `templates/artifacts/pr_faq.template.md` |
| Requirements | `prd_[feature].md` | `prd_authentication.md` | `templates/artifacts/prd.template.md` |
| Architecture | `adr_[topic].md` | `adr_database_choice.md` | `templates/artifacts/adr.template.md` |
| System Design | `system_design_[component].md` | `system_design_api.md` | `templates/artifacts/system_design.template.md` |
| Visual Design | `design_spec_[component].md` | `design_spec_login.md` | `templates/artifacts/design_spec.template.md` |
| Roadmap | `roadmap_[project].md` | `roadmap_mvp.md` | `templates/artifacts/roadmap.template.md` |
| Plan | `plan_[task].md` | `plan_api_refactor.md` | `templates/artifacts/plan.template.md` |
| Security Audit | `security_audit_[date].md` | `security_audit_2025-01.md` | `templates/artifacts/security_audit.template.md` |
| Post-Mortem | `postmortem_[incident-id].md` | `postmortem_inc-2025-001.md` | `templates/artifacts/postmortem.template.md` |

All artifacts are stored in `./artifacts/` and created from templates during persona handoffs.

## Customization

### Adding a New Skill

1. Create directory: `.claude/skills/[domain]/[skill-name]/`
2. Add `SKILL.md` with proper frontmatter:

```yaml
---
name: skill-name          # Must match directory name
description: What it does. Use when [trigger phrases].
allowed-tools: Read, Write, Edit
---
```

3. Add entry to `.claude/skills/skill-rules.json` for auto-activation

See `templates/skill.template.md` for the full format.

### Skill Activation System

Skills are automatically suggested based on user prompts via `.claude/skills/skill-rules.json`. The `UserPromptSubmit` hook analyzes each prompt and suggests relevant skills based on matching triggers.

#### Trigger Types

| Type | Description | Example |
|------|-------------|---------|
| `keywords` | Exact word matches (case-insensitive) | `["deploy", "infrastructure"]` |
| `intent_patterns` | Regex patterns for intent detection | `["how (do\|can) I deploy"]` |
| `file_patterns` | File path patterns that activate skill | `["*.tf", "terraform/**"]` |

#### Priority Levels

- `critical` - Always shown first, urgent relevance
- `high` - Strong match, prominently displayed
- `medium` - Moderate relevance
- `low` - Informational, shown last

#### How It Works

1. User submits a prompt
2. `UserPromptSubmit` hook processes `.claude/skills/skill-rules.json`
3. Each skill's triggers are evaluated:
   - **keywords**: Checked against prompt text (case-insensitive word matching)
   - **intent_patterns**: Regex matched against prompt
   - **file_patterns**: Matched against recently modified files
4. Matching skills are sorted by priority and appended to the prompt
5. Claude receives the prompt with suggested skills as additional context

#### Adding a New Skill Trigger

After creating a skill (see "Adding a New Skill" above), register it in `skill-rules.json`:

```json
{
  "name": "my-skill",
  "path": ".claude/skills/category/my-skill/SKILL.md",
  "description": "What this skill does",
  "triggers": {
    "keywords": ["keyword1", "keyword2"],
    "intent_patterns": ["how to do X", "need to (setup|configure)"],
    "file_patterns": ["*.xyz", "config/**"]
  },
  "priority": "medium"
}
```

**Example**: A "deploy-railway" skill might use:
- **keywords**: `["deploy", "railway", "hosting"]`
- **intent_patterns**: `["how (do|can) (I|we) deploy", "need to (host|publish)"]`
- **file_patterns**: `["railway.json", "railway.toml"]`
- **priority**: `"high"`

This ensures the skill is suggested whenever deployment intent is detected or Railway config files are being edited.

### Adding a New Command

1. Create file: `.claude/commands/[persona].md`
2. Add required frontmatter:

```yaml
---
description: Short description for autocomplete
allowed-tools: Read, Write, Edit, Bash
argument-hint: [task-description]
---
```

3. Define identity, constraints, and handoff protocol

See `templates/command.template.md` for the full format.

### Adding a New Rule

1. Create file: `.claude/rules/[rule-name].md`
2. Rules are auto-loaded as project context (no conditional loading)
3. Keep rules concise to minimize token usage

See `templates/rule.template.md` for the format.

### Adding a New Agent (Swarm Worker)

1. Create file: `.claude/agents/worker-[type].md`
2. Add required frontmatter:

```yaml
---
name: worker-[type]
description: Brief description for Task tool selection
tools: Read, Glob, Grep
model: haiku
---
```

3. Choose model based on task complexity:
   - `haiku`: Fast exploration, read-only searches
   - `sonnet`: Implementation, review, testing

See `templates/agent.template.md` for the full format.

### Adding a New Hook

1. Create file: `.claude/hooks/[hook-name].sh`
2. Make it executable: `chmod +x .claude/hooks/[hook-name].sh`
3. Register in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/[hook-name].sh",
        "timeout": 5
      }]
    }]
  }
}
```

4. Hook events and their purposes:

| Event | When Triggered | Common Uses |
|-------|----------------|-------------|
| `SessionStart` | Session begins/resumes | Load state, check prerequisites |
| `UserPromptSubmit` | User sends message | Add context, suggest skills |
| `PreToolUse` | Before tool executes | Block actions, validate input |
| `PostToolUse` | After tool completes | Track changes, sync state |
| `Stop` | Session ends | Cleanup, save state |
| `SubagentStop` | Subagent completes | Log results, coordinate swarm |

See `templates/hook.template.sh` for input/output schemas.

## Environment Variables

The framework uses these environment variables (automatically set by Claude Code):

| Variable | Description | Used By |
|----------|-------------|---------|
| `CLAUDE_PROJECT_DIR` | Root directory of the project | All hooks, skill activation |
| `CLAUDE_SESSION_ID` | Current session identifier | Session hooks |
| `CLAUDE_MODEL` | Active model name | Hooks for model-specific behavior |

### Hook Input Variables

Hooks receive JSON input via stdin with:
- `session_id` - Current session
- `transcript_path` - Path to conversation transcript
- `cwd` - Current working directory
- `allowed_tools` - List of enabled tools
- `prompt` - User's input (for UserPromptSubmit hooks)
- `tool_name`, `tool_input` - Tool details (for PreToolUse/PostToolUse)

## Tech Strategy

This framework includes an opinionated tech strategy (see `.claude/rules/tech-strategy.md`):

| Domain | Default Choice |
|--------|----------------|
| TypeScript Runtime | Node.js LTS / Bun |
| TypeScript Build | Vite |
| TypeScript Lint | Biome |
| TypeScript Test | Vitest |
| Python Runtime | Python 3.13+ |
| Python Server | Granian |
| Python Framework | Litestar |
| Python Lint | Ruff |
| Go Runtime | Go 1.25+ with PGO |
| Go Framework | Gin / Chi |
| Rust Edition | 2024 |
| Rust Framework | Axum |
| Swift Runtime | Swift 5.10+ / Xcode 16+ |
| Swift UI | SwiftUI |
| Kotlin Runtime | Kotlin 2.0+ / JDK 17 |
| Kotlin UI | Jetpack Compose |
| Database | PostgreSQL |
| IaC | Terraform |
| Observability | OpenTelemetry |

Customize the tech strategy for your organization's needs.

## Beads Integration

This framework integrates with [Beads](https://github.com/steveyegge/beads) for AI-native issue tracking.

### Installation

```bash
# Install Beads
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# Initialize with protected branch workflow (recommended for teams)
bd init --branch beads-metadata

# Configure project settings
bd config set sync.branch "beads-metadata"
bd config set sync.require_confirmation_on_mass_delete "true"

# Start daemon
bd daemon start --auto-commit
```

### Daily Commands

```bash
# Create issues
bd create "Implement feature X"

# Find ready work
bd ready

# Claim work
bd update <id> --status in_progress

# Complete work
bd update <id> --status done

# Sync with team
bd sync

# Health check (run daily)
bd doctor
```

### Multi-Agent Workflow

Agents coordinate via status transitions:
1. Query ready work: `bd ready`
2. Claim issue: `bd update <id> --status in_progress`
3. Work on task
4. Complete: `bd update <id> --status done`
5. Sync: `bd sync`

Hooks automatically sync with Beads for swarm coordination.
# Web Agency Agents - AI Development Team

A collection of **38 specialized AI agent prompts** that work together as a coordinated development team. Each agent has deep domain expertise, structured handoffs, and mandatory human approval gates.

**Platform-agnostic** -- works with Claude Code, Warp, Cursor, Windsurf, or any AI coding assistant that supports custom prompts.

> **Token notice:** Multi-agent orchestration can consume 10-50k tokens per complex feature. Monitor your usage.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Usage Scenarios (Step-by-Step)](#usage-scenarios-step-by-step)
- [Agent Catalog](#agent-catalog)
- [How It Works](#how-it-works)
- [Creating Custom Agents](#creating-custom-agents)
- [Community](#community)

---

## Quick Start

### Prerequisites
- An AI coding assistant (Claude Code, [Warp](https://www.warp.dev), Cursor, Windsurf, etc.)
- Active project directory with your codebase
- **Optional**: [Context7 MCP](docs/dependencies.md) for enhanced documentation access

### Clone the Repository
```bash
git clone https://github.com/ps-prabhjyotsingh/WebAgencyAgents.git
```

---

### Setup by Platform

#### Claude Code

Claude Code natively supports agent files in `~/.claude/agents/`.

**Option A: Symlink (recommended -- auto-updates)**

macOS/Linux:
```bash
mkdir -p ~/.claude/agents
ln -sf "$(pwd)/WebAgencyAgents/agents/" ~/.claude/agents/WebAgencyAgents
```

Windows (PowerShell):
```powershell
New-Item -Path "$env:USERPROFILE\.claude\agents" -ItemType Directory -Force
cmd /c mklink /D "$env:USERPROFILE\.claude\agents\WebAgencyAgents" "$(Get-Location)\WebAgencyAgents\agents"
```

**Option B: Copy (static)**
```bash
mkdir -p ~/.claude/agents
cp -r WebAgencyAgents/agents ~/.claude/agents/WebAgencyAgents
```

Verify:
```bash
claude /agents
# Should show all 38 agents
```

#### Warp

Add agents as [Rules](https://docs.warp.dev/agents/rules):
1. Open Warp settings > Rules
2. Copy the markdown content (below the YAML frontmatter `---`) from any agent file
3. Paste as a new rule

#### Cursor

Add agents to `.cursor/rules/`:
```bash
mkdir -p .cursor/rules
cp WebAgencyAgents/agents/orchestrators/*.md .cursor/rules/
cp WebAgencyAgents/agents/core/*.md .cursor/rules/
# Add framework-specific agents as needed
```

#### Windsurf

Add to your project rules or global AI instructions:
1. Open Settings > AI > Custom Instructions
2. Copy the markdown content from the agent file(s) you need
3. Paste as custom instructions

#### Any Other Platform

Paste agent content as a system prompt, custom instruction, or rules file wherever your platform accepts them. The agents are plain Markdown -- they work anywhere.

---

## Usage Scenarios (Step-by-Step)

### Scenario 1: Build a New Project from Requirements

**Pipeline:** `requirements-clarifier` -> `project-builder` -> specialists -> `code-reviewer` -> fix issues -> present report (per phase)

| Step | Action | Agent Used |
|------|--------|------------|
| 1 | Create `requirements.md` in your project root | You |
| 2 | "Analyze my requirements and create an execution plan" | `requirements-clarifier` |
| 3 | Review and approve the execution plan | You (approval gate) |
| 4 | "Build this project following the approved plan" | `project-builder` |
| 5 | Project-builder delegates to specialists per phase | Auto-routed |
| 5a | **Code review after each phase** — fix all Critical/Major issues | `code-reviewer` (enforced) |
| 5b | **Review report presented to you** | Auto |
| 6 | Approve each phase (schema, backend, frontend, tests) | You (approval gates) |
| 7 | Final code review | `code-reviewer` |

**Example invocation (Claude Code):**
```
claude "use @agent-requirements-clarifier to analyze requirements.md"
# ... approve plan ...
claude "use @agent-project-builder to build the project from the approved plan"
```

**Example invocation (other platforms):**
```
Analyze my requirements.md using the requirements-clarifier workflow.
Then build the project using the project-builder phased approach.
```

---

### Scenario 2: Add a Feature to an Existing Project

**Pipeline:** `tech-lead-orchestrator` -> specialists -> `code-reviewer` -> fix issues -> present report (per round) -> `testing-specialist` -> `code-reviewer` -> `branch-finisher`

| Step | Action | Agent Used |
|------|--------|------------|
| 1 | Describe the feature you want | You |
| 2 | "Analyze this feature request and create a task plan" | `tech-lead-orchestrator` |
| 3 | Review the agent routing map and task assignments | You (approval gate) |
| 4 | Execute tasks in the order specified by tech-lead | Assigned specialists |
| 4a | **Code review after each round** — fix all Critical/Major issues | `code-reviewer` (enforced) |
| 4b | **Review report presented to you** | Auto |
| 5 | Run tests for the feature | `testing-specialist` |
| 5a | **Code review after tests** — fix all Critical/Major issues | `code-reviewer` (enforced) |
| 5b | **Review report presented to you** | Auto |
| 6 | Finish the branch | `branch-finisher` |

**Example invocation:**
```
claude "use @agent-tech-lead-orchestrator to plan adding a user authentication system"
```

---

### Scenario 3: Debug a Bug

**Pipeline:** `systematic-debugger` -> fix with test -> `code-reviewer` -> fix issues -> present report

| Step | Action | Agent Used |
|------|--------|------------|
| 1 | Describe the bug or paste the error | You |
| 2 | "Debug this issue systematically" | `systematic-debugger` |
| 3 | Agent investigates (Phase 1-3: gather evidence, analyze patterns, form hypothesis) | `systematic-debugger` |
| 4 | Review root cause analysis and proposed fix | You (approval gate) |
| 5 | Agent implements the fix with a failing test first | `systematic-debugger` |
| 6 | **Code review of the fix** — fix all Critical/Major issues | `code-reviewer` (enforced) |
| 7 | **Review report presented to you** | Auto |

**Example invocation:**
```
claude "use @agent-systematic-debugger to investigate why user login returns 500 errors"
```

---

### Scenario 4: Code Review

**Pipeline:** `code-reviewer` (2-stage review)

| Step | Action | Agent Used |
|------|--------|------------|
| 1 | "Review the code changes on this branch" | `code-reviewer` |
| 2 | Stage 1: Spec compliance check | `code-reviewer` |
| 3 | Stage 2: Code quality, security, performance | `code-reviewer` |
| 4 | Report saved to `.code-reviews/` | Automatic |

**Example invocation:**
```
claude "use @agent-code-reviewer to review the current branch changes"
```

---

### Scenario 5: Explore an Unfamiliar Codebase

**Pipeline:** `code-archaeologist` -> `team-configurator`

| Step | Action | Agent Used |
|------|--------|------------|
| 1 | "Analyze this codebase and produce a full assessment" | `code-archaeologist` |
| 2 | Review the architecture report, risks, and recommendations | You |
| 3 | "Configure the AI team for this project" | `team-configurator` |
| 4 | Team configurator updates project config with optimal agent mappings | Automatic |

**Example invocation:**
```
claude "use @agent-code-archaeologist to explore and document this codebase"
claude "use @agent-team-configurator to set up the AI team"
```

---

### Scenario 6: Performance Optimization

**Pipeline:** `performance-optimizer`

| Step | Action | Agent Used |
|------|--------|------------|
| 1 | "Profile and optimize the slow endpoints" | `performance-optimizer` |
| 2 | Agent baselines metrics, profiles, fixes top bottlenecks | `performance-optimizer` |
| 3 | Review before/after metrics report | You |

---

### Scenario 7: Finish a Branch (Merge/PR/Discard)

**Pipeline:** `branch-finisher`

| Step | Action | Agent Used |
|------|--------|------------|
| 1 | "Finish this branch" | `branch-finisher` |
| 2 | Agent verifies all tests pass | `branch-finisher` |
| 3 | Choose: merge locally, create PR, keep, or discard | You (approval gate) |
| 4 | Agent executes your choice | `branch-finisher` |

---

## Agent Catalog

### Orchestrators (5 agents)
| Agent | Purpose |
|-------|---------|
| [tech-lead-orchestrator](agents/orchestrators/tech-lead-orchestrator.md) | Analyzes tasks, assigns specialists, enforces max 4 parallel agents |
| [project-builder](agents/orchestrators/project-builder.md) | End-to-end project builds with 9-phase lifecycle |
| [requirements-clarifier](agents/orchestrators/requirements-clarifier.md) | Turns vague briefs into structured execution plans |
| [project-analyst](agents/orchestrators/project-analyst.md) | Detects tech stack for intelligent agent routing |
| [team-configurator](agents/orchestrators/team-configurator.md) | Configures optimal agent team for your project |

### Core Team (7 agents)
| Agent | Purpose |
|-------|---------|
| [code-reviewer](agents/core/code-reviewer.md) | 2-stage reviews (spec compliance + code quality) with reports |
| [testing-specialist](agents/core/testing-specialist.md) | TDD enforcement, unit tests, Playwright E2E across all stacks |
| [systematic-debugger](agents/core/systematic-debugger.md) | 4-phase root-cause debugging with evidence-backed fixes |
| [code-archaeologist](agents/core/code-archaeologist.md) | Deep codebase exploration, architecture mapping, risk assessment |
| [performance-optimizer](agents/core/performance-optimizer.md) | Bottleneck profiling, optimization, before/after metrics |
| [documentation-specialist](agents/core/documentation-specialist.md) | READMEs, API specs, architecture guides |
| [branch-finisher](agents/core/branch-finisher.md) | Structured branch completion (merge/PR/keep/discard) |

### Universal Experts (4 agents)
| Agent | Purpose |
|-------|---------|
| [backend-developer](agents/universal/backend-developer.md) | Polyglot backend for any language/framework |
| [frontend-developer](agents/universal/frontend-developer.md) | Universal UI builder with 2026 framework ecosystem |
| [api-architect](agents/universal/api-architect.md) | RESTful, GraphQL, OpenAPI contract design |
| [tailwind-css-expert](agents/universal/tailwind-css-expert.md) | Tailwind CSS styling and responsive components |

### Python Specialists (9 agents)
| Agent | Purpose |
|-------|---------|
| [python-expert](agents/specialized/python/python-expert.md) | Modern Python 3.12+ development |
| [fastapi-expert](agents/specialized/python/fastapi-expert.md) | FastAPI high-performance APIs |
| [django-expert](agents/specialized/python/django-expert.md) | Django full-stack with DRF |
| [ml-data-expert](agents/specialized/python/ml-data-expert.md) | ML/AI, data science, pandas/sklearn/PyTorch |
| [security-expert](agents/specialized/python/security-expert.md) | Python security, cryptography, vulnerability assessment |
| [testing-expert](agents/specialized/python/testing-expert.md) | pytest, test automation, quality assurance |
| [performance-expert](agents/specialized/python/performance-expert.md) | Python profiling, async, optimization |
| [web-scraping-expert](agents/specialized/python/web-scraping-expert.md) | Scraping, data extraction, async crawling |
| [devops-cicd-expert](agents/specialized/python/devops-cicd-expert.md) | CI/CD, Docker, infrastructure as code |

### Framework Specialists (13 agents)

**Django (3)**
| Agent | Purpose |
|-------|---------|
| [django-backend-expert](agents/specialized/django/django-backend-expert.md) | Models, views, services |
| [django-api-developer](agents/specialized/django/django-api-developer.md) | DRF and GraphQL APIs |
| [django-orm-expert](agents/specialized/django/django-orm-expert.md) | Query optimization, migrations |

**Rails (3)**
| Agent | Purpose |
|-------|---------|
| [rails-backend-expert](agents/specialized/rails/rails-backend-expert.md) | Full-stack Rails development |
| [rails-api-developer](agents/specialized/rails/rails-api-developer.md) | RESTful APIs and GraphQL |
| [rails-activerecord-expert](agents/specialized/rails/rails-activerecord-expert.md) | Complex queries, DB optimization |

**Laravel (2)**
| Agent | Purpose |
|-------|---------|
| [laravel-backend-expert](agents/specialized/laravel/laravel-backend-expert.md) | MVC, Inertia, Livewire, API architectures |
| [laravel-eloquent-expert](agents/specialized/laravel/laravel-eloquent-expert.md) | Eloquent ORM, schemas, query tuning |

**React (2)**
| Agent | Purpose |
|-------|---------|
| [react-component-architect](agents/specialized/react/react-component-architect.md) | Modern React patterns, hooks, components |
| [react-nextjs-expert](agents/specialized/react/react-nextjs-expert.md) | Next.js SSR, SSG, ISR |

**Vue (3)**
| Agent | Purpose |
|-------|---------|
| [vue-component-architect](agents/specialized/vue/vue-component-architect.md) | Vue 3 Composition API, component design |
| [vue-nuxt-expert](agents/specialized/vue/vue-nuxt-expert.md) | Nuxt SSR, SSG, full-stack Vue |
| [vue-state-manager](agents/specialized/vue/vue-state-manager.md) | Pinia/Vuex state architecture |

---

## How It Works

### Orchestration Pattern

```
User Request
    |
    v
tech-lead-orchestrator (analyzes, assigns agents, sets execution order)
    |
    v
[Approval Gate] -- user reviews plan
    |
    v
Specialists execute (max 4 in parallel)
    |
    v
[Approval Gate] -- user verifies each phase
    |
    v
code-reviewer + testing-specialist (quality gates)
    |
    v
branch-finisher (merge/PR)
```

### Key Principles

1. **Tech-lead routes all multi-step tasks** -- never pick agents yourself
2. **Max 4 agents in parallel** -- orchestrators enforce this limit
3. **Human approval gates** at every major milestone (schema, backend, frontend, tests)
4. **Framework-specific agents preferred** over universal ones (e.g., `django-backend-expert` over `backend-developer`)
5. **Structured handoffs** -- each agent returns a report the next agent can parse

### Pre-Flight Checks (Automatic)

Every task begins with:
- Git remote verification
- Docker setup check (required for implementation)
- Branch safety (no work on `main`/`master`)
- UI framework proposal and approval (if frontend work)

---

## Creating Custom Agents

See [docs/creating-agents.md](docs/creating-agents.md) for the full guide.

**Quick template:**
```yaml
---
name: my-agent-name
description: One-line description of when this agent should be used.
tools: Read, Write, Edit, Bash, Grep, Glob, LS
---

# Agent Name

## Mission
[What this agent does]

## Workflow
[Step-by-step process]

## Structured Report Format
[What the agent returns]

## Delegation
[When to hand off to other agents]

## Red Flags
[When to stop and reassess]
```

---

## Learn More

- [Creating Custom Agents](docs/creating-agents.md)
- [Best Practices](docs/best-practices.md)
- [Dependencies](docs/dependencies.md)

## Community

- [Report issues](https://github.com/ps-prabhjyotsingh/WebAgencyAgents/issues)
- [Share ideas](https://github.com/ps-prabhjyotsingh/WebAgencyAgents/discussions)

## License

MIT License - Use freely in your projects.

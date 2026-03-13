# CLAUDE.md

Project-level instructions for AI coding assistants working with this repository.

## Project Overview

A collection of 38 specialized AI agent prompts that extend any AI coding assistant's capabilities through intelligent orchestration and domain expertise. Platform-agnostic -- works with Claude Code, Warp, Cursor, Windsurf, or any tool supporting custom prompts.

## Working with Agents

**⚠️ REMINDER: Before modifying ANY file, verify you are on a feature branch (NOT main/master)**

When creating or modifying agents:
1. Agents are Markdown files with YAML frontmatter
2. Most agents should omit the `tools` field to inherit all available tools
3. Agents return structured findings for main agent coordination
4. Keep agent files concise (target 100-300 lines) to minimize token waste
5. Do NOT duplicate Git Safety Rules in agents -- they are enforced at project level (see below)

## Orchestration Protocol

Sub-agents cannot directly invoke other sub-agents. The main agent orchestrates all coordination.

### Agent Routing (Mandatory)

1. **ALWAYS start with tech-lead-orchestrator** for any multi-step task
2. **FOLLOW the agent routing map** returned by tech-lead EXACTLY
3. **USE ONLY the agents** explicitly recommended by tech-lead
4. **NEVER select agents independently** -- tech-lead knows which agents exist
5. **Maximum 4 agents in parallel** -- never exceed this limit

### Routing Flow

```
CORRECT:  User Request -> Tech-Lead Analysis -> Agent Routing Map -> Execute with Listed Agents
WRONG:    User Request -> Main Agent Guesses -> Wrong Agent Selected -> Task Fails
```

### Context Hygiene for Sub-Agents

Each sub-agent invocation MUST receive curated, minimal context:
1. **Extract, don't forward** -- pull only relevant findings from prior agents
2. **Provide full task text** -- not a summary or reference
3. **Include file paths** -- exact files to read or modify
4. **Set the scene** -- 1-2 sentences of where this fits
5. **Omit irrelevant history**

Good context example:
```
Task: Implement user registration endpoint
Context: Phase 5 (Backend) of a Laravel 12 project. Schema already migrated.
Files: app/Http/Controllers/AuthController.php, routes/api.php
Prior phase: User model at app/Models/User.php with fields: name, email, password
Criteria: POST /api/register accepts name, email, password. Returns 201 with user JSON.
```

## Agent Architecture

### Categories (38 agents total)

| Category | Location | Count | Purpose |
|----------|----------|-------|---------|
| Orchestrators | `agents/orchestrators/` | 5 | Planning, routing, coordination |
| Core | `agents/core/` | 7 | Reviews, testing, debugging, docs (all stacks) |
| Universal | `agents/universal/` | 4 | Framework-agnostic fallbacks |
| Python | `agents/specialized/python/` | 9 | Python ecosystem specialists |
| Django | `agents/specialized/django/` | 3 | Django-specific experts |
| Rails | `agents/specialized/rails/` | 3 | Rails-specific experts |
| Laravel | `agents/specialized/laravel/` | 2 | Laravel-specific experts |
| React | `agents/specialized/react/` | 2 | React/Next.js experts |
| Vue | `agents/specialized/vue/` | 3 | Vue/Nuxt/Pinia experts |

### Routing Rules
- Prefer framework-specific agents over universal (e.g., `django-backend-expert` > `backend-developer`)
- Use `project-analyst` to detect the stack when uncertain
- Universal agents are fallbacks for unknown stacks

## Usage Pipelines

### Build a New Project
```
requirements-clarifier -> [APPROVAL] -> project-builder -> specialists (per phase) -> [APPROVAL per phase] -> code-reviewer -> branch-finisher
```

### Add a Feature
```
tech-lead-orchestrator -> [APPROVAL] -> assigned specialists -> testing-specialist -> code-reviewer -> branch-finisher
```

### Debug a Bug
```
systematic-debugger (4 phases) -> [APPROVAL after root cause] -> fix with test
```

### Code Review
```
code-reviewer (Stage 1: spec compliance -> Stage 2: code quality) -> report to .code-reviews/
```

### Explore a Codebase
```
code-archaeologist -> team-configurator (updates project config)
```

## Project Builder Workflow

For end-to-end builds from `requirements.md`:
1. `requirements-clarifier` -- analyzes requirements, produces execution plan
2. `project-builder` -- orchestrates 9-phase lifecycle
3. Each phase: implement -> unit test -> code review -> approval gate
4. Reports to `.code-reviews/` (gitignored)

### Supported Stacks
- **Laravel** -- Blade/Livewire or Laravel + React (dual-service Docker)
- **Node.js** -- Express, Fastify, NestJS, Koa
- **Django** -- DRF, full-stack
- **Rails** -- API, full-stack
- **React/Vue** -- standalone or with any backend

### Skills (`skills/`)
- `laravel-dockerization` -- Docker setup for Laravel projects
- `nodejs-dockerization` -- Docker setup for Node.js projects
- `playwright-testing` -- E2E testing setup with stack-aware configs

## Development Guidelines

1. **Creating Agents**: Focus on single domain, include structured report format, define delegation triggers
2. **Agent Returns**: Always structured, include "Next Steps" and handoff info
3. **Testing**: Verify invocation patterns and delegation chains

---

## Project Development Standards

All agents MUST follow these standards universally. These rules are enforced at project level so individual agents do not need to repeat them.

### 1. Git Safety Rules (Enforced for ALL agents)

- **NEVER commit directly to `main` or `master`** -- always use a feature branch
- **Before any work**, verify current branch: `git branch --show-current`
  - If on `main`/`master` -> create a feature branch: `git checkout -b feature/<name>`
- **NEVER force push** to `main`/`master`
- **NEVER run destructive git commands** without explicit user approval
- After committing, push to remote: `git push -u origin <branch>` (if remote exists)
- Branch naming: `feature/`, `fix/`, `release/`, `hotfix/`
- Commit format: Conventional Commits (`feat(scope): description`)
- **NEVER add Claude/Anthropic co-author attribution** in commit messages

### 2. Dockerization Requirement

Before starting implementation:
- Verify `Dockerfile`, `docker-compose.yml` exist
- If NOT found -> **STOP**: "ERROR: Project has not been Dockerized yet."
- Use `make up` / `make down` to start/stop
- Verify `.env` is compatible with `Makefile` targets

### 3. UI/UX Framework Selection

For frontend work:
1. Propose framework with rationale
2. Get **explicit human approval** before proceeding
3. Do NOT implement until approved

### 4. Human Approval Gates

**PAUSE** at each milestone with:
- Summary of what was completed
- Verification steps (commands, URLs, credentials, expected behavior)
- What comes next

**Mandatory gates:**
- After pre-flight checks
- After UI framework selection
- After database schema design (before migrations)
- After each major feature (backend and frontend separately)
- Before final integration

### 5. Documentation

Maintain `docs/` folder:
- `docs/progress.md` -- updated after every significant step
- `docs/<feature>.md` -- per-feature documentation
- `docs/decisions.md` -- architectural decisions with rationale

### 6. Database Naming Rules

Keep constraint/index names under 50 characters:
```php
// BAD
$table->unique(['style_id', 'process_type_id', 'employee_type_id']);
// GOOD
$table->unique(['style_id', 'process_type_id', 'employee_type_id'], 'spe_unique');
```

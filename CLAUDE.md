# CLAUDE.md

## ⚠️ CRITICAL: GIT FLOW RULES - READ THIS FIRST ⚠️

**THESE RULES MUST BE FOLLOWED WITHOUT EXCEPTION:**

### 🔴 NEVER COMMIT DIRECTLY TO MAIN/MASTER
1. **ALWAYS** create a feature branch before any work: `git checkout -b feature/<description>`
2. **NEVER** use `git commit` while on `main` or `master` branch
3. **ALWAYS** verify current branch with `git branch` before making changes
4. For bug fixes use: `fix/<description>`
5. For releases use: `release/<version>`
6. For hotfixes use: `hotfix/<description>`

### 🔴 MANDATORY PRE-FLIGHT CHECKS (BEFORE ANY WORK)
**Run these checks BEFORE starting ANY task:**
```bash
# 1. Check current branch - MUST NOT be main/master
git branch --show-current

# 2. If on main/master, CREATE FEATURE BRANCH IMMEDIATELY:
if [[ $(git branch --show-current) == "main" ]] || [[ $(git branch --show-current) == "master" ]]; then
  git checkout -b feature/<task-description>
fi

# 3. Check for git remote
git remote -v

# 4. Check if project is dockerized (REQUIRED before implementation)
ls Dockerfile docker-compose.yml
```

### 🔴 COMMIT MESSAGE FORMAT (REQUIRED)
- Use Conventional Commits: `feat(scope): description`, `fix(scope): description`, `docs(scope): description`
- **ALWAYS** include co-author: `Co-Authored-By: Oz <oz-agent@warp.dev>`
- **NEVER** include Claude/Anthropic attribution

### 🔴 AFTER EVERY COMMIT
- **ALWAYS** push to remote if configured: `git push origin <branch-name>`
- **NEVER** push to main/master directly

---

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Web Agency Agents repository - a collection of specialized AI agent prompts that extend any AI coding assistant's capabilities through intelligent orchestration and domain expertise. The agents work together as a development team, with each agent having specific expertise and delegation patterns.

## Working with Agents

**⚠️ REMINDER: Before modifying ANY file, verify you are on a feature branch (NOT main/master)**

When creating or modifying agents:
1. **First**: Run `git branch --show-current` to verify branch
2. **If on main/master**: Create feature branch immediately with `git checkout -b feature/<description>`
3. Agents are Markdown files with YAML frontmatter
4. Most agents should omit the `tools` field to inherit all available tools
5. Use XML-style examples in descriptions for intelligent invocation
6. Agents return structured findings for main agent coordination

## Orchestration Pattern for Claude Code

Since sub-agents in Claude Code cannot directly invoke other sub-agents, orchestration follows this strict pattern:

### CRITICAL: Agent Routing Protocol

**When handling complex tasks, you MUST:**

1. **ALWAYS start with tech-lead-orchestrator** for any multi-step task
2. **FOLLOW the agent routing map** returned by tech-lead EXACTLY
3. **USE ONLY the agents** explicitly recommended by tech-lead
4. **NEVER select agents independently** - tech-lead knows which agents exist

### Example: Building a Feature with Agent Routing

```
User: "Build a user management system"

Main Claude Agent:
1. First, I'll use the tech-lead-orchestrator to analyze and get routing
   → Tech lead returns Agent Routing Map with SPECIFIC agents
   
2. I MUST use ONLY the agents listed in the routing map:
   - If tech-lead says "use django-api-developer" → Use that EXACT agent
   - If tech-lead says "use react-component-architect" → Use that EXACT agent
   - DO NOT substitute with generic agents unless specified as fallback
   
3. Execute tasks in the order specified by tech-lead using TodoWrite
```

### Key Orchestration Rules

1. **Tech-Lead is Routing Authority**: Tech-lead determines which agents can handle each task
2. **Strict Agent Selection**: Use ONLY agents from tech-lead's "Available Agents" list
3. **No Improvisation**: Do NOT select agents based on your own judgment
4. **Deep Reasoning**: Apply careful thought when coordinating the recommended agents
5. **Structured Handoffs**: Extract and pass information between agent invocations

### Agent Selection Flow

```
CORRECT FLOW:
User Request → Tech-Lead Analysis → Agent Routing Map → Execute with Listed Agents

INCORRECT FLOW:
User Request → Main Agent Guesses → Wrong Agent Selected → Task Fails
```

### Example Tech-Lead Response You Must Follow

When tech-lead returns:
```
## Available Agents for This Project
- django-backend-expert: Django tasks
- django-api-developer: API tasks  
- react-component-architect: React UI
```

You MUST use these specific agents, NOT generic alternatives like "backend-developer"

## High-Level Architecture

### Agent Organization
The project follows a hierarchical structure:

1. **Orchestrators** (`agents/orchestrators/`)
   - `tech-lead-orchestrator`: Coordinates complex projects through three-phase workflow (Research → Planning → Execution)
   - `project-analyst`: Detects technology stack and enables intelligent routing
   - `team-configurator`: Creates agent routing rules in CLAUDE.md files
   - `requirements-clarifier`: Analyzes requirements.md, asks clarifying questions, produces execution plans
   - `project-builder`: Master orchestrator for end-to-end project builds from requirements.md

2. **Core Agents** (`agents/core/`)
   - Cross-cutting concerns like code archaeology, reviews, performance, debugging, and documentation
   - `testing-specialist`: Universal testing with TDD enforcement (RED-GREEN-REFACTOR) across PHPUnit/Pest, Jest/Vitest, and Playwright E2E
   - `code-reviewer`: Two-stage reviews (spec compliance then code quality) with reports saved to `.code-reviews/`
   - `systematic-debugger`: 4-phase root-cause debugging (investigate → analyse → hypothesise → fix) with user approval gate
   - `branch-finisher`: Structured branch completion (verify tests → present options → execute → cleanup)
   - These agents support all technology stacks

3. **Universal Agents** (`agents/universal/`)
   - Framework-agnostic specialists (API, backend, frontend, Tailwind)
   - Fallback when no framework-specific agent exists

4. **Specialized Agents** (`agents/specialized/`)
   - Framework-specific experts organized by technology
   - Subdirectories: laravel/, django/, rails/, react/, vue/

### Three-Phase Orchestration Workflow (Main Agent Coordinated)

The main Claude agent implements a human-in-the-loop workflow using the tech-lead-orchestrator:

1. **Research Phase**: Tech-lead analyzes requirements and returns structured findings
2. **Approval Gate**: Main agent presents findings and waits for human approval
3. **Planning Phase**: Main agent creates tasks with TodoWrite based on tech-lead's recommendations
4. **Execution Phase**: Main agent invokes specialists sequentially with filtered context

### Agent Communication Protocol

Since sub-agents cannot directly communicate or invoke each other:
- **Structured Returns**: Each agent returns findings in a parseable format
- **Context Passing**: Main agent extracts relevant information from returns
- **Sequential Coordination**: Main agent manages the execution flow
- **Handoff Information**: Agents include what the next specialist needs in their returns

### Sub-Agent Context Hygiene

Each sub-agent invocation MUST receive **curated, minimal context** — not the accumulated conversation history. This prevents context pollution and ensures agents work with clean, relevant information.

**Rules:**
1. **Extract, don't forward** — Pull only the relevant findings from a prior agent's return. Never pass the entire conversation or plan.
2. **Provide full task text** — Give the sub-agent the complete text of its specific task, not a summary or reference to a plan file.
3. **Include file paths** — List the exact files the sub-agent needs to read or modify.
4. **Set the scene** — Briefly describe where this task fits in the overall work (1-2 sentences of context).
5. **Omit irrelevant history** — Don't include findings from unrelated phases or agents.

**Example of good context for a sub-agent:**
```
Task: Implement user registration endpoint
Context: This is Phase 5 (Backend) of a Laravel 12 project. Database schema is already migrated.
Files to modify: app/Http/Controllers/AuthController.php, routes/api.php
From prior phase: User model exists at app/Models/User.php with fields: name, email, password
Acceptance criteria: POST /api/register accepts name, email, password. Returns 201 with user JSON.
```

**Example of bad context:**
```
Here's everything from the conversation so far: [dumps 5000 tokens of prior discussion]
```

Example return format:
```
## Task Completed: API Design
- Endpoints defined: GET/POST/PUT/DELETE /api/users
- Authentication: Bearer token required
- Next specialist needs: This API specification for implementation
```

### Intelligent Routing

The system automatically routes tasks based on:
1. Project context (detected by project-analyst)
2. Framework-specific routing when applicable
3. Universal fallback for unknown stacks
4. Task requirements and agent expertise

## Key Concepts

### Agent Definition Format
```yaml
---
name: agent-name
description: |
  Expertise description with XML examples
  Examples:
  - <example>
    Context: When to use
    user: "Request"
    assistant: "I'll use agent-name"
    <commentary>Why selected</commentary>
  </example>
# tools: omit for all tools, specify for restrictions
---

# Agent Name
System prompt content...
```

### Ambiguity Detection
- Project-analyst flags uncertainties in analysis
- Tech-lead presents research findings for approval before execution
- Agents should identify assumptions needing clarification

### Tool Inheritance
- Omitting `tools` field = inherit all tools (recommended)
- Specify tools only for security restrictions
- Includes WebFetch, MCP tools when available

## Development Guidelines

1. **Creating New Agents**:
   - Use templates/agent-template.md as starting point
   - Focus on single domain expertise
   - Include 2-3 XML examples
   - Define structured return format

2. **Agent Return Patterns**:
   - Always return findings in structured format
   - Include "Next Steps" or "Handoff Information"
   - Specify what context next specialist needs
   - Main agent will parse and coordinate

3. **Testing Agents**:
   - Test invocation patterns
   - Verify delegation works correctly
   - Ensure quality of output

## Important Files and Patterns

- `docs/orchestration-patterns.md`: Detailed three-phase workflow documentation
- `docs/creating-agents.md`: Guide for creating new agents
- `docs/best-practices.md`: Agent development best practices
- `examples/`: Real-world usage examples
- All agents support human-in-the-loop through the tech-lead's approval gate

## Project Builder Workflow

For end-to-end project builds from a `requirements.md`:

1. **Invoke `requirements-clarifier`** — analyzes requirements, asks clarifying questions, produces a phased execution plan
2. **Invoke `project-builder`** — orchestrates phased execution using the clarified plan
3. Each phase follows: implement → unit test → code review → approval gate
4. `code-reviewer` writes reports to `.code-reviews/` (gitignored, never pushed)
5. `testing-specialist` handles unit tests (PHPUnit/Pest/Jest/Vitest) and Playwright E2E tests

### Supported Stacks
- **Laravel 12 standalone** — Blade/Livewire frontend + Laravel backend
- **Laravel 12 + React** — Laravel API backend + React frontend (dual-service Docker)
- **Node.js** — Express, Fastify, NestJS, Koa applications

### Skills (`skills/`)
- `laravel-dockerization` — Docker setup for Laravel projects (standalone and Laravel+React)
- `nodejs-dockerization` — Docker setup for Node.js projects
- `playwright-testing` — E2E testing setup with stack-aware Playwright configs

### Code Review Reports
The `code-reviewer` agent writes markdown reports to `.code-reviews/` in the project root. This directory MUST be gitignored to prevent reports from being pushed to the repository. Add `.code-reviews/` to your project's `.gitignore`.

## Complete Orchestration Example

Here's a full example showing proper agent routing:

### User Request:
"Help me build an authentication system for my web app"

### Step 1: Tech-Lead Analysis
```
Main Agent: "I'll use the tech-lead-orchestrator to analyze this request and determine the best approach."

[Invokes tech-lead-orchestrator]
```

### Step 2: Tech-Lead Returns Routing Map
```
## Agent Routing Map

Task 1: Detect Project Technology
- PRIMARY AGENT: project-analyst
- REASON: Need to identify framework for proper routing

Task 2: Design Authentication Schema  
- PRIMARY AGENT: database-architect
- REASON: Framework-agnostic database design

Task 3: Implement Auth Backend
- PRIMARY AGENT: django-backend-expert
- FALLBACK AGENT: backend-developer
- REASON: Django detected in project

Task 4: Create Auth API Endpoints
- PRIMARY AGENT: django-api-developer
- FALLBACK AGENT: api-architect
- REASON: Django REST Framework patterns

## Available Agents for This Project
- project-analyst
- database-architect  
- django-backend-expert
- django-api-developer
- code-reviewer

## CRITICAL INSTRUCTION
Use ONLY the agents listed above. Do NOT use laravel, rails, or other framework agents.
```

### Step 3: Main Agent Executes Plan
```
Main Agent: "Based on the tech-lead's routing, I'll now coordinate the implementation:"

1. ✓ Using project-analyst to analyze the codebase
2. ✓ Using database-architect for auth schema design  
3. ✓ Using django-backend-expert for implementation
4. ✓ Using django-api-developer for API endpoints
5. ✓ Using code-reviewer for security audit

[Executes each step with the EXACT agents specified]
```

### What NOT to Do:
```
❌ "I'll use backend-developer" (when tech-lead specified django-backend-expert)
❌ "I'll use rails-api-developer" (wrong framework)
❌ "I'll skip the tech-lead and choose agents myself" (bypasses routing)
```

## Critical Reminders

- ALWAYS use tech-lead-orchestrator for multi-step tasks to get proper agent routing
- FOLLOW the agent routing map exactly - do not improvise
- USE deep reasoning when coordinating the recommended agents
- TRUST the tech-lead's expertise in agent selection

---

## Project Development Standards

**⚠️ CRITICAL REMINDER: These standards include the git flow rules from the top of this document. ALWAYS follow them.**

All agents MUST follow these standards when working on any project. These apply universally regardless of framework.

### 1. Git Setup (Pre-Flight Check)

**🔴 MANDATORY FIRST STEP - CHECK BRANCH:**
```bash
# ALWAYS run this BEFORE any work
git branch --show-current

# If output is "main" or "master" → CREATE FEATURE BRANCH IMMEDIATELY
git checkout -b feature/<task-description>
```

Before any coding begins:
1. **🔴 VERIFY NOT ON MAIN/MASTER**: Run `git branch --show-current` - if on main/master, create feature branch immediately
2. Check if a git remote is configured: `git remote -v`
3. If NO remote is found → **STOP** and ask the user:
   > "No git remote is configured. Would you like to add one, or skip and work locally only?"
4. If YES remote → proceed with git flow branching below.
5. Always follow **git flow** branching:
   - **🔴 NEVER EVER commit directly to `main` or `master`** - This is the #1 rule
   - Feature work → `feature/<short-description>`
   - Bug fixes → `fix/<short-description>`
   - Releases → `release/<version>`
   - Hotfixes → `hotfix/<short-description>`
6. All commit messages MUST follow Conventional Commits format:
   - `feat(scope): short description`
   - `fix(scope): short description`
   - `docs(scope): short description`
   - `chore(scope): short description`
7. **NEVER add Claude/Anthropic co-author attribution** in commit messages:
   - Do NOT include `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` or similar
   - Do NOT include any co-author line referencing Claude, Anthropic, or AI models
   - The only acceptable co-author line (if using Oz/Warp agents) is: `Co-Authored-By: Oz <oz-agent@warp.dev>`
   - When in doubt, omit co-author lines entirely
8. After every commit, push to remote if one is configured: `git push origin <branch-name>`
9. **🔴 VERIFY BRANCH BEFORE PUSHING**: Always confirm you're NOT pushing to main/master

### 2. Dockerization Requirement

**MANDATORY CHECK**: Before starting any implementation, verify the project is dockerized.
- Look for `Dockerfile`, `docker-compose.yml`, or `docker-compose.yaml`
- If NOT found → **STOP immediately** and return this error:
  > "ERROR: Project has not been Dockerized yet. Please Dockerize the project before proceeding."
- Do NOT write code or make changes until the project is Dockerized.
- Always use `make up` to start the application and `make down` to stop it.
- Verify `.env` configuration is compatible with `Makefile` targets.

### 3. UI/UX Framework Selection

Whenever frontend work is involved:
1. Propose a specific UI framework based on project context (e.g., Tailwind CSS + Shadcn, Bootstrap, Ant Design, Material UI).
2. Present the rationale and get **explicit human approval** before proceeding.
3. Do NOT start frontend implementation until the framework is approved.

### 4. Human Approval Gates

At each strategic milestone, **PAUSE** and present an approval gate with:
- Summary of what was just completed
- How to test/verify the work:
  - Exact commands to run (e.g., `make up`, `php artisan migrate`)
  - URLs to open (e.g., `http://localhost:8000/api/health`)
  - Default credentials if applicable (e.g., `admin@example.com / password`)
  - Expected output or behaviour
- What comes next (so the user can make an informed decision)

Do NOT proceed to the next phase until the human responds with approval.

**Mandatory approval gates:**
- After project analysis / pre-flight checks
- After UI framework selection
- After database schema is designed (before running migrations)
- After each major feature is implemented (backend AND frontend separately)
- Before final integration / go-live

### 5. Documentation & Project Memory

Maintain living documentation in the `docs/` folder:
- Update `docs/progress.md` after every significant step with what was done, what changed, and what is next.
- Create feature-specific docs (e.g., `docs/auth.md`, `docs/api.md`) as features are built.
- Keep `docs/decisions.md` to log architectural and tooling decisions with rationale.
- All docs live in `docs/` — never scatter markdown files in the root.
- After every work session, the docs must reflect the current state of the project.

### 6. Database Key Name Rules

To prevent "Identifier name too long" database errors:
- Keep constraint names and index names **short and descriptive** (max ~50 characters).
- Avoid auto-generated names that concatenate multiple column names.
- Explicitly name foreign keys, indexes, and unique constraints:
  ```php
  // BAD - auto-generated name too long
  $table->unique(['style_id', 'process_type_id', 'employee_type_id']);

  // GOOD - explicit short name
  $table->unique(['style_id', 'process_type_id', 'employee_type_id'], 'spe_unique');
  ```
- Rule of thumb: constraint name = abbreviated table + columns + type, all ≤ 50 chars.

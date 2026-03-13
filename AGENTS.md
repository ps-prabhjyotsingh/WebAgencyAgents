# AGENTS.md - Universal AI Agent Guidelines

> **📌 CRITICAL:** This file contains mandatory rules for ALL AI assistants working with this repository, regardless of platform (Claude Code, Warp, Cursor, Windsurf, etc.).

---

## 🔴 MANDATORY RULES - READ BEFORE ANY WORK

These rules MUST be followed without exception. Violations will result in broken workflows and incorrect implementations.

### Rule 1: 🚫 NEVER COMMIT DIRECTLY TO MAIN/MASTER

**BEFORE starting ANY task:**
```bash
# Check current branch
git branch --show-current

# If output is "main" or "master" → CREATE FEATURE BRANCH IMMEDIATELY
git checkout -b feature/<task-description>
```

**Git Flow Branching:**
- Feature work → `feature/<short-description>`
- Bug fixes → `fix/<short-description>`
- Releases → `release/<version>`
- Hotfixes → `hotfix/<short-description>`

**After EVERY commit:**
```bash
git push origin <branch-name>
```

**Commit Format (Conventional Commits):**
- `feat(scope): description`
- `fix(scope): description`
- `docs(scope): description`
- `chore(scope): description`
- ALWAYS include: `Co-Authored-By: Oz <oz-agent@warp.dev>`
- NEVER include Claude/Anthropic attribution

---

### Rule 2: 🛑 MANDATORY PRE-FLIGHT CHECKS

**Run these checks BEFORE writing ANY code:**

```bash
# 1. Verify NOT on main/master
current_branch=$(git branch --show-current)
if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
  echo "❌ ERROR: You are on $current_branch. Create a feature branch first!"
  exit 1
fi

# 2. Verify git remote exists
git remote -v || echo "⚠️ WARNING: No git remote configured"

# 3. Verify project is Dockerized (REQUIRED before implementation)
if [[ ! -f Dockerfile ]] || [[ ! -f docker-compose.yml ]]; then
  echo "❌ ERROR: Project has not been Dockerized yet."
  echo "Please Dockerize the project before proceeding."
  exit 1
fi
```

**IF DOCKER CHECK FAILS:**
- STOP immediately
- Return error: "Project has not been Dockerized yet. Please Dockerize before proceeding."
- Do NOT write ANY code until Dockerized

---

### Rule 3: 🎯 APPROVAL GATES (NEVER SKIP)

**Approval gates are MANDATORY at these points:**

1. **After Project Analysis** - Present findings, wait for approval
2. **After UI Framework Selection** - Propose options, wait for approval before installing
3. **After Database Schema Design** - Show ERD/migrations, wait for approval before running
4. **After Each Major Feature** - Present implementation summary, wait for approval
5. **Before Final Integration** - Show integration plan, wait for approval

**How to Present Approval Gates:**
```markdown
## 🎯 Approval Gate: [Phase Name]

### What Was Completed
- [List of completed items]

### How to Verify
- Run: `make up`
- Open: `http://localhost:8000`
- Login: `admin@example.com / password`
- Expected: [describe expected behavior]

### What Comes Next
- [Next phase description]

**⏸️ Waiting for your approval to proceed...**
```

**DO NOT PROCEED until user explicitly approves.**

---

### Rule 4: 🧪 TESTING IS MANDATORY

**Test Requirements:**

**For Backend Code:**
- Write unit tests BEFORE implementation (TDD: RED-GREEN-REFACTOR)
- Use project's test framework:
  - PHP: PHPUnit or Pest
  - JavaScript/TypeScript: Jest or Vitest
  - Python: pytest
- Minimum 80% code coverage for new code

**For Frontend Code:**
- Component tests with Testing Library
- E2E tests with Playwright for critical flows
- Visual regression tests for UI changes

**For APIs:**
- Integration tests for all endpoints
- Test authentication/authorization
- Test error handling

**NEVER deliver code without tests.**

---

### Rule 5: 📝 CODE REVIEW IS MANDATORY

**After implementing ANY feature:**
```bash
# Use code-reviewer agent
claude "use @agent-code-reviewer to review the implemented feature"
```

**Code Reviewer Process:**
1. **Stage 1**: Spec compliance review
2. **Stage 2**: Code quality review
3. Writes reports to `.code-reviews/` (must be gitignored)
4. Tags issues by severity: CRITICAL, HIGH, MEDIUM, LOW, INFO

**DO NOT proceed to next phase if CRITICAL issues exist.**

---

### Rule 6: 🔄 NO PARALLEL SUB-AGENT INVOCATION

**IMPORTANT:** Sub-agents in most platforms (Claude Code, Cursor, Windsurf) **CANNOT directly invoke other sub-agents**.

**Correct Pattern:**
```
Main Agent → Tech Lead (returns routing map) 
          → Main Agent invokes specialists sequentially
          → Each specialist returns findings
          → Main Agent passes context to next specialist
```

**Incorrect Pattern (Will Fail):**
```
Main Agent → Sub-Agent-A → Sub-Agent-B (FAILS - sub-agents can't invoke each other)
```

**Context Passing Rules:**
- Extract ONLY relevant findings from prior agent returns
- Provide complete task text to each sub-agent
- Include file paths to read/modify
- 1-2 sentences of context about where this fits
- NEVER dump entire conversation history to sub-agents

---

### Rule 7: 🎭 ALWAYS USE TECH-LEAD FOR MULTI-STEP TASKS

**For ANY task with 3+ steps:**
```bash
claude "use @agent-tech-lead-orchestrator to plan [task description]"
```

**Tech Lead Will:**
- Analyze requirements
- Create agent routing map (which specialists to use)
- Return structured findings
- Wait for approval

**YOU MUST:**
- Use ONLY the agents listed in tech-lead's routing map
- Follow the exact sequence recommended
- NOT improvise or choose different agents

**Example:**
```
Tech Lead says: "Use django-backend-expert"
✅ Correct: Invoke django-backend-expert
❌ Wrong: Invoke generic backend-developer instead
```

---

### Rule 8: 📚 DOCUMENTATION IS MANDATORY

**Maintain living documentation in `docs/` folder:**

1. **docs/progress.md** - Update after EVERY significant step
   - What was done
   - What changed
   - What is next

2. **docs/decisions.md** - Log architectural decisions
   - What was decided
   - Why (rationale)
   - Alternatives considered

3. **Feature-specific docs** - Create as features are built
   - docs/auth.md
   - docs/api.md
   - docs/architecture.md

**Update docs BEFORE committing code.**

---

### Rule 9: 🎨 UI FRAMEWORK SELECTION REQUIRES APPROVAL

**For Frontend Work:**

1. **Auto-detect context:**
   - Read `package.json` for existing UI deps
   - Check framework (React/Vue/Angular/Svelte)
   - Analyze project complexity (simple vs enterprise)

2. **Propose 2-3 options with matrix:**
   | Framework | Best For | Bundle Size | Pros | Cons |
   |-----------|----------|-------------|------|------|
   | shadcn/ui | Customizable React | Minimal | Full ownership | Manual updates |
   | PrimeVue | Enterprise Vue | Medium | 90+ components | Larger bundle |

3. **Include animation library recommendation:**
   - React: Motion (Framer Motion) or Remotion
   - Vue: Motion for Vue or built-in transitions
   - Angular: Angular animations + GSAP
   - Svelte: Built-in transitions + Motion

4. **STOP and wait for explicit approval**

**DO NOT install ANY UI framework until approved.**

---

### Rule 10: 🏗️ PROJECT STRUCTURE WORKFLOWS

**For Greenfield Projects:**
```bash
1. Create requirements.md
2. claude "use @requirements-clarifier to analyze requirements.md"
3. Answer clarifying questions
4. claude "use @project-builder to execute the clarified plan"
5. Dockerize (use laravel-dockerization or nodejs-dockerization skill)
6. Add E2E tests (use playwright-testing skill)
```

**For New Features:**
```bash
1. claude "use @agent-team-configurator" (first time only)
2. Verify Docker & git setup
3. claude "use @agent-tech-lead-orchestrator to plan [feature]"
4. Execute with specialists per tech-lead's routing
5. claude "use @agent-code-reviewer to review"
6. claude "use @agent-branch-finisher to complete branch"
```

**For Bug Fixes:**
```bash
1. git checkout -b fix/<bug-description>
2. claude "use @agent-systematic-debugger to debug [issue]"
3. claude "use @agent-testing-specialist to add tests"
4. claude "use @agent-code-reviewer to review"
5. claude "use @agent-branch-finisher to complete"
```

---

## 🚨 RED FLAGS - STOP IF YOU SEE THESE

**STOP immediately if:**
- [ ] Currently on `main` or `master` branch
- [ ] About to commit without being on a feature branch
- [ ] Project is not Dockerized but implementation started
- [ ] Installing UI framework without user approval
- [ ] Implementing feature without tests
- [ ] No code review performed
- [ ] Skipping approval gates
- [ ] Sub-agent trying to invoke another sub-agent
- [ ] Committing to main/master
- [ ] Writing code without verifying branch first

---

## 📋 MANDATORY CHECKLIST (Use Before Every Commit)

```markdown
- [ ] Verified on feature/fix/release branch (NOT main/master)
- [ ] Project is Dockerized
- [ ] All tests pass (unit + integration + E2E)
- [ ] Code reviewed by @agent-code-reviewer
- [ ] No CRITICAL issues from code review
- [ ] Documentation updated (docs/progress.md minimum)
- [ ] Approval gate passed for this phase
- [ ] Commit message follows Conventional Commits
- [ ] Co-author line included: Co-Authored-By: Oz <oz-agent@warp.dev>
- [ ] Ready to push to remote
```

---

## 🎯 QUICK REFERENCE COMMANDS

**Start any project:**
```bash
# Verify branch
git branch --show-current

# If on main/master, create feature branch
git checkout -b feature/<description>

# Configure team (first time)
claude "use @agent-team-configurator"

# Plan complex task
claude "use @agent-tech-lead-orchestrator to plan [task]"
```

**Complete a feature:**
```bash
# Review
claude "use @agent-code-reviewer to review"

# Finish
claude "use @agent-branch-finisher to complete this branch"
```

---

## 💡 PLATFORM-SPECIFIC NOTES

### Claude Code
- Agents available via `~/.claude/agents/`
- Use `@agent-name` syntax
- CLAUDE.md file provides additional Claude-specific guidance

### Warp / Cursor / Windsurf
- Add this file (AGENTS.md) to your Rules
- Reference agents via URL or copy content
- Use `use @agent-name` or natural language

### All Platforms
- These rules apply universally
- Git flow rules are non-negotiable
- Approval gates are mandatory
- Testing is required
- Documentation must be maintained

---

## 📞 AGENT INVOCATION EXAMPLES

**Correct Orchestration:**
```bash
# 1. Plan with tech-lead
"use @agent-tech-lead-orchestrator to analyze and plan building a user authentication system"

# 2. Tech-lead returns routing map with specific agents

# 3. Invoke specialists based on routing
"use @django-backend-expert to implement the backend"
"use @react-component-architect to build the login UI"
"use @agent-code-reviewer to review all changes"
"use @agent-branch-finisher to complete this feature"
```

**Always follow the routing from tech-lead - don't improvise.**

---

## ⚠️ FINAL REMINDERS

1. **Git Flow**: ALWAYS work on feature branches, NEVER on main/master
2. **Docker First**: Verify Dockerization before writing code
3. **Approval Gates**: NEVER skip, always wait for user approval
4. **Testing**: Write tests BEFORE or WITH implementation (TDD)
5. **Code Review**: MANDATORY for every feature
6. **Documentation**: Update docs with every commit
7. **Tech Lead**: Use for multi-step tasks, follow routing exactly
8. **Sequential Invocation**: Sub-agents can't invoke each other
9. **UI Frameworks**: Get approval before installing
10. **Branch Completion**: Use @agent-branch-finisher for clean handoff

**These aren't suggestions - they're requirements.**

---

**Last Updated**: March 13, 2026
**Applies To**: All AI assistants (Claude Code, Warp, Cursor, Windsurf, etc.)

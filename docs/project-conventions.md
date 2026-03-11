# Project Conventions

This document defines the mandatory standards that all Claude agents must follow when working on any project. These conventions exist to prevent common mistakes and ensure consistent, high-quality development workflows.

---

## 1. Git Setup & Branching (Git Flow)

### Pre-Flight Git Check
Before any work begins, agents MUST verify the git setup:
```bash
git remote -v          # Check for remote
git branch --show-current  # Check current branch
```

- **No remote found** → Ask the user: "No git remote is configured. Would you like to add one (provide the URL), or continue working locally only?" — wait for a response before proceeding.
- **On `main` or `master`** → Create a feature branch immediately before making any commits.

### Branch Naming
| Branch Type | Pattern              | Example                    |
|-------------|----------------------|----------------------------|
| Feature     | `feature/<name>`     | `feature/user-auth`        |
| Bug Fix     | `fix/<name>`         | `fix/login-redirect`       |
| Release     | `release/<version>`  | `release/1.2.0`            |
| Hotfix      | `hotfix/<name>`      | `hotfix/critical-sql-error`|

**NEVER** commit directly to `main` or `master`.

### Commit Messages (Conventional Commits)
All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) format:
```
<type>(<scope>): <short description>
```

**Types:**
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only changes
- `chore` — build process, tooling, deps
- `refactor` — code restructuring without behaviour change
- `test` — adding or updating tests
- `style` — formatting, whitespace

**Examples:**
```
feat(auth): add JWT refresh token endpoint
fix(db): shorten unique constraint names to avoid length errors
docs(api): update REST endpoint documentation
chore(docker): update Makefile dev targets
```

### Pushing
After every commit, push to the remote if one is configured:
```bash
git push origin <branch-name>
```

---

## 2. Dockerization Requirement

**Every project must be Dockerized before any agent work begins.**

### Check
Look for any of:
- `Dockerfile`
- `docker-compose.yml`
- `docker-compose.yaml`

### If Not Found
Agents MUST stop immediately with this error:
> "ERROR: Project has not been Dockerized yet. Please Dockerize the project before proceeding."

No code changes should be made until Dockerization is confirmed.

### Starting & Stopping the App
Always use `make` targets — never call `docker-compose` directly:
```bash
make up     # Start the application
make down   # Stop the application
```

Ensure `.env` configuration is aligned with the `Makefile` targets. Check that variables like `APP_PORT`, `DB_HOST`, etc., match what the Makefile expects.

---

## 3. UI/UX Framework Selection

Whenever frontend work is involved, the agent MUST:

1. Inspect the existing project stack (CSS files, `package.json` dependencies, component structure).
2. Propose a specific UI framework with a clear rationale.
3. **STOP and wait for explicit human approval** before implementing any UI.

### Example Proposal Format
```
**Proposed UI Framework:** Tailwind CSS + Shadcn/UI
**Rationale:** Project already uses Vite + React 18. Shadcn provides accessible, unstyled headless components. Tailwind keeps styling utility-first and consistent.

Approve this choice, or would you prefer an alternative?
```

### Common Framework Choices
| Stack              | Recommended Framework         | Rationale                              |
|--------------------|-------------------------------|----------------------------------------|
| React              | Tailwind CSS + Shadcn/UI      | Headless components, great DX          |
| Vue 3              | Tailwind CSS + Headless UI    | Composable, unstyled                   |
| Server-rendered    | Bootstrap 5                   | Minimal JS, CDN-friendly               |
| Angular            | Angular Material + Tailwind   | Native integration                     |
| Inertia.js (Laravel/Rails) | Tailwind CSS + Headless UI | Works with SSR, minimal bundle  |

---

## 4. Human Approval Gates

Agents MUST pause at strategic milestones and wait for human verification before continuing.

### Mandatory Gates
| Gate | Trigger                          |
|------|----------------------------------|
| 1    | After pre-flight checks complete |
| 2    | After UI framework is proposed   |
| 3    | After database schema is designed (before migrations run) |
| 4    | After backend feature is implemented |
| 5    | After frontend feature is implemented |
| 6    | Before final integration / go-live |

### Gate Format
Each approval gate MUST include:
```
---
## ✅ Approval Gate — [Gate Name]

**What was completed:**
- [bullet summary of work done]

**How to verify:**
- Run: `make up`
- Visit: http://localhost:8000/[path]
- Login with: [credentials if applicable]
- Expected behaviour: [what the user should see/get]

**What comes next:**
- [brief description of next phase]

Please confirm you're happy to proceed, or raise any issues before I continue.
---
```

---

## 5. Documentation & Project Memory

All project documentation lives in the `docs/` folder. Never scatter markdown files in the project root.

### Required Files
| File                  | Purpose                                              |
|-----------------------|------------------------------------------------------|
| `docs/progress.md`    | Running log of completed work, updated after each step |
| `docs/decisions.md`   | Architectural and tooling decisions with rationale   |
| `docs/api.md`         | API endpoint documentation (created when APIs exist) |
| `docs/<feature>.md`   | Feature-specific implementation notes                |

### Update Cadence
- **After every significant step** → update `docs/progress.md`
- **After every major feature** → create or update `docs/<feature>.md`
- **After every architectural decision** → append to `docs/decisions.md`

### progress.md Format
```markdown
# Project Progress

## [YYYY-MM-DD] — [What was done]
- Completed: [description]
- Files changed: [list]
- Next: [what's coming]
```

---

## 6. Database Key Name Rules

Long auto-generated constraint names cause database errors like:
```
Identifier name 'style_process_pricing_style_id_process_type_id_employee_type_unique' is too long
```

### Rules
- Keep all constraint, index, and foreign key names **≤ 50 characters**.
- **Always explicitly name** constraints — never rely on auto-generated names when multiple columns are involved.
- Naming convention: `<abbrev_table>_<abbrev_cols>_<type>`

### Examples
```php
// BAD — auto-generated name will be too long
$table->unique(['style_id', 'process_type_id', 'employee_type_id']);
$table->foreign('organisation_department_id')->references('id')->on('organisation_departments');

// GOOD — explicit short names
$table->unique(['style_id', 'process_type_id', 'employee_type_id'], 'spe_unique');
$table->foreign('organisation_department_id', 'fk_org_dept')->references('id')->on('organisation_departments');

// GOOD — index naming
$table->index(['user_id', 'created_at'], 'idx_user_created');
```

```python
# Django example
class Meta:
    constraints = [
        models.UniqueConstraint(
            fields=['style', 'process_type', 'employee_type'],
            name='spe_unique'  # short, explicit
        )
    ]
```

---

## Quick Reference Checklist

Before starting any project task, verify:
- [ ] Git remote configured (or user has confirmed local-only)
- [ ] `Dockerfile` and `docker-compose.yml` exist
- [ ] `Makefile` with `up`/`down` targets exists
- [ ] Not on `main`/`master` branch
- [ ] UI framework approved (if frontend work is involved)
- [ ] `docs/` folder exists and `docs/progress.md` is up to date

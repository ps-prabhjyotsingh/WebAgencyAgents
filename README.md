# Web Agency Agents - AI Development Team 🚀

**A collection of specialized AI agent prompts** that work together to build complete features, debug complex issues, and handle any technology stack with expert-level knowledge. These agents are **platform-agnostic** — use them with Claude Code, Warp, Cursor, Windsurf, or any AI coding assistant that supports custom prompts.

## ⚠️ Important Notice

**This project is experimental and token-intensive.** Multi-agent orchestration can consume 10-50k tokens per complex feature. Use with caution and monitor your usage.

## 🚀 Quick Start

### Prerequisites
- An **AI coding assistant** (Claude Code, [Warp](https://www.warp.dev), Cursor, Windsurf, etc.)
- Active project directory with your codebase
- **Optional**: [Context7 MCP](docs/dependencies.md) for enhanced documentation access

### Clone the Repository
```bash
git clone https://github.com/ps-prabhjyotsingh/WebAgencyAgents.git web-agency-agents
```

---

### Setup: Claude Code

Claude Code natively supports agent files in `~/.claude/agents/`.

#### Option A: Symlink (Recommended - auto-updates)

**macOS/Linux:**
```bash
mkdir -p ~/.claude/agents
ln -sf "$(pwd)/web-agency-agents/agents/" ~/.claude/agents/web-agency-agents
```

**Windows (PowerShell):**
```powershell
New-Item -Path "$env:USERPROFILE\.claude\agents" -ItemType Directory -Force
cmd /c mklink /D "$env:USERPROFILE\.claude\agents\web-agency-agents" "$(Get-Location)\web-agency-agents\agents"
```

#### Option B: Copy (Static - no auto-updates)
```bash
mkdir -p ~/.claude/agents
cp -r web-agency-agents/agents ~/.claude/agents/web-agency-agents
```

#### Verify & Use
```bash
claude /agents
# Should show all 26 agents

# Configure your project
claude "use @agent-team-configurator and optimize my project to best use the available subagents."

# Start building
claude "use @agent-tech-lead-orchestrator and build a user authentication system"
```

---

### Setup: Warp, Cursor, Windsurf & Other Platforms

For platforms that don't use `~/.claude/agents/`, you can use these agents as **custom prompts or system instructions**.

#### Option 1: Reference agents via URL (easiest)

Paste this into your AI assistant's prompt or chat:

```
Follow the agent instructions from this file:
https://raw.githubusercontent.com/ps-prabhjyotsingh/WebAgencyAgents/master/agents/orchestrators/tech-lead-orchestrator.md
```

Replace the path with whichever agent you want to use. Browse the full list in the [`agents/`](agents/) directory.

#### Option 2: Copy agent content as a custom prompt

1. Browse to the agent you want in the [`agents/`](agents/) directory
2. Copy the **markdown content** (everything below the YAML frontmatter `---`)
3. Paste it as a **system prompt**, **custom instruction**, or **rules file** in your platform:
   - **Warp**: Add as a [Rule](https://docs.warp.dev/agents/rules) in your project or user settings
   - **Cursor**: Add to `.cursor/rules/` as a `.md` or `.mdc` file
   - **Windsurf**: Add to your project rules or global AI instructions
   - **Other tools**: Use wherever the platform accepts custom system prompts

#### Option 3: Point your AI at the full repo

For a quick multi-agent workflow, give your AI assistant this prompt:

```
I want you to act as the tech-lead-orchestrator from this agent collection:
https://github.com/ps-prabhjyotsingh/WebAgencyAgents

Read the agent definitions in the agents/ directory and coordinate a team
of specialists to help me build [describe your task].
```

---

Your AI team will automatically detect your stack and use the right specialists!

## 🎯 How Auto-Configuration Works

The @agent-team-configurator automatically sets up your perfect AI development team. When invoked, it:

1. **Locates CLAUDE.md** - Finds existing project configuration and preserves all your custom content outside the "AI Team Configuration" section
2. **Detects Technology Stack** - Inspects package.json, composer.json, requirements.txt, go.mod, Gemfile, and build configs to understand your project
3. **Discovers Available Agents** - Scans ~/.claude/agents/ and .claude/ folders, building a capability table of all available specialists
4. **Selects Specialists** - Prefers framework-specific agents over universal ones, always includes @agent-code-reviewer and @agent-performance-optimizer for quality assurance
5. **Updates CLAUDE.md** - Creates a timestamped "AI Team Configuration" section with your detected stack and a Task|Agent|Notes mapping table
6. **Provides Usage Guidance** - Shows you the detected stack, selected agents, and gives sample commands to start building


## 👥 Meet Your AI Development Team

### 🎭 Orchestrators (3 agents)
- **[Tech Lead Orchestrator](agents/orchestrators/tech-lead-orchestrator.md)** - Senior technical lead who analyzes complex projects and coordinates multi-step development tasks
- **[Project Analyst](agents/orchestrators/project-analyst.md)** - Technology stack detection specialist who enables intelligent agent routing
- **[Team Configurator](agents/orchestrators/team-configurator.md)** - AI team setup expert who detects your stack and configures optimal agent mappings

### 💼 Framework Specialists (13 agents)
- **Laravel (2 agents)**
  - **[Backend Expert](agents/specialized/laravel/laravel-backend-expert.md)** - Comprehensive Laravel development with MVC, services, and Eloquent patterns
  - **[Eloquent Expert](agents/specialized/laravel/laravel-eloquent-expert.md)** - Advanced ORM optimization, complex queries, and database performance
- **Django (3 agents)**
  - **[Backend Expert](agents/specialized/django/django-backend-expert.md)** - Models, views, services following current Django conventions
  - **[API Developer](agents/specialized/django/django-api-developer.md)** - Django REST Framework and GraphQL implementations
  - **[ORM Expert](agents/specialized/django/django-orm-expert.md)** - Query optimization and database performance for Django applications
- **Rails (3 agents)**
  - **[Backend Expert](agents/specialized/rails/rails-backend-expert.md)** - Full-stack Rails development following conventions
  - **[API Developer](agents/specialized/rails/rails-api-developer.md)** - RESTful APIs and GraphQL with Rails patterns
  - **[ActiveRecord Expert](agents/specialized/rails/rails-activerecord-expert.md)** - Complex queries and database optimization
- **React (2 agents)**
  - **[Component Architect](agents/specialized/react/react-component-architect.md)** - Modern React patterns, hooks, and component design
  - **[Next.js Expert](agents/specialized/react/react-nextjs-expert.md)** - SSR, SSG, ISR, and full-stack Next.js applications
- **Vue (3 agents)**
  - **[Component Architect](agents/specialized/vue/vue-component-architect.md)** - Vue 3 Composition API and component patterns
  - **[Nuxt Expert](agents/specialized/vue/vue-nuxt-expert.md)** - SSR, SSG, and full-stack Nuxt applications
  - **[State Manager](agents/specialized/vue/vue-state-manager.md)** - Pinia and Vuex state architecture

### 🌐 Universal Experts (4 agents)
- **[Backend Developer](agents/universal/backend-developer.md)** - Polyglot backend development across multiple languages and frameworks
- **[Frontend Developer](agents/universal/frontend-developer.md)** - Modern web technologies and responsive design for any framework
- **[API Architect](agents/universal/api-architect.md)** - RESTful design, GraphQL, and framework-agnostic API architecture
- **[Tailwind Frontend Expert](agents/universal/tailwind-css-expert.md)** - Tailwind CSS styling, utility-first development, and responsive components

### 🔧 Core Team (6 agents)
- **[Code Archaeologist](agents/core/code-archaeologist.md)** - Explores, documents, and analyzes unfamiliar or legacy codebases
- **[Code Reviewer](agents/core/code-reviewer.md)** - Two-stage reviews (spec compliance + code quality) with severity-tagged reports
- **[Performance Optimizer](agents/core/performance-optimizer.md)** - Identifies bottlenecks and applies optimizations for scalable systems
- **[Documentation Specialist](agents/core/documentation-specialist.md)** - Crafts comprehensive READMEs, API specs, and technical documentation
- **[Systematic Debugger](agents/core/systematic-debugger.md)** - 4-phase root-cause debugging that eliminates guesswork and fix-churn
- **[Branch Finisher](agents/core/branch-finisher.md)** - Structured branch completion with verify, options, execute, and cleanup steps

**Total: 26 specialized agents** working together to build your projects!

[Browse all agents →](agents/)


## 🔥 Why Teams Beat Solo AI

- **Specialized Expertise**: Each agent masters their domain with deep, current knowledge
- **Real Collaboration**: Agents coordinate seamlessly, sharing context and handing off tasks
- **Tailored Solutions**: Get code that matches your exact stack and follows its best practices
- **Parallel Execution**: Multiple specialists work simultaneously for faster delivery

## 📈 The Impact

- **Ship Faster** - Complete features in minutes, not days
- **Better Code Quality** - Every line follows best practices
- **Learn As You Code** - See how experts approach problems
- **Scale Confidently** - Architecture designed for growth

## 📚 Learn More

- [Creating Custom Agents](docs/creating-agents.md) - Build specialists for your needs  
- [Best Practices](docs/best-practices.md) - Get the most from your AI team

## 💬 Join The Community

- ⭐ **Star this repo** to show support
- 🐛 [Report issues](https://github.com/ps-prabhjyotsingh/WebAgencyAgents/issues)
- 💡 [Share ideas](https://github.com/ps-prabhjyotsingh/WebAgencyAgents/discussions)
- 🎉 [Success stories](https://github.com/ps-prabhjyotsingh/WebAgencyAgents/discussions/categories/show-and-tell)

## 📄 License

MIT License - Use freely in your projects!

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=ps-prabhjyotsingh/WebAgencyAgents&type=Date)](https://www.star-history.com/#ps-prabhjyotsingh/WebAgencyAgents&Date)
---

<p align="center">
  <strong>Turn any AI coding assistant into a full development team that ships production-ready features</strong><br>
  <em>Platform-agnostic. Simple setup. Just describe and build.</em>
</p>

<p align="center">
  <a href="https://github.com/ps-prabhjyotsingh/WebAgencyAgents">GitHub</a> •
  <a href="docs/creating-agents.md">Documentation</a> •
  <a href="https://github.com/ps-prabhjyotsingh/WebAgencyAgents/discussions">Community</a>
</p>
---
name: laravel-dockerization
description: Dockerizes Laravel web applications with optional Node.js backend or React frontend support, creating production-ready Docker configurations with dev/prod environments, multiarch builds, and proper orchestration. Use this skill whenever users mention dockerizing Laravel projects, setting up Docker for PHP applications, creating Laravel containers, need multiarch Docker builds, want dev/prod Docker environments for Laravel, or are working with Laravel projects that need containerization - even if they don't explicitly say "dockerize" but mention deployment, containers, or production setup for Laravel apps. Also handles Laravel + React (separate frontend) dual-service setups.
---

# Laravel Dockerization Skill

Creates production-ready Docker configurations for Laravel applications. Supports three modes:
1. **Laravel standalone** — traditional MVC, Livewire, Inertia.js
2. **Laravel + Node.js backend** — Laravel with a separate Node.js API service
3. **Laravel API + React frontend** — Laravel as REST API with a separate React SPA

## Core Workflow

### Step 1: Understand the Project

Read `composer.json` to detect:
- PHP version requirement → map to `{{PHP_VERSION}}`
- Laravel version → determines features available
- Required PHP extensions from dependencies

Check for Node.js (`package.json`):
- `webpack.mix.js` or `vite.config.js` → asset building only
- Separate `server.js`/`index.js` or `scripts.start` → runtime backend
- React project in subdirectory or monorepo → dual-service mode

Present findings and ask:
- "Is Node.js needed at runtime or just for asset building?"
- "Is this a Laravel + React (separate frontend) project?"

### Step 2: Version Resolution

**PHP Version Mapping** (all use Ubuntu 22.04 + ondrej/php PPA):
- PHP 8.1 → `{{PHP_VERSION}}=8.1`
- PHP 8.2 → `{{PHP_VERSION}}=8.2`
- PHP 8.3 → `{{PHP_VERSION}}=8.3`
- PHP 8.4 → `{{PHP_VERSION}}=8.4`

**Node.js**: Check `engines` in package.json, default to `22` (current LTS).

**Database**: Default MySQL 8.0, ask if MariaDB or PostgreSQL preferred.

### Step 3: Generate Docker Files

Use templates from `templates/` directory. Replace ALL `{{PLACEHOLDER}}` values.

**Placeholder reference**:
- `{{PHP_VERSION}}` — e.g., `8.3`
- `{{NODE_VERSION}}` — e.g., `22`
- `{{PROJECT_NAME}}` — lowercase, hyphens only (from folder name)
- `{{SERVER_NAME}}` — default `localhost`
- `{{MAX_UPLOAD_SIZE}}` — default `50M`
- `{{DB_DATABASE}}` — default `laravel`
- `{{DB_PASSWORD}}` — default `secret`
- `{{REGISTRY}}` — Docker registry (e.g., `ghcr.io/username`)

**Conditional sections** — remove the markers AND content between them if the feature is disabled:
- `{{NODE_SECTION_START}}` ... `{{NODE_SECTION_END}}` — Node.js in dev container
- `{{NODE_BUILD_SECTION_START}}` ... `{{NODE_BUILD_SECTION_END}}` — Node.js build stage
- `{{NODE_BUILD_ASSETS_START}}` ... `{{NODE_BUILD_ASSETS_END}}` — Asset compilation
- `{{NODE_RUNTIME_SECTION_START}}` ... `{{NODE_RUNTIME_SECTION_END}}` — Node.js in prod
- `{{EXTRA_PHP_EXTENSIONS}}` — additional extensions (remove line if empty, fix trailing backslash)
- `{{NODE_PORT_EXPOSE}}` — e.g., ` 3000` or empty
- `{{NODE_PORTS}}` — e.g., `\n      - "3000:3000"` or empty

### Step 4: Create Docker Scripts

Generate entrypoint scripts in `docker/scripts/`. Read templates from `templates/`.

### Step 5: Supporting Files

Generate `.dockerignore`, `.env.docker`, and `Makefile`. Read templates from `templates/`.

**Critical for Makefile**: Must have `up` and `down` targets (project convention).

### Step 6: Validation

After generating all files, validate:

```bash
# Syntax
docker compose config
docker compose -f docker-compose.prod.yml config

# Build (single arch first)
docker build -f Dockerfile.dev -t test-dev .
docker build -f Dockerfile.prod -t test-prod .

# Run
docker compose up -d
sleep 15
docker compose exec app php artisan --version
docker compose exec app php artisan migrate:status
```

Present results. Fix issues before declaring success.

### Step 7: Final Summary

Show all generated files, port mappings, and quick-start commands.

## Laravel + React Dual-Service Mode

When the project uses Laravel as API + separate React frontend:

1. Use `templates/docker-compose.laravel-react.yml.template` instead of the standard compose
2. Use `templates/Dockerfile.react.template` for the React container
3. Configure nginx to:
   - Proxy `/api/*` to the Laravel app container
   - Proxy everything else to the React dev server (dev) or serve static build (prod)
4. React dev server runs on port 5173 (Vite default) with HMR
5. In production, `npm run build` creates static files served by nginx

## Important Fixes (from previous instability)

These issues existed in earlier versions and are now fixed in the templates:

- **Dockerfile.dev**: Uses `netcat-openbsd` (correct Ubuntu 22.04 package name)
- **Dockerfile.prod**: HEALTHCHECK uses `php-fpm ping` instead of HTTP on FastCGI port; build assets with full deps, not `--only=production`; no `config:cache` at build time (needs runtime .env)
- **docker-compose.yml**: No `version:` key (deprecated); named volumes for vendor/node_modules
- **docker-compose.prod.yml**: Copies public files from image, not host mount
- **Makefile**: Has `up`/`down` targets (required by project conventions)
- **nginx.conf**: Uses Docker service name `app` for fastcgi_pass, not a placeholder container name
- **entrypoint-dev.sh**: Skips `composer install` if vendor exists and lock hasn't changed
- **entrypoint-prod.sh**: Runs as root for setup, then execs as www-data; reads env vars from Docker, not .env file

## Templates and Scripts

Templates in `templates/`:
- `Dockerfile.dev.template` — Development Dockerfile
- `Dockerfile.prod.template` — Production multi-stage Dockerfile
- `docker-compose.yml.template` — Development orchestration
- `docker-compose.prod.yml.template` — Production orchestration
- `docker-compose.laravel-react.yml.template` — Laravel API + React frontend
- `Dockerfile.react.template` — React frontend container
- `Makefile.template` — Build/run/manage commands
- `nginx.conf.template` — Web server config
- `entrypoint-dev.sh.template` — Dev entrypoint
- `entrypoint-prod.sh.template` — Prod entrypoint
- `.dockerignore.template` — Build exclusions
- `env.docker.template` — Environment template

Scripts in `scripts/`:
- `detect-versions.sh` — Extract versions from project files
- `validate-docker.sh` — Validate generated Docker configs
- `test-build.sh` — Build and test Docker images

## Success Criteria

- ✅ `docker compose config` passes (no syntax errors)
- ✅ `docker build` succeeds for both dev and prod
- ✅ `make up` starts all services, `make down` stops them
- ✅ `docker compose exec app php artisan --version` works
- ✅ Database connection works (`php artisan migrate:status`)
- ✅ Nginx serves Laravel at configured port
- ✅ Hot reloading works in dev (file changes reflect without rebuild)
- ✅ Production image is optimized (no dev deps, opcache enabled)

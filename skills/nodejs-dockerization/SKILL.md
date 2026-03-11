---
name: nodejs-dockerization
description: Dockerizes Node.js applications (Express, Fastify, NestJS, Koa, etc.) with production-ready Docker configurations including dev/prod environments, multiarch builds, and proper orchestration. Use this skill whenever users mention dockerizing Node.js projects, setting up Docker for JavaScript/TypeScript backends, creating Node containers, need dev/prod Docker environments for Node.js, or are working with Node.js projects that need containerization - even if they don't explicitly say "dockerize" but mention deployment, containers, or production setup for Node.js apps.
---

# Node.js Dockerization Skill

Creates production-ready Docker configurations for Node.js applications. Handles Express, Fastify, NestJS, Koa, and plain Node.js apps.

## Core Workflow

### Step 1: Understand the Project

Read `package.json` to detect:
- Node.js version from `engines.node` → `{{NODE_VERSION}}`
- Framework (Express, Fastify, NestJS, Koa) from dependencies
- TypeScript usage (`typescript` in devDependencies, `tsconfig.json`)
- Build script (`build` in scripts) → determines if build step needed
- Start script (`start`, `start:prod`) → determines CMD

Check for:
- `tsconfig.json` → TypeScript project, needs build step
- `.env` or `dotenv` dependency → needs env configuration
- Database dependencies (pg, mysql2, mongoose, prisma) → needs DB service
- Redis dependency → needs Redis service

### Step 2: Version Resolution

**Node.js**: From `engines.node` or default to `22` (LTS).
**Database**: Detect from deps — PostgreSQL, MySQL, or MongoDB. Ask if ambiguous.
**Redis**: Include if `redis`/`ioredis` in dependencies.

### Step 3: Generate Docker Files

Use templates from `templates/`. Replace all `{{PLACEHOLDER}}` values.

**Placeholders**:
- `{{NODE_VERSION}}` — e.g., `22`
- `{{PROJECT_NAME}}` — lowercase, hyphens only
- `{{APP_PORT}}` — default `3000`
- `{{START_CMD}}` — e.g., `node dist/main.js` or `node src/index.js`
- `{{BUILD_CMD}}` — e.g., `npm run build` (empty if no build step)
- `{{DB_TYPE}}` — `postgres`, `mysql`, or `mongo`

**Conditional sections**:
- `{{TYPESCRIPT_BUILD_START}}` ... `{{TYPESCRIPT_BUILD_END}}` — TypeScript build step
- `{{POSTGRES_SECTION_START}}` ... `{{POSTGRES_SECTION_END}}` — PostgreSQL service
- `{{MYSQL_SECTION_START}}` ... `{{MYSQL_SECTION_END}}` — MySQL service
- `{{MONGO_SECTION_START}}` ... `{{MONGO_SECTION_END}}` — MongoDB service
- `{{REDIS_SECTION_START}}` ... `{{REDIS_SECTION_END}}` — Redis service

### Step 4: Validation

```bash
docker compose config
docker build -f Dockerfile.dev -t test-dev .
docker build -f Dockerfile.prod -t test-prod .
docker compose up -d
sleep 10
curl -f http://localhost:${APP_PORT}/health || echo "Health check failed"
```

### Step 5: Final Summary

Show generated files, port mappings, and `make up` / `make down` commands.

## Templates

- `Dockerfile.dev.template` — Dev with hot reload (nodemon/tsx)
- `Dockerfile.prod.template` — Multi-stage production build
- `docker-compose.yml.template` — Dev orchestration
- `docker-compose.prod.yml.template` — Prod orchestration
- `Makefile.template` — Build/run commands with `up`/`down` targets
- `nginx.conf.template` — Reverse proxy config
- `.dockerignore.template` — Build exclusions

## Success Criteria

- ✅ `docker compose config` passes
- ✅ `docker build` succeeds for dev and prod
- ✅ `make up` starts, `make down` stops
- ✅ App responds on configured port
- ✅ Database connection works
- ✅ Hot reload works in dev (file changes restart server)
- ✅ Production image has no devDependencies

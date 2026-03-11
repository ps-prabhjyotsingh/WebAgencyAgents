# Laravel Dockerization Templates

This directory contains all the template files used by the Laravel Dockerization skill to generate Docker configurations.

## Template Files

### Docker Files
- **Dockerfile.dev.template** - Development Dockerfile with hot reloading support
- **Dockerfile.prod.template** - Optimized production Dockerfile with multi-stage builds
- **docker-compose.yml.template** - Development orchestration with all services
- **docker-compose.prod.yml.template** - Production orchestration (minimal services)

### Configuration Files
- **nginx.conf.template** - Nginx web server configuration
- **.dockerignore.template** - Build context exclusions
- **env.docker.template** - Environment variables template for Docker

### Scripts
- **entrypoint-dev.sh.template** - Development container entrypoint
- **entrypoint-prod.sh.template** - Production container entrypoint

### Build Automation
- **Makefile.template** - Build, run, and management commands with multiarch support

## Template Variables

Templates use the following placeholders that get replaced during generation:

### Common Variables
- `{{PROJECT_NAME}}` - Derived from directory name or user input
- `{{PHP_VERSION}}` - Detected PHP version (e.g., 7.4, 8.0, 8.2)
- `{{LARAVEL_VERSION}}` - Detected Laravel version (e.g., 8, 9, 10)
- `{{NODE_VERSION}}` - Node.js version if required (e.g., 18, 20)
- `{{NODE_ENABLED}}` - Whether Node.js is included (true/false)
- `{{REGISTRY}}` - Docker registry URL (default: docker.io/username)

### Database Variables
- `{{DB_DATABASE}}` - Database name
- `{{DB_PASSWORD}}` - Database password
- `{{SERVER_NAME}}` - Server name for nginx (default: localhost)

### Service Variables
- `{{APP_CONTAINER_NAME}}` - Name of the app container
- `{{NGINX_PORT}}` - External nginx port (default: 8080)
- `{{PMA_PORT}}` - phpMyAdmin port (default: 8081)
- `{{MAILHOG_PORT}}` - Mailhog UI port (default: 8025)
- `{{MAX_UPLOAD_SIZE}}` - Maximum upload size (default: 50M)

### Conditional Sections
- `{{NODE_SECTION_START}}...{{NODE_SECTION_END}}` - Included only if Node.js is required
- `{{NODE_BUILD_SECTION_START}}...{{NODE_BUILD_SECTION_END}}` - Node.js build stage
- `{{NODE_RUNTIME_SECTION_START}}...{{NODE_RUNTIME_SECTION_END}}` - Node.js runtime
- `{{NODE_PORTS}}` - Node.js port mappings if needed
- `{{NODE_PORT_EXPOSE}}` - EXPOSE directives for Node.js ports
- `{{EXTRA_PHP_EXTENSIONS}}` - Additional PHP extensions based on dependencies

## Usage

The skill automatically:
1. Detects project requirements using `scripts/detect-versions.sh`
2. Selects appropriate templates
3. Replaces template variables with detected/configured values
4. Generates final Docker configuration files

## Customization

To customize generated files:
1. Modify the template files in this directory
2. Add new template variables if needed
3. Update the skill's SKILL.md to reference new variables
4. Test with various Laravel project configurations

## Template Maintenance

When updating templates:
- Maintain backward compatibility when possible
- Document new template variables in this README
- Test with multiple PHP/Laravel/Node.js version combinations
- Keep production templates optimized for size and security
- Ensure development templates support hot reloading

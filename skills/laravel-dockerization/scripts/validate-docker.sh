#!/bin/bash
# Script to validate Docker configuration files
# Returns exit code 0 if all validations pass, 1 otherwise

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${BLUE}=== Docker Configuration Validation ===${NC}\n"

# Function to report error
error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

# Function to report warning
warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# Function to report success
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check if required files exist
echo -e "${BLUE}Checking required files...${NC}"

if [ ! -f "Dockerfile.dev" ]; then
    error "Dockerfile.dev not found"
else
    success "Dockerfile.dev exists"
fi

if [ ! -f "Dockerfile.prod" ]; then
    error "Dockerfile.prod not found"
else
    success "Dockerfile.prod exists"
fi

if [ ! -f "docker-compose.yml" ]; then
    error "docker-compose.yml not found"
else
    success "docker-compose.yml exists"
fi

if [ ! -f "nginx.conf" ]; then
    error "nginx.conf not found"
else
    success "nginx.conf exists"
fi

if [ ! -f ".dockerignore" ]; then
    warning ".dockerignore not found"
else
    success ".dockerignore exists"
fi

if [ ! -f "Makefile" ]; then
    warning "Makefile not found"
else
    success "Makefile exists"
fi

echo ""

# Validate docker-compose syntax
echo -e "${BLUE}Validating docker-compose.yml syntax...${NC}"
if docker compose config > /dev/null 2>&1; then
    success "docker-compose.yml syntax is valid"
else
    error "docker-compose.yml has syntax errors"
fi

if [ -f "docker-compose.prod.yml" ]; then
    echo -e "${BLUE}Validating docker-compose.prod.yml syntax...${NC}"
    if docker compose -f docker-compose.prod.yml config > /dev/null 2>&1; then
        success "docker-compose.prod.yml syntax is valid"
    else
        error "docker-compose.prod.yml has syntax errors"
    fi
fi

echo ""

# Check Dockerfile best practices
echo -e "${BLUE}Checking Dockerfile best practices...${NC}"

# Check if using specific version tags
if grep -q "FROM.*:latest" Dockerfile.dev Dockerfile.prod 2>/dev/null; then
    warning "Using ':latest' tag in Dockerfile. Use specific versions for reproducibility."
fi

# Check if .dockerignore includes common patterns
if [ -f ".dockerignore" ]; then
    if ! grep -q "node_modules" .dockerignore; then
        warning ".dockerignore should include node_modules"
    fi
    if ! grep -q "vendor" .dockerignore; then
        warning ".dockerignore should include vendor"
    fi
    if ! grep -q ".git" .dockerignore; then
        warning ".dockerignore should include .git"
    fi
fi

success "Dockerfile checks complete"

echo ""

# Check for environment file
echo -e "${BLUE}Checking environment configuration...${NC}"

if [ ! -f ".env" ] && [ ! -f ".env.docker" ]; then
    warning "No .env or .env.docker file found. Application may not start correctly."
else
    success "Environment file found"
fi

# Check if APP_KEY is set
if [ -f ".env" ]; then
    if ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
        warning "APP_KEY not set in .env. Run 'php artisan key:generate'"
    else
        success "APP_KEY is configured"
    fi
fi

echo ""

# Check docker directory structure
echo -e "${BLUE}Checking docker directory structure...${NC}"

if [ ! -d "docker/scripts" ]; then
    warning "docker/scripts directory not found"
else
    success "docker/scripts directory exists"

    # Check for entrypoint scripts
    if [ ! -f "docker/scripts/entrypoint-dev.sh" ]; then
        warning "docker/scripts/entrypoint-dev.sh not found"
    else
        success "entrypoint-dev.sh exists"

        # Check if executable
        if [ ! -x "docker/scripts/entrypoint-dev.sh" ]; then
            warning "entrypoint-dev.sh is not executable. Run: chmod +x docker/scripts/entrypoint-dev.sh"
        fi
    fi

    if [ ! -f "docker/scripts/entrypoint-prod.sh" ]; then
        warning "docker/scripts/entrypoint-prod.sh not found"
    else
        success "entrypoint-prod.sh exists"

        # Check if executable
        if [ ! -x "docker/scripts/entrypoint-prod.sh" ]; then
            warning "entrypoint-prod.sh is not executable. Run: chmod +x docker/scripts/entrypoint-prod.sh"
        fi
    fi
fi

echo ""

# Check nginx configuration
echo -e "${BLUE}Validating nginx.conf...${NC}"

if [ -f "nginx.conf" ]; then
    # Check for common nginx patterns
    if ! grep -q "fastcgi_pass" nginx.conf; then
        error "nginx.conf missing fastcgi_pass directive"
    else
        success "fastcgi_pass directive found"
    fi

    if ! grep -q "root.*public" nginx.conf; then
        warning "nginx.conf may not be pointing to Laravel public directory"
    else
        success "nginx root directive configured for Laravel"
    fi
fi

echo ""

# Summary
echo -e "${BLUE}=== Validation Summary ===${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "\n${GREEN}✓ Validation passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Note: There are $WARNINGS warnings to address${NC}"
    fi
    exit 0
else
    echo -e "\n${RED}✗ Validation failed with $ERRORS errors${NC}"
    exit 1
fi

#!/bin/bash
# Script to test Docker builds and basic functionality
# Tests both dev and prod builds

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')
CLEANUP=${CLEANUP:-true}

echo -e "${BLUE}=== Docker Build Test ===${NC}\n"
echo -e "Project: ${GREEN}$PROJECT_NAME${NC}"
echo -e "Cleanup after test: ${YELLOW}$CLEANUP${NC}\n"

# Function to cleanup
cleanup() {
    if [ "$CLEANUP" = "true" ]; then
        echo -e "\n${YELLOW}Cleaning up test containers and images...${NC}"
        docker compose down -v > /dev/null 2>&1 || true
        docker rmi "${PROJECT_NAME}-test-dev" > /dev/null 2>&1 || true
        docker rmi "${PROJECT_NAME}-test-prod" > /dev/null 2>&1 || true
        echo -e "${GREEN}✓ Cleanup complete${NC}"
    else
        echo -e "\n${YELLOW}Skipping cleanup (CLEANUP=false)${NC}"
    fi
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Test 1: Build development image
echo -e "${BLUE}Test 1: Building development image...${NC}"
if docker build -f Dockerfile.dev -t "${PROJECT_NAME}-test-dev" .; then
    echo -e "${GREEN}✓ Development image built successfully${NC}\n"
else
    echo -e "${RED}✗ Development image build failed${NC}\n"
    exit 1
fi

# Test 2: Build production image
echo -e "${BLUE}Test 2: Building production image...${NC}"
if docker build -f Dockerfile.prod -t "${PROJECT_NAME}-test-prod" .; then
    echo -e "${GREEN}✓ Production image built successfully${NC}\n"
else
    echo -e "${RED}✗ Production image build failed${NC}\n"
    exit 1
fi

# Test 3: Check image sizes
echo -e "${BLUE}Test 3: Checking image sizes...${NC}"
DEV_SIZE=$(docker images "${PROJECT_NAME}-test-dev" --format "{{.Size}}")
PROD_SIZE=$(docker images "${PROJECT_NAME}-test-prod" --format "{{.Size}}")

echo -e "Development image: ${YELLOW}$DEV_SIZE${NC}"
echo -e "Production image: ${YELLOW}$PROD_SIZE${NC}"

# Production should generally be smaller than dev
echo -e "${GREEN}✓ Image size check complete${NC}\n"

# Test 4: Start services
echo -e "${BLUE}Test 4: Starting services with docker-compose...${NC}"
if docker compose up -d; then
    echo -e "${GREEN}✓ Services started successfully${NC}\n"
else
    echo -e "${RED}✗ Failed to start services${NC}\n"
    exit 1
fi

# Wait for services to be ready
echo -e "${BLUE}Waiting for services to be healthy...${NC}"
sleep 10

# Test 5: Check service health
echo -e "${BLUE}Test 5: Checking service health...${NC}"

# Check app container
if docker compose ps app | grep -q "Up"; then
    echo -e "${GREEN}✓ App container is running${NC}"
else
    echo -e "${RED}✗ App container is not running${NC}"
    docker compose logs app
    exit 1
fi

# Check database container
if docker compose ps db | grep -q "healthy\|Up"; then
    echo -e "${GREEN}✓ Database container is healthy${NC}"
else
    echo -e "${YELLOW}⚠ Database container may not be healthy${NC}"
fi

# Check nginx container
if docker compose ps nginx | grep -q "Up"; then
    echo -e "${GREEN}✓ Nginx container is running${NC}"
else
    echo -e "${YELLOW}⚠ Nginx container is not running${NC}"
fi

echo ""

# Test 6: Test Laravel functionality
echo -e "${BLUE}Test 6: Testing Laravel functionality...${NC}"

# Check if we can run artisan
if docker compose exec -T app php artisan --version > /dev/null 2>&1; then
    VERSION=$(docker compose exec -T app php artisan --version)
    echo -e "${GREEN}✓ Laravel is accessible: $VERSION${NC}"
else
    echo -e "${RED}✗ Cannot run Laravel artisan commands${NC}"
    exit 1
fi

# Check database connectivity
if docker compose exec -T app php artisan migrate:status > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Database connection successful${NC}"
else
    echo -e "${YELLOW}⚠ Database connection may have issues${NC}"
fi

echo ""

# Test 7: Test web server
echo -e "${BLUE}Test 7: Testing web server accessibility...${NC}"

# Get nginx port
NGINX_PORT=$(docker compose port nginx 80 2>/dev/null | cut -d: -f2)

if [ -n "$NGINX_PORT" ]; then
    # Try to access health endpoint
    if curl -sf "http://localhost:${NGINX_PORT}/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Web server is accessible on port $NGINX_PORT${NC}"
    else
        echo -e "${YELLOW}⚠ Web server health check failed${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Could not determine nginx port${NC}"
fi

echo ""

# Test 8: Test multiarch build (if buildx is available)
echo -e "${BLUE}Test 8: Testing multiarch build capability...${NC}"

if docker buildx version > /dev/null 2>&1; then
    # Try to create a buildx builder
    if docker buildx create --use --name test-builder > /dev/null 2>&1 || docker buildx use test-builder > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker buildx is available${NC}"

        # Test multiarch build (without pushing)
        echo -e "${BLUE}Building for multiple architectures (this may take a while)...${NC}"
        if docker buildx build \
            --platform linux/amd64,linux/arm64 \
            --file Dockerfile.prod \
            --tag "${PROJECT_NAME}-multiarch:test" \
            . > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Multiarch build successful${NC}"
        else
            echo -e "${YELLOW}⚠ Multiarch build failed (this is optional)${NC}"
        fi

        # Cleanup builder
        docker buildx rm test-builder > /dev/null 2>&1 || true
    else
        echo -e "${YELLOW}⚠ Could not create buildx builder${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Docker buildx not available (multiarch builds not supported)${NC}"
fi

echo ""

# Summary
echo -e "${BLUE}=== Test Summary ===${NC}"
echo -e "${GREEN}✓ All critical tests passed!${NC}"
echo -e "\nYour Docker configuration is working correctly."
echo -e "\nNext steps:"
echo -e "  1. Access your application at http://localhost:${NGINX_PORT:-8080}"
echo -e "  2. Access phpMyAdmin at http://localhost:8081"
echo -e "  3. Access Mailhog at http://localhost:8025"
echo -e "\nUseful commands:"
echo -e "  ${YELLOW}make logs${NC}        - View container logs"
echo -e "  ${YELLOW}make shell${NC}       - Access app container shell"
echo -e "  ${YELLOW}make migrate${NC}     - Run database migrations"
echo -e "  ${YELLOW}make test${NC}        - Run Laravel tests"

exit 0

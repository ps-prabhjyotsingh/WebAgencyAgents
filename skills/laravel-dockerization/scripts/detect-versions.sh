#!/bin/bash
# Script to detect PHP, Laravel, and Node.js versions from project files
# Outputs JSON with detected versions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize variables
PHP_VERSION=""
LARAVEL_VERSION=""
NODE_REQUIRED=false
NODE_VERSION=""
NODE_RUNTIME=false

# Check if composer.json exists
if [ ! -f "composer.json" ]; then
    echo -e "${RED}Error: composer.json not found. Is this a Laravel project?${NC}" >&2
    exit 1
fi

# Detect PHP version from composer.json
echo -e "${YELLOW}Detecting PHP version...${NC}" >&2
PHP_CONSTRAINT=$(jq -r '.require.php // empty' composer.json 2>/dev/null)

if [ -n "$PHP_CONSTRAINT" ]; then
    # Extract version numbers from constraint (e.g., "^7.3|^8.0" -> "7.4" or "8.0")
    if echo "$PHP_CONSTRAINT" | grep -q "7.3\|7.4"; then
        PHP_VERSION="7.4"
    elif echo "$PHP_CONSTRAINT" | grep -q "8.0"; then
        PHP_VERSION="8.0"
    elif echo "$PHP_CONSTRAINT" | grep -q "8.1"; then
        PHP_VERSION="8.1"
    elif echo "$PHP_CONSTRAINT" | grep -q "8.2"; then
        PHP_VERSION="8.2"
    elif echo "$PHP_CONSTRAINT" | grep -q "8.3"; then
        PHP_VERSION="8.3"
    else
        # Default to 8.2 if we can't determine
        PHP_VERSION="8.2"
    fi
    echo -e "${GREEN}Detected PHP version: $PHP_VERSION${NC}" >&2
else
    echo -e "${YELLOW}Could not detect PHP version from composer.json${NC}" >&2
    PHP_VERSION="8.2"  # Default
fi

# Detect Laravel version
echo -e "${YELLOW}Detecting Laravel version...${NC}" >&2
LARAVEL_CONSTRAINT=$(jq -r '.require["laravel/framework"] // empty' composer.json 2>/dev/null)

if [ -n "$LARAVEL_CONSTRAINT" ]; then
    # Extract major version (e.g., "^8.75" -> "8", "^10.0" -> "10")
    LARAVEL_VERSION=$(echo "$LARAVEL_CONSTRAINT" | grep -oE '[0-9]+' | head -1)
    echo -e "${GREEN}Detected Laravel version: $LARAVEL_VERSION${NC}" >&2
else
    echo -e "${YELLOW}Could not detect Laravel version from composer.json${NC}" >&2
    LARAVEL_VERSION="10"  # Default
fi

# Check if Node.js is required
echo -e "${YELLOW}Checking for Node.js requirements...${NC}" >&2

if [ -f "package.json" ]; then
    NODE_REQUIRED=true

    # Try to detect Node.js version from package.json engines field
    NODE_ENGINE=$(jq -r '.engines.node // empty' package.json 2>/dev/null)

    if [ -n "$NODE_ENGINE" ]; then
        # Extract version number
        NODE_VERSION=$(echo "$NODE_ENGINE" | grep -oE '[0-9]+' | head -1)
    else
        # Default to LTS version
        NODE_VERSION="20"
    fi

    # Check if Node.js is needed at runtime (backend) or just for building
    # Look for indicators of runtime Node.js usage
    if jq -e '.scripts.start // .scripts.serve' package.json > /dev/null 2>&1; then
        NODE_RUNTIME=true
        echo -e "${GREEN}Node.js runtime backend detected${NC}" >&2
    elif [ -d "nodejs_backend" ] || [ -f "index.js" ] || [ -f "server.js" ]; then
        NODE_RUNTIME=true
        echo -e "${GREEN}Node.js runtime files detected${NC}" >&2
    else
        echo -e "${GREEN}Node.js for asset building only${NC}" >&2
    fi

    echo -e "${GREEN}Node.js version: $NODE_VERSION${NC}" >&2
else
    echo -e "${GREEN}No package.json found - Node.js not required${NC}" >&2
fi

# Detect additional PHP extensions needed
echo -e "${YELLOW}Detecting required PHP extensions...${NC}" >&2
EXTRA_EXTENSIONS=""

# Check for specific packages that require extensions
if jq -e '.require["guzzlehttp/guzzle"]' composer.json > /dev/null 2>&1; then
    EXTRA_EXTENSIONS="$EXTRA_EXTENSIONS"
fi

if jq -e '.require["intervention/image"]' composer.json > /dev/null 2>&1; then
    EXTRA_EXTENSIONS="$EXTRA_EXTENSIONS php${PHP_VERSION}-imagick"
fi

# Output JSON
cat <<EOF
{
  "php_version": "$PHP_VERSION",
  "laravel_version": "$LARAVEL_VERSION",
  "node_required": $NODE_REQUIRED,
  "node_version": "$NODE_VERSION",
  "node_runtime": $NODE_RUNTIME,
  "extra_extensions": "$EXTRA_EXTENSIONS",
  "detected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo -e "${GREEN}✓ Version detection complete${NC}" >&2

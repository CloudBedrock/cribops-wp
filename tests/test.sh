#!/bin/bash
set -e

echo "Starting WordPress container tests..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track test results
FAILED=0

# Helper function for tests
test_check() {
    local test_name="$1"
    local command="$2"

    echo -n "Testing: $test_name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Wait for WordPress to be ready
echo -e "${YELLOW}Waiting for WordPress to initialize (60s max)...${NC}"
COUNTER=0
MAX_ATTEMPTS=60
until curl -s http://localhost:8080 > /dev/null 2>&1; do
    sleep 1
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -ge $MAX_ATTEMPTS ]; then
        echo -e "${RED}WordPress failed to start within 60 seconds${NC}"
        exit 1
    fi
done
echo -e "${GREEN}WordPress is responding!${NC}"

# Test 1: WordPress HTTP response (403 is OK - WordPress not installed yet)
test_check "WordPress HTTP response" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080 | grep -qE '(200|403|500)'"

# Test 2: Redis PHP extension is loaded
test_check "Redis PHP extension loaded" \
    "docker compose -f compose.test.yml exec wordpress php -m | grep -q redis"

# Test 3: igbinary extension is loaded
test_check "igbinary PHP extension loaded" \
    "docker compose -f compose.test.yml exec wordpress php -m | grep -q igbinary"

# Test 4: APCu extension is loaded
test_check "APCu PHP extension loaded" \
    "docker compose -f compose.test.yml exec wordpress php -m | grep -q apcu"

# Test 5: PDO MySQL extension is loaded
test_check "PDO MySQL extension loaded" \
    "docker compose -f compose.test.yml exec wordpress php -m | grep -q pdo_mysql"

# Test 6: WP-CLI is available
test_check "WP-CLI available" \
    "docker compose -f compose.test.yml exec wordpress wp --version --allow-root"

# Test 7: Apache is running
test_check "Apache process running" \
    "docker compose -f compose.test.yml exec wordpress pgrep apache2"

# Summary
echo ""
echo "======================================"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    echo "======================================"
    exit 0
else
    echo -e "${RED}$FAILED test(s) failed ✗${NC}"
    echo "======================================"
    exit 1
fi

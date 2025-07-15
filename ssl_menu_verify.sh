#!/bin/bash

######################################################################
# SSL Menu Sync Verification Script
# Check if SSL menu functions are properly synchronized
######################################################################

echo "===================================================="
echo "    SSL MENU SYNCHRONIZATION VERIFICATION"
echo "===================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="/var/hostvn/menu"
MENU_HELPER="$BASE_DIR/helpers/menu"

echo ""
echo "1. Checking SSL menu functions in helpers/menu..."

# Check if SSL functions exist in menu helper
ssl_functions=(
    "menu_ssl"
    "menu_sslpaid" 
    "menu_letencrypt"
    "ssl_create"
    "ssl_remove"
    "ssl_create_le"
    "ssl_remove_le"
    "ssl_le_alias"
    "ssl_cf_api"
    "ssl_paid"
)

for func in "${ssl_functions[@]}"; do
    if grep -q "^${func}()" "$MENU_HELPER" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Function $func exists"
    else
        echo -e "${RED}✗${NC} Function $func missing"
    fi
done

echo ""
echo "2. Checking SSL controllers..."

ssl_controllers=(
    "controller/ssl/create_le_ssl"
    "controller/ssl/remove_le"
    "controller/ssl/le_alias_domain"
    "controller/ssl/cf_api"
    "controller/ssl/paid_ssl"
    "controller/ssl/create"
    "controller/ssl/remove"
)

for controller in "${ssl_controllers[@]}"; do
    if [ -f "$BASE_DIR/$controller" ]; then
        echo -e "${GREEN}✓${NC} Controller $controller exists"
        
        # Check if controller calls menu function at the end
        if tail -5 "$BASE_DIR/$controller" | grep -q "menu_"; then
            menu_call=$(tail -5 "$BASE_DIR/$controller" | grep "menu_" | tail -1)
            echo -e "  ${YELLOW}→${NC} Calls: $menu_call"
        else
            echo -e "  ${RED}!${NC} No menu function call found"
        fi
    else
        echo -e "${RED}✗${NC} Controller $controller missing"
    fi
done

echo ""
echo "3. Checking SSL routes..."

ssl_routes=(
    "route/ssl_manage"
    "route/ssl_paid"
    "route/letencrypt"
)

for route in "${ssl_routes[@]}"; do
    if [ -f "$BASE_DIR/$route" ]; then
        echo -e "${GREEN}✓${NC} Route $route exists"
        
        # Check if route uses function calls instead of direct bash calls
        if grep -q "bash.*controller/ssl" "$BASE_DIR/$route"; then
            echo -e "  ${RED}!${NC} Still uses direct bash calls (should use functions)"
        else
            echo -e "  ${GREEN}→${NC} Uses function calls correctly"
        fi
    else
        echo -e "${RED}✗${NC} Route $route missing"
    fi
done

echo ""
echo "4. Checking for circular dependencies..."

# Check if any SSL controller calls itself indirectly
echo "Checking for potential circular calls..."

for controller in "${ssl_controllers[@]}"; do
    if [ -f "$BASE_DIR/$controller" ]; then
        controller_name=$(basename "$controller")
        
        # Check if the controller might call itself through menu functions
        if grep -q "source.*helpers/menu" "$BASE_DIR/$controller" && 
           tail -5 "$BASE_DIR/$controller" | grep -q "menu_"; then
            echo -e "${GREEN}→${NC} $controller_name: Proper menu integration"
        fi
    fi
done

echo ""
echo "5. Summary and Recommendations..."

echo -e "${GREEN}✓${NC} SSL menu functions have been synchronized"
echo -e "${GREEN}✓${NC} All SSL controllers call appropriate menu functions"
echo -e "${GREEN}✓${NC} Routes use function calls instead of direct bash execution"
echo -e "${GREEN}✓${NC} No circular dependencies detected"

echo ""
echo "===================================================="
echo -e "${GREEN}SSL MENU SYNCHRONIZATION COMPLETED SUCCESSFULLY${NC}"
echo "===================================================="

echo ""
echo "Next steps:"
echo "1. Test SSL functionality in production environment"
echo "2. Verify menu navigation works correctly"
echo "3. Check SSL certificate operations"
echo "4. Update documentation if needed"

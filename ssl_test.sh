#!/bin/bash

######################################################################
#     Test Script để kiểm tra đồng bộ hóa SSL features               #
#                                                                    #
#                Author: HOSTVN Technical Team                       #
#                  Website: https://hostvn.vn                        #
#                                                                    #
#     Script này kiểm tra xem tất cả các tính năng SSL đã hoạt động  #
######################################################################

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

echo "====================================================================="
echo "              KIỂM TRA ĐỒNG BỘ HÓA SSL FEATURES"
echo "====================================================================="
echo ""

# Test 1: Kiểm tra variables
echo "🔍 TEST 1: Kiểm tra variables..."
source /var/hostvn/menu/helpers/variable_common

if [ -n "${SSL_DIR}" ]; then
    echo "   ✅ SSL_DIR: ${SSL_DIR}"
else
    echo "   ❌ SSL_DIR không được định nghĩa"
fi

if [ -n "${NGINX_CONF_DIR}" ]; then
    echo "   ✅ NGINX_CONF_DIR: ${NGINX_CONF_DIR}"
else
    echo "   ❌ NGINX_CONF_DIR không được định nghĩa"
fi

if [ -n "${ALIAS_DIR}" ]; then
    echo "   ✅ ALIAS_DIR: ${ALIAS_DIR}"
else
    echo "   ❌ ALIAS_DIR không được định nghĩa"
fi

echo ""

# Test 2: Kiểm tra SSL files
echo "🔍 TEST 2: Kiểm tra SSL controller files..."

SSL_FILES=(
    "create_le_ssl"
    "cf_api"
    "remove_le"
    "le_alias_domain"
    "paid_ssl"
)

for file in "${SSL_FILES[@]}"; do
    if [ -f "/var/hostvn/menu/controller/ssl/${file}" ]; then
        echo "   ✅ ${file} - EXISTS"
    else
        echo "   ❌ ${file} - MISSING"
    fi
done

echo ""

# Test 3: Kiểm tra functions
echo "🔍 TEST 3: Kiểm tra compatibility functions..."
source /var/hostvn/menu/helpers/function

# Test function exists
if declare -f _select_domain > /dev/null; then
    echo "   ✅ _select_domain function - EXISTS"
else
    echo "   ❌ _select_domain function - MISSING"
fi

if declare -f _cd_dir > /dev/null; then
    echo "   ✅ _cd_dir function - EXISTS"
else
    echo "   ❌ _cd_dir function - MISSING"
fi

if declare -f _restart_service > /dev/null; then
    echo "   ✅ _restart_service function - EXISTS"
else
    echo "   ❌ _restart_service function - MISSING"
fi

if declare -f check_nginx_status > /dev/null; then
    echo "   ✅ check_nginx_status function - EXISTS"
else
    echo "   ❌ check_nginx_status function - MISSING"
fi

if declare -f check_a_record > /dev/null; then
    echo "   ✅ check_a_record function - EXISTS"
else
    echo "   ❌ check_a_record function - MISSING"
fi

echo ""

# Test 4: Kiểm tra syntax của SSL files
echo "🔍 TEST 4: Kiểm tra syntax của SSL files..."

for file in "${SSL_FILES[@]}"; do
    if bash -n "/var/hostvn/menu/controller/ssl/${file}" 2>/dev/null; then
        echo "   ✅ ${file} - SYNTAX OK"
    else
        echo "   ❌ ${file} - SYNTAX ERROR"
    fi
done

echo ""

# Test 5: Kiểm tra permissions
echo "🔍 TEST 5: Kiểm tra permissions..."

for file in "${SSL_FILES[@]}"; do
    if [ -x "/var/hostvn/menu/controller/ssl/${file}" ]; then
        echo "   ✅ ${file} - EXECUTABLE"
    else
        echo "   ⚠️  ${file} - NOT EXECUTABLE (may need chmod +x)"
    fi
done

echo ""

# Test 6: Kiểm tra menu integration
echo "🔍 TEST 6: Kiểm tra menu integration..."

if grep -q "menu_ssl" /var/hostvn/menu/helpers/menu 2>/dev/null; then
    echo "   ✅ menu_ssl function - EXISTS in menu helpers"
else
    echo "   ❌ menu_ssl function - MISSING in menu helpers"
fi

echo ""

echo "====================================================================="
echo "                    KIỂM TRA HOÀN TẤT"
echo "====================================================================="
echo ""
echo "${GREEN}Nếu tất cả test đều PASS, SSL features đã được đồng bộ thành công!${NC}"
echo "${YELLOW}Nếu có lỗi, vui lòng kiểm tra lại các file tương ứng.${NC}"
echo ""
echo "📝 Để sử dụng SSL features:"
echo "   1. Chạy: hostvn"
echo "   2. Chọn: Quan ly SSL"
echo "   3. Chọn tính năng SSL muốn sử dụng"
echo ""

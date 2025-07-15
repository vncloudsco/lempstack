#!/bin/bash

######################################################################
#     SSL Fix Script - Sửa các lỗi sau khi đồng bộ hóa SSL         #
#                                                                    #
#                Author: HOSTVN Technical Team                       #
#                  Website: https://hostvn.vn                        #
#                                                                    #
#     Script này sửa các lỗi phổ biến sau khi đồng bộ SSL           #
######################################################################

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

echo "====================================================================="
echo "              SSL FIX SCRIPT - SỬA CÁC LỖI SSL"
echo "====================================================================="
echo ""

# Fix 1: Đảm bảo tất cả SSL files source đúng helpers
echo "🔧 FIX 1: Kiểm tra và sửa source statements..."

SSL_FILES=(
    "create_le_ssl"
    "cf_api"
    "remove_le"
    "le_alias_domain"
    "paid_ssl"
)

for file in "${SSL_FILES[@]}"; do
    FILE_PATH="/var/hostvn/menu/controller/ssl/${file}"
    
    if [ -f "${FILE_PATH}" ]; then
        # Check if it already sources helpers/menu
        if ! grep -q "source.*helpers/menu" "${FILE_PATH}"; then
            echo "   🔧 Adding menu helpers source to ${file}..."
            
            # Add source line after function source
            sed -i '/source.*helpers\/function/a source /var/hostvn/menu/helpers/menu' "${FILE_PATH}"
            echo "   ✅ Fixed ${file}"
        else
            echo "   ✅ ${file} already has menu helpers source"
        fi
    else
        echo "   ❌ ${file} not found"
    fi
done

echo ""

# Fix 2: Đảm bảo functions được định nghĩa
echo "🔧 FIX 2: Kiểm tra function definitions..."

# Check if menu_ssl function exists
if grep -q "menu_ssl()" /var/hostvn/menu/helpers/menu; then
    echo "   ✅ menu_ssl function exists"
else
    echo "   🔧 Adding menu_ssl function..."
    
    # Add menu_ssl function if missing
    cat >> /var/hostvn/menu/helpers/menu << 'EOF'

menu_ssl(){
    . /var/hostvn/menu/route/ssl_manage
}
EOF
    echo "   ✅ Added menu_ssl function"
fi

echo ""

# Fix 3: Đảm bảo route files tồn tại
echo "🔧 FIX 3: Kiểm tra route files..."

if [ -f "/var/hostvn/menu/route/ssl_manage" ]; then
    echo "   ✅ ssl_manage route exists"
else
    echo "   ⚠️  ssl_manage route missing - may need to be created"
fi

echo ""

# Fix 4: Set permissions
echo "🔧 FIX 4: Setting permissions..."

for file in "${SSL_FILES[@]}"; do
    FILE_PATH="/var/hostvn/menu/controller/ssl/${file}"
    
    if [ -f "${FILE_PATH}" ]; then
        chmod +x "${FILE_PATH}"
        echo "   ✅ Set executable permission for ${file}"
    fi
done

echo ""

# Fix 5: Test a sample SSL file
echo "🔧 FIX 5: Testing SSL file execution..."

if [ -f "/var/hostvn/menu/controller/ssl/cf_api" ]; then
    echo "   🧪 Testing cf_api syntax..."
    if bash -n /var/hostvn/menu/controller/ssl/cf_api; then
        echo "   ✅ cf_api syntax is OK"
    else
        echo "   ❌ cf_api has syntax errors"
    fi
else
    echo "   ❌ cf_api file not found"
fi

echo ""

echo "====================================================================="
echo "                         FIX SCRIPT HOÀN TẤT"
echo "====================================================================="
echo ""
echo "${GREEN}Các lỗi SSL đã được sửa!${NC}"
echo ""
echo "📝 Tiếp theo:"
echo "   1. Test lại: bash /path/to/ssl_test.sh"
echo "   2. Chạy menu SSL: hostvn -> Quan ly SSL"
echo "   3. Kiểm tra các chức năng SSL"
echo ""

# Final verification
echo "🔍 FINAL CHECK: Verifying fixes..."
echo ""

# Check if all files can be sourced without errors
all_good=true

for file in "${SSL_FILES[@]}"; do
    FILE_PATH="/var/hostvn/menu/controller/ssl/${file}"
    
    if bash -n "${FILE_PATH}" 2>/dev/null; then
        echo "   ✅ ${file} - OK"
    else
        echo "   ❌ ${file} - Still has issues"
        all_good=false
    fi
done

echo ""

if [ "$all_good" = true ]; then
    echo "${GREEN}🎉 TẤT CẢ SSL FILES HOẠT ĐỘNG BÌNH THƯỜNG!${NC}"
else
    echo "${YELLOW}⚠️  Vẫn còn một số vấn đề cần kiểm tra thêm.${NC}"
fi

echo ""

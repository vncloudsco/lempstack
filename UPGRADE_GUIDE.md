# HOSTVN LEMP Stack - Cập nhật cho AlmaLinux 8/9, Rocky Linux 8/9 và CentOS 9

## Tóm tắt thay đổi

Script HOSTVN LEMP Stack đã được cập nhật để hỗ trợ đầy đủ các hệ điều hành sau:
- CentOS 7/8/9
- AlmaLinux 8/9  
- Rocky Linux 8/9
- RHEL 8/9

## Những cải tiến chính

### 1. Enhanced OS Detection (Cải thiện nhận diện hệ điều hành)

**File được cập nhật:**
- `install`
- `hostvn`
- `menu/helpers/os_detection`

**Cải tiến:**
- Nhận diện chính xác AlmaLinux, Rocky Linux và CentOS Stream
- Phân biệt các variant khác nhau của RHEL-based distros
- Detection fallback cho các trường hợp đặc biệt
- Xử lý PowerTools/CRB repository tự động

```bash
# Ví dụ detection logic
if [[ -f /etc/almalinux-release ]]; then
    OS_NAME="almalinux"
elif [[ -f /etc/rocky-release ]]; then
    OS_NAME="rocky"
elif [[ -f /etc/centos-release ]]; then
    if grep -q "CentOS Stream" /etc/centos-release; then
        OS_NAME="centos-stream"
    else
        OS_NAME="centos"
    fi
fi
```

### 2. Package Manager Compatibility (Tương thích trình quản lý gói)

**Thay đổi:**
- Sử dụng `dnf` cho các OS version 8+
- Giữ `yum` cho CentOS 7
- Error handling tốt hơn cho package installation
- Retry logic khi cài đặt package thất bại

**Ví dụ:**
```bash
if [[ $OS_VER -ge 8 ]]; then
    dnf -y install $packages || {
        echo "Failed to install packages: $packages"
        return 1
    }
else
    yum -y install $packages || {
        echo "Failed to install packages: $packages"
        return 1
    }
fi
```

### 3. Repository Management (Quản lý repository)

**PowerTools/CRB Repository:**
- CentOS 8: `PowerTools`
- AlmaLinux 8/Rocky 8: `powertools`
- Tất cả OS version 9: `crb`

**Remi Repository:**
- Tự động chọn URL phù hợp theo OS version
- Kiểm tra repository đã được cài đặt trước khi cài mới
- Error handling cho repository installation

## Nginx Repository Configuration

### Issue với repository cũ:
Repository cũ sử dụng hardcode `centos` cho tất cả distros:
```bash
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
```

Điều này gây vấn đề với AlmaLinux và Rocky Linux vì:
- AlmaLinux/Rocky không có packages trực tiếp trong nginx.org/packages/centos/
- Cần sử dụng RHEL repository cho better compatibility
- Version mapping có thể không chính xác

### Solution mới:
```bash
# Auto-detect distro appropriate repository
case $OS_NAME in
    "centos"|"centos-stream")
        nginx_repo_distro="centos"
        ;;
    "almalinux"|"rocky"|"rhel")
        nginx_repo_distro="rhel"
        ;;
    *)
        nginx_repo_distro="centos"  # fallback
        ;;
esac
```

### Repository URLs:
- **CentOS 7/8/9**: `http://nginx.org/packages/centos/`
- **AlmaLinux/Rocky/RHEL**: `http://nginx.org/packages/rhel/`
- **Fallback**: EPEL repository nếu official repos thất bại

### Cải tiến thêm:
1. **Dual repository setup**: Cả stable và mainline (mainline disabled by default)
2. **Fallback mechanism**: Tự động thử EPEL nếu official repo thất bại
3. **Cache refresh**: `dnf makecache --refresh` trước khi install
4. **Service verification**: Kiểm tra nginx start thành công
5. **Version display**: Hiển thị nginx version sau khi cài đặt

### 4. SELinux Configuration (Cấu hình SELinux)

**Cải tiến:**
- Cài đặt SELinux tools phù hợp với từng OS version
- CentOS 8: `policycoreutils-python-utils`
- CentOS 9: `policycoreutils-python-utils python3-policycoreutils`
- Graceful handling khi SELinux tools không khả dụng

### 5. Enhanced Error Handling (Xử lý lỗi tốt hơn)

**Tính năng:**
- Kiểm tra exit code của các lệnh quan trọng
- Warning messages cho non-critical failures
- Exit với error code khi critical operations thất bại
- Detailed logging cho troubleshooting

### 6. MariaDB Installation (Cài đặt MariaDB)

**Cải tiến:**
- Architecture detection (x86_64, aarch64)
- Repository URL generation tự động
- Galera cluster support cho các version mới
- AppStream repository disable để tránh conflicts

### 7. PHP Installation (Cài đặt PHP)

**Thay đổi:**
- Module management cho DNF-based systems
- PHP version filtering theo OS compatibility
- Repository enable/disable logic
- Better package installation with error checking

## Các file đã được cập nhật

### Core Files:
1. `install` - Script cài đặt chính
2. `hostvn` - Main LEMP installation script

### Helper Files:
3. `menu/helpers/os_detection` - OS detection và compatibility functions

### Controller Files:
4. `menu/controller/cache/install_memcached` - Memcached installation
5. `menu/controller/security/install_clamav` - ClamAV installation

## Kiểm tra tương thích

### Trước khi chạy script:
```bash
# Kiểm tra OS version
cat /etc/os-release

# Kiểm tra architecture  
uname -m

# Kiểm tra RAM
free -h
```

### Sau khi cài đặt:
```bash
# Kiểm tra services
systemctl status nginx mariadb php-fpm

# Kiểm tra repositories
dnf repolist enabled  # hoặc yum repolist enabled

# Kiểm tra PHP version
php -v
```

## Troubleshooting

### Repository Issues:
- Nếu gặp lỗi repository, chạy: `dnf clean all && dnf makecache`
- Kiểm tra network connectivity tới repository mirrors

### SELinux Issues:
- Kiểm tra SELinux status: `getenforce`
- Xem audit logs: `ausearch -m avc -ts recent`

### Package Installation Issues:
- Kiểm tra available packages: `dnf search package_name`
- Update system trước: `dnf update`

## Lưu ý quan trọng

1. **Backup dữ liệu** trước khi upgrade từ CentOS 7
2. **Test trên environment phát triển** trước khi deploy production
3. **Kiểm tra firewall rules** sau khi cài đặt
4. **Update package lists** thường xuyên: `dnf update`

## Changelog

### Version 1.0.5.4
- ✅ Hỗ trợ đầy đủ AlmaLinux 8/9
- ✅ Hỗ trợ đầy đủ Rocky Linux 8/9  
- ✅ Hỗ trợ CentOS 9
- ✅ Enhanced OS detection
- ✅ Improved error handling
- ✅ DNF package manager support
- ✅ SELinux tools compatibility
- ✅ Repository management cải tiến

### Kế hoạch tương lai
- [ ] Container support (Docker/Podman)
- [ ] ARM64 architecture optimization
- [ ] Automated testing framework
- [ ] Performance monitoring integration

---
**Tác giả:** Sanvv - HOSTVN Technical  
**Website:** https://hostvn.vn  
**Phiên bản:** 1.0.5.4  
**Ngày cập nhật:** 2025-07-14

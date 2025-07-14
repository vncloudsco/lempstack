#!/bin/bash

######################################################################
#           HOSTVN LEMP Stack - Compatibility Test Script            #
#           Support: CentOS 7/8/9, AlmaLinux 8/9, Rocky Linux 8/9   #
#                                                                    #
#                Author: Sanvv - HOSTVN Technical                    #
#                  Website: https://hostvn.vn                        #
#                                                                    #
#              Please do not remove copyright. Thank!                #
#  Please do not copy under any circumstance for commercial reason!  #
######################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test logging
LOG_FILE="/tmp/hostvn_compatibility_test.log"

# Helper functions
log_test() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  HOSTVN LEMP Stack Compatibility Test  ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if [[ "$result" == "PASS" ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log_test "PASS - $test_name - $message"
    elif [[ "$result" == "FAIL" ]]; then
        echo -e "${RED}✗ FAIL${NC} - $test_name - $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log_test "FAIL - $test_name - $message"
    else
        echo -e "${YELLOW}⚠ WARN${NC} - $test_name - $message"
        log_test "WARN - $test_name - $message"
    fi
}

print_summary() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}          Test Summary                  ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "Total Tests: $TESTS_TOTAL"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed! Your system is compatible with HOSTVN LEMP Stack.${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed. Please review the results before installation.${NC}"
        return 1
    fi
}

# Test OS Detection
test_os_detection() {
    echo -e "${YELLOW}Testing OS Detection...${NC}"
    
    # Test if we can detect OS
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_NAME=$ID
        OS_VERSION=$VERSION_ID
        OS_VERSION_MAJOR=$(echo $VERSION_ID | cut -d. -f1)
        
        # Additional detection
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
        
        print_result "OS Detection" "PASS" "Detected: $OS_NAME $OS_VERSION"
    else
        print_result "OS Detection" "FAIL" "Cannot detect OS version"
        return 1
    fi
    
    # Test supported OS
    case $OS_NAME in
        "centos"|"centos-stream"|"almalinux"|"rocky"|"rhel")
            if [[ $OS_VERSION_MAJOR -ge 7 && $OS_VERSION_MAJOR -le 9 ]]; then
                print_result "OS Compatibility" "PASS" "$OS_NAME $OS_VERSION_MAJOR is supported"
            else
                print_result "OS Compatibility" "FAIL" "$OS_NAME $OS_VERSION_MAJOR is not supported"
            fi
            ;;
        *)
            print_result "OS Compatibility" "FAIL" "$OS_NAME is not supported"
            ;;
    esac
    
    export OS_NAME OS_VERSION OS_VERSION_MAJOR
}

# Test System Requirements
test_system_requirements() {
    echo -e "${YELLOW}Testing System Requirements...${NC}"
    
    # Test RAM
    RAM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    RAM_MB=$((RAM_TOTAL / 1024))
    
    if [[ $RAM_TOTAL -ge 400000 ]]; then
        print_result "RAM Check" "PASS" "${RAM_MB}MB available (minimum 512MB recommended)"
    else
        print_result "RAM Check" "FAIL" "${RAM_MB}MB available (minimum 512MB required)"
    fi
    
    # Test disk space
    DISK_AVAILABLE=$(df / | awk 'NR==2 {print $4}')
    DISK_GB=$((DISK_AVAILABLE / 1024 / 1024))
    
    if [[ $DISK_AVAILABLE -ge 2097152 ]]; then # 2GB in KB
        print_result "Disk Space" "PASS" "${DISK_GB}GB available"
    else
        print_result "Disk Space" "WARN" "${DISK_GB}GB available (minimum 2GB recommended)"
    fi
    
    # Test CPU cores
    CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
    if [[ $CPU_CORES -ge 1 ]]; then
        print_result "CPU Cores" "PASS" "$CPU_CORES cores detected"
    else
        print_result "CPU Cores" "FAIL" "Cannot detect CPU cores"
    fi
}

# Test Network Connectivity
test_network() {
    echo -e "${YELLOW}Testing Network Connectivity...${NC}"
    
    # Test internet connectivity
    if ping -c 1 google.com &>/dev/null; then
        print_result "Internet Connectivity" "PASS" "Can reach external hosts"
    else
        print_result "Internet Connectivity" "FAIL" "Cannot reach external hosts"
    fi
    
    # Test repository access
    if [[ $OS_VERSION_MAJOR -ge 8 ]]; then
        # Test EPEL
        if curl -s --connect-timeout 10 https://dl.fedoraproject.org/pub/epel/ &>/dev/null; then
            print_result "EPEL Repository" "PASS" "Can access EPEL repository"
        else
            print_result "EPEL Repository" "WARN" "Cannot access EPEL repository"
        fi
        
        # Test Remi
        if curl -s --connect-timeout 10 https://rpms.remirepo.net/ &>/dev/null; then
            print_result "Remi Repository" "PASS" "Can access Remi repository"
        else
            print_result "Remi Repository" "WARN" "Cannot access Remi repository"
        fi
    fi
}

# Test Package Manager
test_package_manager() {
    echo -e "${YELLOW}Testing Package Manager...${NC}"
    
    if [[ $OS_VERSION_MAJOR -ge 8 ]]; then
        # Test DNF
        if command -v dnf &>/dev/null; then
            print_result "DNF Available" "PASS" "DNF package manager found"
            
            # Test DNF functionality
            if dnf --version &>/dev/null; then
                print_result "DNF Functional" "PASS" "DNF is working properly"
            else
                print_result "DNF Functional" "FAIL" "DNF is not working"
            fi
        else
            print_result "DNF Available" "FAIL" "DNF not found"
        fi
    else
        # Test YUM
        if command -v yum &>/dev/null; then
            print_result "YUM Available" "PASS" "YUM package manager found"
            
            # Test YUM functionality
            if yum --version &>/dev/null; then
                print_result "YUM Functional" "PASS" "YUM is working properly"
            else
                print_result "YUM Functional" "FAIL" "YUM is not working"
            fi
        else
            print_result "YUM Available" "FAIL" "YUM not found"
        fi
    fi
}

# Test Root Access
test_root_access() {
    echo -e "${YELLOW}Testing Permissions...${NC}"
    
    if [[ "$(id -u)" == "0" ]]; then
        print_result "Root Access" "PASS" "Running as root user"
    else
        print_result "Root Access" "FAIL" "Not running as root user"
    fi
}

# Test SELinux
test_selinux() {
    echo -e "${YELLOW}Testing SELinux...${NC}"
    
    if command -v getenforce &>/dev/null; then
        SE_STATUS=$(getenforce)
        print_result "SELinux Status" "PASS" "SELinux is $SE_STATUS"
        
        if command -v semanage &>/dev/null; then
            print_result "SELinux Tools" "PASS" "SELinux management tools available"
        else
            print_result "SELinux Tools" "WARN" "SELinux management tools not installed"
        fi
    else
        print_result "SELinux" "WARN" "SELinux not available"
    fi
}

# Test Existing Services
test_existing_services() {
    echo -e "${YELLOW}Testing for Existing Services...${NC}"
    
    # List of conflicting services
    local conflicting_services=("httpd" "apache2" "nginx" "mysql" "mariadb" "postgresql")
    local conflicts_found=false
    
    for service in "${conflicting_services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            print_result "Service Conflict" "WARN" "$service is currently running"
            conflicts_found=true
        fi
    done
    
    if [[ "$conflicts_found" == "false" ]]; then
        print_result "Service Conflicts" "PASS" "No conflicting services found"
    fi
    
    # Check for control panels
    local control_panels=(
        "/usr/local/cpanel/cpanel"
        "/usr/local/directadmin/custombuild/build"
        "/usr/local/psa/version"
        "/etc/init.d/webmin"
        "/usr/local/vesta/"
    )
    
    local panels_found=false
    for panel in "${control_panels[@]}"; do
        if [[ -f "$panel" || -d "$panel" ]]; then
            print_result "Control Panel" "WARN" "Existing control panel detected: $panel"
            panels_found=true
        fi
    done
    
    if [[ "$panels_found" == "false" ]]; then
        print_result "Control Panels" "PASS" "No existing control panels found"
    fi
}

# Test Nginx repository connectivity
test_nginx_repository() {
    local nginx_repo_distro="$1"
    local os_ver="$2"
    
    echo "Testing Nginx repository connectivity..."
    
    # Test repository URL
    local repo_url="http://nginx.org/packages/${nginx_repo_distro}/${os_ver}/x86_64/"
    
    if curl -s --connect-timeout 10 --head "$repo_url" | grep -q "200 OK"; then
        print_result "Nginx Repository" "PASS" "Can access $repo_url"
        return 0
    else
        print_result "Nginx Repository" "WARN" "Cannot access $repo_url - will fallback to EPEL"
        return 1
    fi
}

# Enhanced nginx installation test
test_nginx_requirements() {
    echo -e "${YELLOW}Testing Nginx Installation Requirements...${NC}"
    
    # Determine nginx repository distro
    local nginx_repo_distro
    case $OS_NAME in
        "centos"|"centos-stream")
            nginx_repo_distro="centos"
            ;;
        "almalinux"|"rocky"|"rhel")
            nginx_repo_distro="rhel"
            ;;
        *)
            nginx_repo_distro="centos"
            ;;
    esac
    
    # Test nginx repository
    test_nginx_repository "$nginx_repo_distro" "$OS_VERSION_MAJOR"
    
    # Test if nginx is already installed
    if systemctl is-active --quiet nginx 2>/dev/null; then
        print_result "Existing Nginx" "WARN" "Nginx service is currently running"
    elif rpm -q nginx &>/dev/null; then
        print_result "Existing Nginx" "WARN" "Nginx package is installed but not running"
    else
        print_result "Nginx Conflict" "PASS" "No existing nginx installation found"
    fi
    
    # Test for conflicting web servers
    local web_servers=("httpd" "apache2" "lighttpd")
    local conflicts_found=false
    
    for server in "${web_servers[@]}"; do
        if systemctl is-active --quiet "$server" 2>/dev/null; then
            print_result "Web Server Conflict" "WARN" "$server is currently running"
            conflicts_found=true
        fi
    done
    
    if [[ "$conflicts_found" == "false" ]]; then
        print_result "Web Server Conflicts" "PASS" "No conflicting web servers found"
    fi
}

# Main test execution
main() {
    # Initialize log
    echo "HOSTVN LEMP Stack Compatibility Test - $(date)" > "$LOG_FILE"
    
    print_header
    
    # Run all tests
    test_root_access
    test_os_detection
    test_system_requirements
    test_network
    test_package_manager
    test_selinux
    test_existing_services
    test_nginx_requirements
    test_nginx_requirements
    
    # Print summary
    print_summary
    
    echo ""
    echo -e "${BLUE}Log file saved to: $LOG_FILE${NC}"
    echo ""
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"

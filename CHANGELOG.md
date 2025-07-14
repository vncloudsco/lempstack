# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5.4] - 2025-07-14

### Added
- ✅ Full support for AlmaLinux 8/9
- ✅ Full support for Rocky Linux 8/9
- ✅ Full support for CentOS 9
- ✅ Enhanced OS detection with fallback mechanisms
- ✅ Compatibility test script (`compatibility_test.sh`)
- ✅ ARM64 (aarch64) architecture support
- ✅ Improved error handling throughout all scripts
- ✅ DNF package manager support for modern OS versions
- ✅ Enhanced repository management (PowerTools/CRB auto-detection)
- ✅ SELinux tools compatibility for different OS versions
- ✅ Comprehensive upgrade guide (`UPGRADE_GUIDE.md`)

### Changed
- 🔄 Updated OS detection logic in `install`, `hostvn`, and `menu/helpers/os_detection`
- 🔄 Enhanced package installation with retry logic and error checking
- 🔄 Improved MariaDB installation with architecture detection
- 🔄 Updated PHP installation to use DNF modules for OS 8+
- 🔄 Enhanced SELinux configuration for newer OS versions
- 🔄 Updated Memcached, ClamAV, and CSF installation procedures
- 🔄 Improved Pure-FTPd installation with package manager detection

### Fixed
- 🐛 Fixed PowerTools repository naming inconsistencies
- 🐛 Fixed PHP version filtering for different OS versions
- 🐛 Fixed SELinux tools installation for CentOS 9
- 🐛 Fixed repository URLs for different architectures
- 🐛 Fixed package manager selection logic
- 🐛 Fixed error handling in critical installation steps

### Security
- 🔒 Enhanced SELinux configuration with proper boolean settings
- 🔒 Improved permission handling for service accounts
- 🔒 Better firewall configuration for different OS versions

## [1.0.5.3] - Previous Release

### Features
- Basic support for CentOS 7/8
- LEMP stack installation
- Multiple PHP versions support
- SSL certificates with Let's Encrypt
- Basic cache solutions (Memcached, Redis)
- FTP server with Pure-FTPd
- Web-based admin tools
- CSF Firewall integration

## Migration Guide

### From 1.0.5.3 to 1.0.5.4

#### For CentOS 7 users:
- No changes required, existing functionality preserved
- New features available but not breaking

#### For CentOS 8 users:
- Enhanced DNF support
- Better PowerTools repository handling
- Improved package installation reliability

#### New OS Support:
- **AlmaLinux 8/9**: Direct migration path from CentOS 8
- **Rocky Linux 8/9**: Direct migration path from CentOS 8  
- **CentOS 9**: New support with latest packages

#### Testing Your System:
```bash
# Run compatibility test before upgrade
curl -O https://https://dev.tinycp.me/compatibility_test.sh
chmod +x compatibility_test.sh
./compatibility_test.sh
```

#### Backup Recommendations:
1. Backup your websites: `/home/*/public_html/`
2. Backup databases: `mysqldump --all-databases > backup.sql`
3. Backup configurations: `/etc/nginx/`, `/etc/php-fpm.d/`
4. Backup SSL certificates: `/etc/letsencrypt/`

## Technical Details

### OS Detection Algorithm:
1. Read `/etc/os-release` for primary detection
2. Check specific release files for exact variant detection
3. Fallback to generic RHEL-based detection
4. Set appropriate package manager and repository variables

### Package Manager Selection:
- **OS Version 7**: YUM with EPEL + Remi
- **OS Version 8+**: DNF with EPEL + Remi + PowerTools/CRB

### Repository Management:
- **CentOS 8**: PowerTools repository
- **AlmaLinux/Rocky 8**: powertools repository  
- **All OS 9**: crb repository
- **Remi**: Version-specific URLs for each OS

### Error Handling Strategy:
1. Check exit codes for critical operations
2. Provide warnings for non-critical failures
3. Graceful degradation when possible
4. Detailed logging for troubleshooting

## Support Matrix

| OS | Version | Status | Package Manager | Repository | Notes |
|----|---------|--------|----------------|------------|-------|
| CentOS | 7 | ✅ Supported | YUM | EPEL + Remi | Legacy but stable |
| CentOS | 8 | ✅ Supported | DNF | EPEL + Remi + PowerTools | EOL but functional |
| CentOS | 9 | ✅ Supported | DNF | EPEL + Remi + CRB | Stream release |
| AlmaLinux | 8 | ✅ Supported | DNF | EPEL + Remi + powertools | CentOS 8 replacement |
| AlmaLinux | 9 | ✅ Supported | DNF | EPEL + Remi + CRB | Latest stable |
| Rocky Linux | 8 | ✅ Supported | DNF | EPEL + Remi + powertools | CentOS 8 replacement |
| Rocky Linux | 9 | ✅ Supported | DNF | EPEL + Remi + CRB | Latest stable |
| RHEL | 8 | ✅ Supported | DNF | EPEL + Remi + CodeReady | Enterprise |
| RHEL | 9 | ✅ Supported | DNF | EPEL + Remi + CRB | Enterprise |

## Known Issues

### Resolved in 1.0.5.4:
- ❌ PowerTools repository naming inconsistency → ✅ Fixed
- ❌ SELinux tools missing on newer OS → ✅ Fixed  
- ❌ PHP module conflicts on DNF systems → ✅ Fixed
- ❌ Architecture detection for repositories → ✅ Fixed

### Current Limitations:
- Container environments may require additional configuration
- Some enterprise repositories may need subscription
- ARM64 support requires testing in specific environments

## Contributing

When contributing to OS support:

1. Test on actual hardware/VMs
2. Verify package availability
3. Check repository URLs
4. Test architecture variants (x86_64, aarch64)
5. Validate SELinux contexts
6. Test upgrade/migration paths

## References

- [AlmaLinux Documentation](https://wiki.almalinux.org/)
- [Rocky Linux Documentation](https://docs.rockylinux.org/)
- [CentOS Stream Documentation](https://docs.centos.org/en-US/stream/)
- [Red Hat Enterprise Linux Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/)
- [DNF Documentation](https://dnf.readthedocs.io/)
- [Remi Repository](https://rpms.remirepo.net/)

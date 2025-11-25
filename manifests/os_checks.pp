# @api private
#
# @summary compute some variable related to target system
class sssd::os_checks (
) inherits sssd {
  assert_private()

  # Recent distributions ships SSSD package rewriting permission in their systemd service file
  # https://github.com/voxpupuli/puppet-sssd/issues/24
  $osname = $facts['os']['name']
  $osreleasefull = $facts['os']['release']['full']
  $is_recent_redhat = $osname in ['RedHat', 'CentOS', 'Rocky'] and versioncmp($osreleasefull, '10') >= 0
  $is_recent_fedora = $osname == 'Fedora' and versioncmp($osreleasefull, '41') >= 0
  $is_recent_debian = $osname == 'Debian' and versioncmp($osreleasefull, '13') >= 0 
  $is_recent_ubuntu = $osname == 'Ubuntu' and versioncmp($osreleasefull, '25.04') >= 0 
  $ignore_file_permissions = $is_recent_redhat or $is_recent_fedora or $is_recent_debian or $is_recent_ubuntu
}

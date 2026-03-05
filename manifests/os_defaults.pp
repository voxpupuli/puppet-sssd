# @summary Computes SSSD files permission depending on target OS
#
# Recent distributions ships SSSD package rewriting permission in their systemd service file
# See: https://github.com/voxpupuli/puppet-sssd/issues/24
#
# RedHat-based (new), RHEL >= 10 or Fedora >= 41
#   /etc/sssd/        => 0750 root:sssd
#   /etc/sssd/conf.d/ => 0750 root:sssd
#   /etc/sssd/pki/    => 0750 root:sssd
#   sssd.conf         => 0640 root:sssd
#
# RedHat-based (old), RHEL < 10 or Fedora < 41
#   /etc/sssd/        => 0700 sssd:sssd
#   /etc/sssd/conf.d/ => 0711 sssd:sssd
#   /etc/sssd/pki/    => 0711 root:root
#   sssd.conf         => 0600 root:root
#
# Debian-based (new), Debian >= 13, 
#   /etc/sssd/        => 0740 root:root
#   /etc/sssd/conf.d/ => 0740 root:root
#   /etc/sssd/pki/    => 0751 root:root
#   sssd.conf         => 0640 root:root
#
# Debian-based (old)
#   /etc/sssd/        => 0700 root:root
#   /etc/sssd/conf.d/ => 0700 root:root
#   /etc/sssd/pki/    => 0711 root:root
#   sssd.conf         => 0600 root:root
#
# Other systems gets default root config like Debian-based
#
class sssd::os_defaults {
  assert_private()

  # Extract distribution facts
  $osfamily = $facts['os']['family']
  $osname = $facts['os']['name']
  $osreleasemajor = $facts['os']['release']['major']

  # Check we are on modern RHEL or derivative
  $rhel_based = [
    'RedHat',
    'CentOS',
    'Rocky',
    'AlmaLinux',
    'OracleLinux',
  ]
  $is_modern_rhel = $osname in $rhel_based and versioncmp($osreleasemajor, '10') >= 0
  $is_modern_fedora = $osname == 'Fedora' and versioncmp($osreleasemajor, '41') >= 0

  # Check we are on legacy RHEL or Fedora
  $is_legacy_rhel = $osname in $rhel_based and versioncmp($osreleasemajor, '10') < 0
  $is_legacy_fedora = $osname == 'Fedora' and versioncmp($osreleasemajor, '41') < 0

  # Check if we are on modern Debian/Ubuntu (chmod -R g+r in systemd service)
  $is_modern_debian = $osname == 'Debian' and versioncmp($osreleasemajor, '13') >= 0
  $is_modern_ubuntu = $osname == 'Ubuntu' and versioncmp($osreleasemajor, '25.04') >= 0
  
  # Check if we are on legacy Debian/Ubuntu
  $is_legacy_debian = $osname == 'Debian' and versioncmp($osreleasemajor, '13') < 0
  $is_legacy_ubuntu = $osname == 'Ubuntu' and versioncmp($osreleasemajor, '25.04') < 0

  if ($is_modern_rhel or $is_modern_fedora) {
    # Modern RedHat based
    $permission_defaults = {
      'config_dir_owner' => 'root',
      'config_dir_group' => 'sssd',
      'config_dir_mode'  => '0750',
      'pki_owner'        => 'root',
      'pki_group'        => 'sssd',
      'pki_mode'         => '0750',
      'config_d_owner'   => 'root',
      'config_d_group'   => 'sssd',
      'config_d_mode'    => '0750',
      'config_owner'     => 'root',
      'config_group'     => 'sssd',
      'config_mode'      => '0640',
    }
  } elsif ($is_legacy_rhel or $is_legacy_fedora) {
    # Legacy RedHat based
    $permission_defaults = {
      'config_dir_owner' => 'root',
      'config_dir_group' => 'root',
      'config_dir_mode'  => '0700',
      'pki_owner'        => 'root',
      'pki_group'        => 'root',
      'pki_mode'         => '0711',
      'config_d_owner'   => 'root',
      'config_d_group'   => 'root',
      'config_d_mode'    => '0711',
      'config_owner'     => 'root',
      'config_group'     => 'root',
      'config_mode'      => '0600',
    }
  } elsif ($is_modern_debian or $is_modern_ubuntu) {
    # Modern Debian/Ubuntu perform g+r in init script
    $permission_defaults = {
      'config_dir_owner' => 'root',
      'config_dir_group' => 'root',
      'config_dir_mode'  => '0740',
      'pki_owner'        => 'root',
      'pki_group'        => 'root',
      'pki_mode'         => '0750',
      'config_d_owner'   => 'root',
      'config_d_group'   => 'root',
      'config_d_mode'    => '0750',
      'config_owner'     => 'root',
      'config_group'     => 'root',
      'config_mode'      => '0640',
    }
  } elsif ($is_legacy_debian or $is_legacy_ubuntu) {
    # Legacy Debian/Ubuntu
    $permission_defaults = {
      'config_dir_owner' => 'root',
      'config_dir_group' => 'root',
      'config_dir_mode'  => '0700',
      'pki_owner'        => 'root',
      'pki_group'        => 'root',
      'pki_mode'         => '0700',
      'config_d_owner'   => 'root',
      'config_d_group'   => 'root',
      'config_d_mode'    => '0700',
      'config_owner'     => 'root',
      'config_group'     => 'root',
      'config_mode'      => '0600',
    }
  } else {
    # Unknown system
    # Use default root/root permissions like legacy Debian
    $permission_defaults = {
      'config_dir_owner' => 'root',
      'config_dir_group' => 'root',
      'config_dir_mode'  => '0700',
      'pki_owner'        => 'root',
      'pki_group'        => 'root',
      'pki_mode'         => '0700',
      'config_d_owner'   => 'root',
      'config_d_group'   => 'root',
      'config_d_mode'    => '0700',
      'config_owner'     => 'root',
      'config_group'     => 'root',
      'config_mode'      => '0600',
    }
  }
}

# @api private
#
# @summary ensure packages match our expected state
#
# @param config_manage
#   Should we manage the config?
# @param main_config_dir
#   This is probably /etc/sssd on your system
# @param main_config_file
#   This is probably /etc/sssd/sssd.conf on your system
# @param config_d_location
#   This is probably /etc/sssd/conf.d on your system
# @param purge_unmanaged_conf_d
#   Should we remove any files unknown to puppet in the conf_d location?
# @param config_owner
#   Owner for the config files - should be 'root'
# @param config_group
#   Group for the config files - should be 'root'
# @param config_mode
#   chmod for the config files - should be '0600'
# @param config_dir_mode
#   chmod for main config directory - should probably be '0750' or '0700'
# @param config_d_mode
#   chmod for conf.d sub-directory - should probably be '0750', '0711' or '0700'
# @param main_config
#   Hash containing the content of $main_config_file broken out by section
#   Entries in $config_d_location can replace these elements in a last
#   file wins methodology.
# @param configs
#   A Hash similar to $main_config, but with one more level of nesting
#   'any text you want':
#     section:
#       key: value
class sssd::base_config (
  # lint:ignore:parameter_types
  $config_manage  = $sssd::config_manage,
  $main_config_dir = $sssd::main_config_dir,
  $main_config_file = $sssd::main_config_file,
  $main_pki_dir = $sssd::main_pki_dir,
  $config_d_location = $sssd::config_d_location,
  $purge_unmanaged_conf_d = $sssd::purge_unmanaged_conf_d,
  $pki_owner = $sssd::pki_owner,
  $pki_group = $sssd::pki_group,
  $pki_mode = $sssd::pki_mode,
  $config_owner = $sssd::config_owner,
  $config_group = $sssd::config_group,
  $config_mode = $sssd::config_mode,
  $config_dir_mode = $sssd::config_dir_mode,
  $config_d_mode = $sssd::config_d_mode,
  $main_config = $sssd::main_config,
  $configs = $sssd::configs,
  # lint:endignore
) inherits sssd {
  assert_private()

  if $config_manage {

    # Use computed default values for file permissions depending on running OS
    include sssd::os_defaults
    $permission_defaults = $sssd::os_defaults::permission_defaults
    $eff_pki_owner       = $pki_owner       ? { undef => $permission_defaults['pki_owner'],       default => $pki_owner }
    $eff_pki_group       = $pki_group       ? { undef => $permission_defaults['pki_group'],       default => $pki_group }
    $eff_pki_mode        = $pki_mode        ? { undef => $permission_defaults['pki_mode'],        default => $pki_mode }
    $eff_config_owner    = $config_owner    ? { undef => $permission_defaults['config_owner'],    default => $config_owner }
    $eff_config_group    = $config_group    ? { undef => $permission_defaults['config_group'],    default => $config_group }
    $eff_config_mode     = $config_mode     ? { undef => $permission_defaults['config_mode'],     default => $config_mode }
    $eff_config_dir_mode = $config_dir_mode ? { undef => $permission_defaults['config_dir_mode'], default => $config_dir_mode }
    $eff_config_d_mode   = $config_d_mode   ? { undef => $permission_defaults['config_d_mode'],   default => $config_d_mode }
    #fail("eff_pki_group=${eff_pki_group} permission_defaults_pki_group=${permission_defaults['pki_group']} pki_group=${pki_group}")

    file { $main_config_dir:
      ensure => 'directory',
      owner  => $eff_config_owner,
      group  => $eff_config_group,
      mode   => $eff_config_dir_mode,
    }

    file { $main_pki_dir:
      ensure => 'directory',
      owner  => $eff_pki_owner,
      group  => $eff_pki_group,
      mode   => $eff_pki_mode,
    }

    file { $config_d_location:
      ensure  => 'directory',
      owner   => $eff_config_owner,
      group   => $eff_config_group,
      mode    => $eff_config_d_mode,
      recurse => $purge_unmanaged_conf_d,
      purge   => $purge_unmanaged_conf_d,
    }

    sssd::config { $main_config_file:
      owner               => $eff_config_owner,
      group               => $eff_config_group,
      mode                => $eff_config_mode,
      stanzas             => $main_config,
      force_this_filename => $main_config_file,
    }

    # lint:ignore:140chars
    create_resources(sssd::config, $configs, { 'owner' => $eff_config_owner, 'group' => $eff_config_group, 'mode' => $eff_config_mode })
    # lint:endignore
  }
}

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
# @param main_config
#   Hash containing the content of $main_config_file broken out by section
#   Entries in $config_d_location can replace these elements in a last
#   file wins methodology.
# @param configs
#   A Hash similar to $main_config, but with one more level of nesting
#   'any text you want':
#     section:
#       key: value
# @param advanced_permissions
#   Enable permission handling for files/directories
# @param config_dir_owner
#   Owner for configuration directories ($main_config_dir and $config_d_location)
# @param config_dir_group
#   Group for configuration directories ($main_config_dir and $config_d_location)
# @param config_dir_mode
#   chmod for configuration directories ($main_config_dir and $config_d_location)
# @param main_config_owner
#   Owner for configuration files ($main_config_file and resoures created by $configs)
# @param main_config_group
#   Group for configuration files ($main_config_file and resoures created by $configs)
# @param main_config_mode
#   chmod for configuration files ($main_config_file and resoures created by $configs)
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
  $main_config = $sssd::main_config,
  $configs = $sssd::configs,
  $advanced_permissions = $sssd::advanced_permissions,
  $config_dir_owner = $sssd::config_dir_owner,
  $config_dir_group = $sssd::config_dir_group,
  $config_dir_mode = $sssd::config_dir_mode,
  $main_config_owner = $sssd::main_config_owner,
  $main_config_group = $sssd::main_config_group,
  $main_config_mode = $sssd::main_config_mode,
  # lint:endignore
) inherits sssd {
  assert_private()

  if $config_manage {
    if $advanced_permissions {
      $_config_dir_owner = $config_dir_owner
      $_config_dir_group = $config_dir_group
      $_config_dir_mode = $config_dir_mode
      $_main_config_owner = $main_config_owner
      $_main_config_group = $main_config_group
      $_main_config_mode = $main_config_mode
    } else {
      $_config_dir_owner = $config_owner
      $_config_dir_group = $config_group
      $_config_dir_mode = $config_mode
      $_main_config_owner = $config_owner
      $_main_config_group = $config_group
      $_main_config_mode = $config_mode
    }

    file { $main_config_dir:
      ensure => 'directory',
      owner  => $_config_dir_owner,
      group  => $_config_dir_group,
      mode   => $_config_dir_mode,
    }

    file { $main_pki_dir:
      ensure => 'directory',
      owner  => $pki_owner,
      group  => $pki_group,
      mode   => $pki_mode,
    }

    file { $config_d_location:
      ensure  => 'directory',
      owner   => $_config_dir_owner,
      group   => $_config_dir_group,
      mode    => $_config_dir_mode,
      recurse => $purge_unmanaged_conf_d,
      purge   => $purge_unmanaged_conf_d,
    }

    sssd::config { $main_config_file:
      owner               => $_main_config_owner,
      group               => $_main_config_group,
      mode                => $_main_config_mode,
      stanzas             => $main_config,
      force_this_filename => $main_config_file,
    }

    # lint:ignore:140chars
    create_resources(sssd::config, $configs, { 'owner' => $_main_config_owner, 'group' => $_main_config_group, 'mode' => $_main_config_mode })
    # lint:endignore
  }
}

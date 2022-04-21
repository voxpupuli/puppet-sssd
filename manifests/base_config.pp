# @api private
#
# @summary ensure packages match our expected state
#
# @param config_manage
#   Should we manage the config?
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
class sssd::base_config (
  # lint:ignore:parameter_types
  $config_manage  = $sssd::config_manage,
  $main_config_file = $sssd::main_config_file,
  $config_d_location = $sssd::config_d_location,
  $purge_unmanaged_conf_d = $sssd::purge_unmanaged_conf_d,
  $config_owner = $sssd::config_owner,
  $config_group = $sssd::config_group,
  $config_mode = $sssd::config_mode,
  $main_config = $sssd::main_config,
  $configs = $sssd::configs,
  # lint:endignore
) inherits sssd {
  assert_private()

  if $config_manage {
    file { $config_d_location:
      ensure  => 'directory',
      owner   => $config_owner,
      group   => $config_group,
      mode    => $config_mode,
      recurse => $purge_unmanaged_conf_d,
      purge   => $purge_unmanaged_conf_d,
    }

    sssd::config { $main_config_file:
      owner               => $config_owner,
      group               => $config_group,
      mode                => $config_mode,
      stanzas             => $main_config,
      force_this_filename => $main_config_file,
    }

    # lint:ignore:140chars
    create_resources(sssd::config, $configs, { 'owner' => $config_owner, 'group' => $config_group, 'mode' => $config_mode })
    # lint:endignore
  }
}

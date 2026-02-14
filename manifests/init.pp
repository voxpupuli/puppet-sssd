# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param packages_manage
#   Should we manage the package?
# @param packages_ensure
#   `package` ensure parameter
# @param package_names
#   Array of packages to manage
# @param config_manage
#   Should we manage the config?
# @param main_pki_dir
#   This is probably /etc/sssd/pki on your system
# @param main_config_dir
#   This is probably /etc/sssd on your system
# @param main_config_file
#   This is probably /etc/sssd/sssd.conf on your system
# @param config_d_location
#   This is probably /etc/sssd/conf.d on your system
# @param purge_unmanaged_conf_d
#   Should we remove any files unknown to puppet in the conf_d location?
# @param pki_owner
#   Owner for the pki directory - should probably be 'root' or 'sssd'
# @param pki_group
#   Group for the pki directory - should probably be 'root' or 'sssd'
# @param pki_mode
#   Group for the pki directory - should probably be '0711'
# @param config_owner
#   Owner for the config files - should probably be 'root' or 'sssd'
# @param config_group
#   Group for the config files - should probably be 'root' or 'sssd'
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
# @param services_manage
#   Should this class manage the service states
# @param services_ensure
#   Service ensure parameter
# @param services_enable
#   Service enable parameter
# @param service_names
#   Array of services that are part of sssd
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
#
# @example
#   class { 'sssd':
#     main_config => {
#       'sssd' => {
#          'domains' => 'a, b',
#          'services => ['pam', 'nss']
#        }},
#     configs => {
#       'enable debug' => {
#         'sssd' => { 'debug' => 0 }},
#       'setup different domains' => {
#         'sssd' => { 'domains' => ['c', 'd'] },
#         'domain/c' => { 'id_provider' => 'ldap' },
#         'domain/d' => { 'id_provider' => 'ipa'}
#       setup_empty_nss_section => { 'nss' => {} }
#   }
#
class sssd (
  Boolean $packages_manage,
  String[1] $packages_ensure,
  Array[String] $package_names,
  Boolean $config_manage,
  Stdlib::Absolutepath $main_config_dir,
  Stdlib::Absolutepath $main_config_file,
  Stdlib::Absolutepath $config_d_location,
  Stdlib::Absolutepath $main_pki_dir,
  String $pki_owner,
  String $pki_group,
  String $pki_mode,
  String $config_owner,
  String $config_group,
  String $config_mode,
  Boolean $purge_unmanaged_conf_d,
  Hash $main_config,
  Hash $configs,
  Boolean $services_manage,
  Enum['stopped','running'] $services_ensure,
  Boolean $services_enable,
  Array[String] $service_names,
  Boolean $advanced_permissions,
  String $config_dir_owner,
  String $config_dir_group,
  Stdlib::Filemode $config_dir_mode,
  String $main_config_owner,
  String $main_config_group,
  Stdlib::Filemode $main_config_mode,
) {
  contain sssd::install
  contain sssd::base_config
  contain sssd::service

  Class['sssd::install'] -> Class['sssd::base_config'] ~> Class['sssd::service']
}

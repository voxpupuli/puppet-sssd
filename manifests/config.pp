# @summary Write out an SSSD compatible config file
#
# Transform a Hash of settings into a deterministic
# sssd compatible config file.
#
# The strings will be used "as is", and arrays
# will be joined with ', ' which should let you
# set things in a number of useful ways.
#
# @param stanzas
#   A hash of stanzas with key/value pairs
#   of their entries
# @param owner
#   Who should own
# @param group
#   Who should own
# @param mode
#   permissions
# @param order
#   prefix used to get these files in the order you want
# @param config_d_location
#   This is probably /etc/sssd/conf.d on your system
# @param filename
#   Name of the config file to write out into $config_d_location.
#   The filename must end in `.conf` or sssd will not see it.
# @param force_this_filename
#   Ignore the helper logic, write out this file
#
# @example
#   sssd::config { 'main conf':
#     stanzas             => {
#       'sssd'            => {
#         'domains'       => [ 'example.com', 'otherdomain.tld']
#         'services       => ['pam', 'nss', 'sudo']
#         'debug'         => 0
#       },
#       'example.com'     => {
#         'id_provider'   => 'ldap'
#       }
#     }
#     force_this_filename => '/etc/sssd/sssd.conf'
#   }
#
#  sssd:config {'LDAP':
#    stanzas              => {
#      'domain/LDAP'      => 
#         'id_provider'   => 'ldap'
#      }
#    }
define sssd::config (
  Hash $stanzas,
  String $owner = 'root',
  String $group = 'root',
  String $mode  = '0600',
  Integer[0, 99] $order = 50,
  Optional[Pattern[/\.conf$/]] $filename = undef,
  Stdlib::Absolutepath $config_d_location = '/etc/sssd/conf.d',
  Optional[Stdlib::Absolutepath] $force_this_filename = undef
) {
  if ! defined(Class['sssd']) {
    fail('You must include the sssd base class before using any defined resources')
  }

  if $force_this_filename != undef {
    $full_path = $force_this_filename
  } else {
    if $filename == undef {
      $dynamic_title = join(sort($stanzas.keys), '_')
      $filename_escape = regsubst(downcase($dynamic_title), '[/\.]', '_', 'G')
      $filename_real = "${order}-${filename_escape}.conf"
    } else {
      $filename_real = $filename
    }
    $full_path = "${config_d_location}/${filename_real}"
  }

  file { $full_path:
    ensure  => 'file',
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => epp('sssd/etc/sssd/sssd.conf.epp', { 'stanzas' => $stanzas }),
    notify  => Class['Sssd::Service'],
  }
}

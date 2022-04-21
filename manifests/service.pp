# @api private
#
# @summary take care of the sssd service(s)
#
# @param services_manage
#   Should this class manage the service states
# @param services_ensure
#   Service ensure parameter
# @param services_enable
#   Service enable parameter
# @param service_names
#   Array of services that are part of sssd
#
class sssd::service (
  # lint:ignore:parameter_types
  $services_manage = $sssd::services_manage,
  $services_ensure = $sssd::services_ensure,
  $services_enable = $sssd::services_enable,
  $service_names   = $sssd::service_names,
  # lint:endignore
) inherits sssd {
  assert_private()

  if $services_manage {
    service { $service_names:
      ensure => $services_ensure,
      enable => $services_enable,
    }
  }
}

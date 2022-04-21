# @api private
#
# @summary ensure packages match our expected state
#
# @param packages_manage
#   Should we manage the package?
# @param packages_ensure
#   `package` ensure parameter
# @param package_names
#   Array of packages to manage
class sssd::install (
  # lint:ignore:parameter_types
  $packages_manage  = $sssd::packages_manage,
  $packages_ensure = $sssd::packages_ensure,
  $package_names   = $sssd::package_names,
  # lint:endignore
) inherits sssd {
  assert_private()

  if $packages_manage {
    package { $package_names:
      ensure => $packages_ensure,
    }
  }
}

# Definition: st2::rbac
#
# This defined type creates RBAC resources for users
# This is an enterprise feature, and requires a license
# to be used.
#
# Example
#
#   st2::rbac { 'admin':
#     description => "Administrative user",
#     roles       => [
#       'observer',
#       'my_test_role',
#     ],
#   }
define st2::rbac (
  $ensure      = 'present',
  $user        = $name,
  $description = "Created and managed by Puppet",
  $roles       = [],
) {
  include ::st2::rbac::support
  $_enabled_state = $ensure ? {
    'present' => 'true',
    default   => 'false',
  }

  ensure_resource('exec', 'reload st2 rbac definitions', {
    'command'         => 'st2-apply-rbac-definitions',
    'refreshonly'     => 'true',
    'path'            => '/usr/sbin:/usr/bin:/sbin:/bin',
  })

  file { "${_rbac_dir}/assignments/${user}.yaml":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/rbac/assignments/user.yaml.erb'),
    require => [
      File['/opt/stackstorm/rbac/assignments'],
    ],
    notify  => Exec['reload st2 rbac definitions'],
  }
}

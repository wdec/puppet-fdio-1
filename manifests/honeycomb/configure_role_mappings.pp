# == Define: fdio::honeycomb::configure_role_mappings
#
# Defined type to configure interface role mapping in OpenDaylight
#
# === Parameters:
# [*honeycomb_username*]
#   User name for Honeycomb.
#
# [*honeycomb_password*]
#   Password for Honeycomb.
#
# [*honeycomb_url*]
#   Honeycomb restconf binding URL.
#
# [*interface_role_mapping*]
#   List of interface role mapping in the format
#              of <VPP interface name>:<role name>
#   Example:
#      [ 'GigabitEthernet0/5/0:public-interface',
#        'GigabitEthernet0/6/0:tenant-interface' ]
#
define fdio::honeycomb::configure_role_mappings (
  $honeycomb_username,
  $honeycomb_password,
  $honeycomb_url,
  $interface_role_mapping = $title,
) {
  $mapping = split($interface_role_mapping, ':')
  $vpp_int = regsubst($mapping[0], '/', '%2F', 'G')
  $role_name = $mapping[1]
  case $role_name {
    'tenant-interface': { $role_type = 'virtual-domain-interface' }
    'public-interface': { $role_type = 'public-interface' }
    default: { fail("Unsupported interface role: ${role_name}") }
  }
  $config_url = "${honeycomb_url}/restconf/config/ietf-interfaces:interfaces/ietf-interfaces:interface/${vpp_int}/interface-role:roles/interface-role:role/${role_name}"

  exec { "Register interface ${mapping[0]} with role ${role_name}":
    command   => "curl -XPOST --fail -H 'Content-Type: application/json' -u ${honeycomb_username}:${honeycomb_password} ${config_url} -d \"{'role-type': '${role_type}'}\"",
    tries     => 5,
    try_sleep => 30,
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
    unless    => "curl -u ${honeycomb_username}:${honeycomb_password} ${config_url} | grep '${role_name}'",
  }
}

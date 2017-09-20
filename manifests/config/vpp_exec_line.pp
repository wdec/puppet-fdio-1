# == Define: fdio::config::vpp_exec_line
#
# Defined type to configure VPP startup exec line
#
# === Parameters:
# [*path*]
# (required) Path of VPP exec file path
#
# [*line*]
# (required) VPP exec command
#
define fdio::config::vpp_exec_line (
  $path,
  $line = $title,
) {
  file_line { "${line}":
    path => $path,
    line => $line
  }
}
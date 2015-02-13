Exec {
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}

Package { allow_virtual => false }

Yumrepo <| |> -> User <| |> -> Package <| |>

include vagrantFix

package { 'nano': ensure => installed,}

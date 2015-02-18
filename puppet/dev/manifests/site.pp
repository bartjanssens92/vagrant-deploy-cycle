Exec {
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}

Package { allow_virtual => false }

Yumrepo <| |> -> User <| |> -> Package <| |>

file { '/home/vagrant/.ssh':
  ensure  => directory,
  owner   => vagrant,
  recurse => true,
}

package { 'nano': ensure => installed,}

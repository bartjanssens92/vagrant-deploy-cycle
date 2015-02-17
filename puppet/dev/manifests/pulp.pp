node 'pulp' {

  ###################
  # EPEL REPOSITORY #
  ###################

  yumrepo { 'epel-enabled':
    ensure     => 'present',
    baseurl    => 'http://download.fedoraproject.org/pub/epel/6/$basearch',
    descr      => 'epel',
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6',
    mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
  }


  ############
  # FIREWALL #
  ############

  firewall { '001 allow ssh':
    port   => 22,
    action => accept,
  }

  firewall { '100 allow http and https access':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }

  firewall { '100 allow costumers connect to the message bus':
    port   => [5671, 5672, 27017],
    proto  => tcp,
    action => accept,
  }

  firewall { "999 drop all other requests":
    action => "drop",
  }

  ###########
  # MONGODB #
  ###########

  yumrepo { 'mongo-stable':
    descr    => 'MongoDB Repository',
    baseurl  => 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/',
    gpgcheck => 0,
    enabled  => 1,
  }

  package { 'mongodb-server':
    ensure  => present,
    require => Yumrepo['mongo-stable'],
  }

  package { 'policycoreutils-python':
    ensure => present,
  }

  exec { "add_mongodb_port_t_27017":
    command => "semanage port -a -t mongod_port_t -p tcp 27017",
    unless  => "semanage port -l|grep \"^mongod_port_t.*tcp.*27017\"",
    require => Package['policycoreutils-python'],
  }

  ########
  # PULP #
  ########

  yumrepo { 'pulp-2.6-beta':
    descr    => 'Pulp Production Releases',
    baseurl  => 'https://repos.fedorapeople.org/repos/pulp/pulp/beta/2.6/$releasever/$basearch/',
    enabled  => 1,
    gpgcheck => 0,
  }

  $qpidd = ['qpid-cpp-server','qpid-cpp-server-store','python-qpid-qmf']

  package { $qpidd:
    ensure  => present,
    require => Yumrepo['pulp-2.6-beta'],
  }

  class { 'pulp':
    pulp_version => '2',
    pulp_server  => true,
    pulp_admin   => true,
    repo_enabled => false,
    require => [Exec['add_mongodb_port_t_27017'],
                Package['mongodb-server'],
                Package[$qpidd],]

  }

  # Ugly hack to fix wrong config issue with module
  file { '/tmp/admin.conf.tmp':
    ensure  => present,
    content => template('files/admin.conf.erb'),
  }
  
  exec { 'config admin hack':
    command => '/bin/cat /tmp/admin.conf.tmp > /etc/pulp/admin/admin.conf',
    require => File['/etc/pulp/admin/admin.conf'],
    notify  => Service['httpd'],
  }

  # Fix for failing pulp-manage-db command
  exec { 'pulp-manage-db':
    command => '/usr/bin/sudo -u apache /usr/bin/pulp-manage-db',
    creates => '/var/lib/pulp/.inited',
    require => Exec['manage_pulp_databases'],
    notify  => Service['httpd'],
  }

  file { '/var/lib/pulp/.inited':
    ensure  => present,
    require => Exec['pulp-manage-db'],
  }
}

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
    port   => [5671, 5672],
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

  service { 'mongod':
    ensure  => 'running',
    require => [Exec['add_mongodb_port_t_27017'],
                Package['mongodb-server']]
  }

  ########
  # PULP #
  ########

  yumrepo { 'pulp-stable':
    descr    => 'Pulp Production Releases',
    baseurl  => 'https://repos.fedorapeople.org/repos/pulp/pulp/v2/stable/$releasever/$basearch/',
    enabled  => 1,
    gpgcheck => 0,
  }

  $qpid_soft = ['qpid-cpp-server',
                'qpid-cpp-server-store']

  $pulp_server_qpid = ['pulp-puppet-plugins',
                       'pulp-rpm-plugins',
                       'python-qpid',
                       'python-qpid-qmf']

  $pulp_admin = ['pulp-admin-client',
                 'pulp-puppet-admin-extensions',
                 'pulp-rpm-admin-extensions']


  exec { 'install-python-pulp-common-2.5.1-1.el6.noarch.rpm':
    command => '/usr/bin/yum install /tmp/rpms/python-pulp-common-2.5.1-1.el6.noarch.rpm -y',
    unless  => '/usr/bin/yum list installed | grep python-pulp-common',
    require => Yumrepo['pulp-stable'],
  }

  exec { 'install-pulp-server-2.5.1-1.el6.noarch.rpm':
    command => '/usr/bin/yum install /tmp/rpms/pulp-server-2.5.1-1.el6.noarch.rpm -y',
    unless  => '/usr/bin/yum list installed | grep pulp-server',
    require => Exec['install-python-pulp-common-2.5.1-1.el6.noarch.rpm'],
  }

#  package { $qpid_soft:
#    ensure => present,
#    require => Yumrepo['pulp-stable'],
#  }
#
#  package { $pulp_server_qpid:
#    ensure  => present,
#    require => Yumrepo['pulp-stable'],
#  }
#
#  package { $pulp_admin:
#    ensure => present,
#    require => Yumrepo['pulp-stable'],
#  }

}

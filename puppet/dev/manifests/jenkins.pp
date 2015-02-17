node 'jenkins' {

  ############
  # SOFTWARE #
  ###########

  $soft = ['java-1.6.0-openjdk-devel.x86_64']

  package { $soft:
    ensure => 'present',
  }

  $jenkins_port = hiera('jenkins_port', 8080)

  ###########
  # JENKINS #
  ###########

  class { 'jenkins':
    install_java       => false,
    port               => $jenkins_port,
    repo               => true,
    configure_firewall => false,
  }

  # Make the jenkins user to use with deployments
  user { 'jenkins':
    ensure  => 'present',
    groups  => 'jenkins',
    require => Group['jenkins'],
  }

  group { 'jenkins':
    ensure => 'present',
  }

  ##############
  # PULP-ADMIN #
  ##############

  yumrepo { 'pulp-2.6-beta':
    descr    => 'Pulp Production Releases',
    baseurl  => 'https://repos.fedorapeople.org/repos/pulp/pulp/beta/2.6/$releasever/$basearch/',
    enabled  => 1,
    gpgcheck => 0,
  }

  file { '/home/jenkins':
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  $pulpadmin = ['pulp-admin-client','pulp-puppet-admin-extensions','pulp-rpm-admin-extensions']

  package { $pulpadmin:
    ensure  => installed,
    require => [Yumrepo['pulp-2.6-beta'],
                Yumrepo['epel-enabled'],]
  }

  file { '/etc/pulp/admin/admin.conf':
    ensure  => present,
    content => template('files/admin.conf.erb'),
    require => Package[$pulpadmin],
  }

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

  file { '/etc/hosts':
    ensure => present,
    content => template('files/hosts.erb'),
  }
}

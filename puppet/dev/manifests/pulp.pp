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

  ###########
  # MONGODB #
  ###########

  include ::mongodb::server

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
                       'pulp-selinux',
                       'pulp-server',
                       'python-qpid',
                       'python-qpid-qmf']

  $pulp_admin = ['pulp-admin-client',
                 'pulp-puppet-admin-extensions',
                 'pulp-rpm-admin-extensions']

  package { $qpid_soft:
    ensure => present,
    require => Yumrepo['pulp-stable'],
  }

  package { $pulp_server_qpid:
    ensure  => present,
    require => Yumrepo['pulp-stable'],
  }

  package { $pulp_admin:
    ensure => present,
    require => Yumrepo['pulp-stable'],
  }

}

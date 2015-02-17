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
}

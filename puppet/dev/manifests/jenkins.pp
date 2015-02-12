node 'jenkins' {

  ###########
  # JENKINS #
  ###########

  class { 'jenkins':
    install_java => false,
    port         => $jenkins_port,
    repo         => true,
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

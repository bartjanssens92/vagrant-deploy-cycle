class vagrantFix {

  file { '/home/vagrant/.ssh':
    ensure  => directory,
    owner   => vagrant,
    recurse => true,
  }

}

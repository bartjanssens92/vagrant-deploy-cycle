Vagrant.configure(2) do |config|
  config.vm.box = "vStone/centos-6.x-puppet.3.x"
#  config.vm.network "public_network"
  config.vm.synced_folder "puppet/hiera_data", "/etc/hiera"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "off"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
  end

  config.vm.provision "puppet" do |puppet|
    env = 'dev'
    puppet.hiera_config_path = "puppet/hiera.yaml"
    puppet.manifest_file = ""
    puppet.manifests_path = "puppet/#{env}/manifests"
    puppet.module_path = "puppet/modules"
    puppet.options = "--environment #{env}"
  end

  config.vm.define "jenkins" do |jenkins|
    jenkins.vm.hostname = "jenkins"
    jenkins.vm.network "forwarded_port", guest: 8080, host: 8080
    jenkins.vm.network "private_network", ip: "192.168.1.100"
    jenkins.ssh.pty = false
  end

  config.vm.define "pulp" do |pulp|
    pulp.vm.hostname = "pulp"
    pulp.vm.network "forwarded_port", guest: 80, host: 8081
    pulp.vm.network "forwarded_port", guest: 443, host: 8443
    pulp.vm.network "private_network", ip: "192.168.1.101"
  end

end

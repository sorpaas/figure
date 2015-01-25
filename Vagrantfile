# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV["BOX_NAME"] || "trusty"
BOX_URI = ENV["BOX_URI"] || "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
BOX_MEMORY = ENV["BOX_MEMORY"] || "1024"
FIGURE_DOMAIN = ENV["FIGURE_DOMAIN"] || "figure.me"
FIGURE_IP = ENV["FIGURE_IP"] || "10.0.0.2"
PREBUILT_STACK_URL = File.exist?("#{File.dirname(__FILE__)}/stack.tgz") ? 'file:///root/figure/stack.tgz' : nil
PUBLIC_KEY_PATH = "#{Dir.home}/.ssh/id_rsa.pub"

make_cmd = "make install"
if PREBUILT_STACK_URL
  make_cmd = "PREBUILT_STACK_URL='#{PREBUILT_STACK_URL}' #{make_cmd}"
end

Vagrant::configure("2") do |config|
  config.ssh.forward_agent = true

  config.vm.box = BOX_NAME
  config.vm.box_url = BOX_URI
  config.vm.synced_folder File.dirname(__FILE__), "/root/figure"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # Ubuntu's Raring 64-bit cloud image is set to a 32-bit Ubuntu OS type by
    # default in Virtualbox and thus will not boot. Manually override that.
    vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    vb.customize ["modifyvm", :id, "--memory", BOX_MEMORY]
  end

  config.vm.define "empty", autostart: false

  config.vm.define "figure", primary: true do |vm|
    vm.vm.network :forwarded_port, guest: 80, host: 8085
    vm.vm.hostname = "#{FIGURE_DOMAIN}"
    vm.vm.network :private_network, ip: FIGURE_IP
    vm.vm.provision :shell, :inline => "apt-get -qq -y install git > /dev/null && cd /root/figure && #{make_cmd}"
  end

  if Pathname.new(PUBLIC_KEY_PATH).exist?
    config.vm.provision :file, source: PUBLIC_KEY_PATH, destination: '/tmp/id_rsa.pub'
    config.vm.provision :shell, :inline => "rm /root/.ssh/authorized_keys && mv /tmp/id_rsa.pub /root/.ssh/authorized_keys"
  end
end

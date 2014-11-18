Vagrant.configure("2") do |config|
  ## Choose your base box
  config.vm.box = "hashicorp/precise64"

  ## For masterless, mount your file roots file root
  config.vm.synced_folder "salt/", "/etc/salt/"
  config.vm.synced_folder "reclass/", "/etc/reclass/"

  ## Set your salt configs here
  config.vm.provision :salt do |salt|

    ## Minion config is set to ``file_client: local`` for masterless
    salt.minion_config = "salt/minion"

    ## Run highstate to apply formula in salt/roots/formula
    salt.run_highstate = true

  end
end


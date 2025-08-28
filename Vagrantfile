Vagrant.configure("2") do |config|
  # Domain Controller
  config.vm.define "dc01" do |dc|
    dc.vm.box = "gusztavvargadr/windows-server-2022-standard"
    dc.vm.hostname = "LAB-DC01"
    dc.vm.network "private_network", ip: "192.168.1.10"
    dc.vm.provider "virtualbox" do |vb|
      vb.memory = "8192"
      vb.cpus = 2
    end
    dc.vm.provision "shell", path: "scripts/setup-dc.ps1"
  end
  
  # Entra Connect Server
  config.vm.define "connect01" do |conn|
    conn.vm.box = "gusztavvargadr/windows-server-2022-standard"
    conn.vm.hostname = "LAB-CONNECT01"
    conn.vm.network "private_network", ip: "192.168.1.11"
    conn.vm.provider "virtualbox" do |vb|
      vb.memory = "8192"
      vb.cpus = 2
    end
    conn.vm.provision "shell", path: "scripts/setup-connect.ps1"
  end
  
  # Attacker Workstation
  config.vm.define "attacker01" do |att|
    att.vm.box = "gusztavvargadr/windows-11-22h2-enterprise"
    att.vm.hostname = "LAB-ATTACKER01"
    att.vm.network "private_network", ip: "192.168.1.12"
    att.vm.provider "virtualbox" do |vb|
      vb.memory = "16384"
      vb.cpus = 4
    end
    att.vm.provision "shell", path: "scripts/setup-attacker.ps1"
  end
end

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "storm_lab" {
  name     = "RG-Storm-Lab"
  location = "East US"
}

resource "azurerm_virtual_network" "storm_vnet" {
  name                = "StormLab-VNet"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.storm_lab.location
  resource_group_name = azurerm_resource_group.storm_lab.name
}

resource "azurerm_subnet" "internal" {
  name                 = "Internal-Subnet"
  resource_group_name  = azurerm_resource_group.storm_lab.name
  virtual_network_name = azurerm_virtual_network.storm_vnet.name
  address_prefixes     = ["192.168.1.0/24"]
}

# Domain Controller VM
resource "azurerm_windows_virtual_machine" "dc01" {
  name                = "LAB-DC01"
  resource_group_name = azurerm_resource_group.storm_lab.name
  location            = azurerm_resource_group.storm_lab.location
  size                = "Standard_D2s_v3"
  admin_username      = "Administrator"
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.dc01_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

variable "admin_password" {
  description = "Admin password for all VMs"
  type        = string
  sensitive   = true
  default     = "StormLab2024!"
}

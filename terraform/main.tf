terraform {
  backend "azurerm" {
    resource_group_name  = "tamopstfstates"
    storage_account_name = "tfstatedevops"
    container_name       = "terraformgithubexample"
    key                  = "terraformgithubexample.tfstate"
  }
}
 
provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you're using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}
 
data "azurerm_client_config" "current" {}

#Création de mon Ressources groupe

resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = "West Europe"
}

#Création de mon réseau

resource "azurerm_virtual_network" "reseauRyan" {
  name                = "reseauRyan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}
#Création de mon sous réseau

resource "azurerm_subnet" "sous_reseauRyan" {
    name              ="sous_reseauRyan"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.reseauRyan.name
    address_prefixes = ["10.0.2.0/24"]
}
#Création de l'adresse ip avec une étiquette DNS

resource "azurerm_public_ip" "mon_ip" {
    name = "mon_ip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Dynamic"
    domain_name_label = "dnsryan"

    tags = {
        environment = "production"
    }
}

#Network security groupe and rules

resource "azurerm_network_security_group" "securitegrp" {
    name = "securitegroupe"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name = "SSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

# Création de l'interface réseau

resource "azurerm_network_interface" "interfacereseau" {
    name = "myNIC"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "myNicConfiguration"
        subnet_id = azurerm_subnet.sous_reseauRyan.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.mon_ip.id
    }
}

#Connection le groupe de securité à l'interface réseau

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.interfacereseau.id
  network_security_group_id = azurerm_network_security_group.securitegrp.id
}

#Création de la machine virutelle

resource "azurerm_linux_virtual_machine" "VmRyan" {
    name = "Ryan"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_F2"
    admin_username = "Ryano"
    network_interface_ids = [
        azurerm_network_interface.interfacereseau.id
    ]
    source_image_reference {
       publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
    os_disk {
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
    }
}

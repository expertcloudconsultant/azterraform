#Create resource group
resource "azurerm_resource_group" "emc-eus-corporate-resources-rg" {
  name     = "emc-eus-corporate-resources-rg"
  location = var.location
}

#Create virtual network and subnets
resource "azurerm_virtual_network" "emc-eus-corporate-network-vnet" {
  name                = "emc-eus-corporate-network-vnet"
  location            = azurerm_resource_group.emc-eus-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  address_space       = ["172.20.0.0/16"]

  tags = {
    environment = "Production"
  }
}

#Create subnet - presentation tier
resource "azurerm_subnet" "presentation-subnet" {
  name                 = "presentation-subnet"
  resource_group_name  = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  virtual_network_name = azurerm_virtual_network.emc-eus-corporate-network-vnet.name
  address_prefixes       = ["172.20.1.0/24"]
}

#Create subnet - data access tier
resource "azurerm_subnet" "data-access-subnet" {
  name                 = "data-access-subnet"
  resource_group_name  = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  virtual_network_name = azurerm_virtual_network.emc-eus-corporate-network-vnet.name
  address_prefixes       = ["172.20.2.0/24"]
}

  #Create Public IP Address
  resource "azurerm_public_ip" "emc-eus-corporate-nic-01-pip" {
    name                = "emc-eus-corporate-nic-01-pip"
    location            = azurerm_resource_group.emc-eus-corporate-resources-rg.location
    resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name
    allocation_method   = "Dynamic"
  }


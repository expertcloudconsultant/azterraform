#IaC on Azure Cloud Platform | Declare Azure as the Provider

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


#Create resource group
resource "azurerm_resource_group" "emc-eus-corporate-resources-rg" {
  name     = "emc-eus-corporate-resources-rg"
  location = var.location
}


#Create virtual network and subnets
resource "azurerm_virtual_network" "emc-eus-corporate-network-vnet" {
   name = "emc-eus-corporate-network-vnet"
   location = azurerm_resource_group.emc-eus-corporate-resources-rg.location
   resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name
   address_space = [ "172.20.0.0/16" ]

   #Create subnet - presentation tier
   subnet {

     name = "presentation-subnet"
     address_prefix = "172.20.1.0/24"
   }

   #Create subnet - data access tier
      subnet {

     name = "data-access-subnet"
     address_prefix = "172.20.2.0/24"
   }


   tags = {
    environment = "Production"
  }
}
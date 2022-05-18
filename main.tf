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
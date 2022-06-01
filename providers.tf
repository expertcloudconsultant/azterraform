#IaC on Azure Cloud Platform | Declare Azure as the Provider
# Configure the Microsoft Azure Provider
terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }


   backend "azurerm" {
    resource_group_name  = "remote-terraform-state"
    storage_account_name = "tfstoragetrainingenc"
    container_name       = "remote-terraform-container"
    key                  = "terraform.tfstate"
      }

}

provider "azurerm" {
  features {}
}
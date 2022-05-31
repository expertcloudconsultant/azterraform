#connect terraform to a remote[backend] state - using azure as an example
terraform {

  backend "azurerm" {
    resource_group_name  = "remote-terraform-state"
    storage_account_name = "tfstoragetrainingenc"
    container_name       = "remote-terraform-container"
    key                  = "terraform.tfstate"

  }
}
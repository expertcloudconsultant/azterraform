
#https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure
#Terraform commands
#terraform init,plan,apply,destroy
#terraform plan -destroy --out=plan-file.pln
#terraform show plan-file.pln
#terraform validate                          # Check if the template is fine
#terraform fmt                               # Format template based on best practices
#terraform state list                        # Lists all resources in the state file
#terraform show                              # Print a complete state in human readable format
#terraform state show path_to_resource       # Print details of one resource
#terraform graph | dot -Tpng > graph.png     # Export dependency graph, needs GraphViz
#terraform graph -verbose | dot -Tpng > graph.png # Also show destroyed resources


#connect terraform to a remote[backend] state - using azure as an example
terraform {

  backend "azurerm" {
    resource_group_name  = "remote-terraform-state"
    storage_account_name = "tfstoragetrainingenc"
    container_name       = "remote-terraform-container"
    key                  = "terraform.tfstate"

  }
}

#Create resource group
resource "azurerm_resource_group" "emc-eus2-corporate-resources-rg" {
  # name     = "emc-eus2-corporate-resources-rg"
  name     = "${var.emc-corp}-resource-rg"
  location = var.location
}

#Create virtual network and subnets
resource "azurerm_virtual_network" "emc-eus2-corporate-network-vnet" {
  name                = "emc-eus2-corporate-network-vnet"
  location            = azurerm_resource_group.emc-eus2-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus2-corporate-resources-rg.name
  address_space       = ["172.20.0.0/16"]

  tags = {
    environment = "Production"
  }
}

#Create subnet - presentation tier
resource "azurerm_subnet" "presentation-subnet" {
  name                 = "presentation-subnet"
  resource_group_name  = azurerm_resource_group.emc-eus2-corporate-resources-rg.name
  virtual_network_name = azurerm_virtual_network.emc-eus2-corporate-network-vnet.name
  address_prefixes     = ["172.20.1.0/24"]
}

#Create subnet - data access tier
resource "azurerm_subnet" "data-access-subnet" {
  name                 = "${var.emc-corp}-data-access-subnet"
  resource_group_name  = azurerm_resource_group.emc-eus2-corporate-resources-rg.name
  virtual_network_name = azurerm_virtual_network.emc-eus2-corporate-network-vnet.name
  address_prefixes     = ["172.20.2.0/24"]
}



# Create public IPs
resource "azurerm_public_ip" "corporate-webserver-vm-01-ip" {
  name                = "corporate-webserver-vm-01-ip"
  location            = azurerm_resource_group.emc-eus2-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus2-corporate-resources-rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "emc-eus2-corporate-nsg" {
  name                = "emc-eus2-corporate-nsg"
  location            = azurerm_resource_group.emc-eus2-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus2-corporate-resources-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_access_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "WEB"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.web_server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}

# Create network interface
resource "azurerm_network_interface" "corporate-webserver-vm-01-nic" {
  name                = "corporate-webserver-vm-01-nic"
  location            = azurerm_resource_group.emc-eus2-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus2-corporate-resources-rg.name

  ip_configuration {
    name                          = "corporate-webserver-vm-01-nic-ip"
    subnet_id                     = azurerm_subnet.presentation-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.corporate-webserver-vm-01-ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "corporate-webserver-vm-01-nsg-link" {
  network_interface_id      = azurerm_network_interface.corporate-webserver-vm-01-nic.id
  network_security_group_id = azurerm_network_security_group.emc-eus2-corporate-nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.emc-eus2-corporate-resources-rg.name
  }

  byte_length = 8
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "corpwebservervm01storage" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.emc-eus2-corporate-resources-rg.location
  resource_group_name      = azurerm_resource_group.emc-eus2-corporate-resources-rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# Create (and display) an SSH key
resource "tls_private_key" "linuxsrvuserprivkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Custom Data Insertion Here

data "template_cloudinit_config" "webserverconfig" {
  gzip          = true
  base64_encode = true

  part {

    content_type = "text/cloud-config"
    content      = "packages: ['nginx']"
  }
}


resource "azurerm_resource_group" "emc-eus2-corporate-import-rg" {

  name     = "emc-eus2-corporate-import-rg"
  location = var.location

  tags = {
    env = "resource-group"
  }

}

# terraform import azurerm_resource_group.emc-eus2-corporate-import-rg /subscriptions/31e9c06e-6d3f-4485-836c-ff36c38135a3/resourceGroups/emc-import-resources-rg
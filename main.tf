

#https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure

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
  address_prefixes     = ["172.20.1.0/24"]
}

#Create subnet - data access tier
resource "azurerm_subnet" "data-access-subnet" {
  name                 = "data-access-subnet"
  resource_group_name  = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  virtual_network_name = azurerm_virtual_network.emc-eus-corporate-network-vnet.name
  address_prefixes     = ["172.20.2.0/24"]
}

#Create Public IP Address
resource "azurerm_public_ip" "emc-eus-corporate-nic-01-pip" {
  name                = "emc-eus-corporate-nic-01-pip"
  location            = azurerm_resource_group.emc-eus-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  allocation_method   = "Dynamic"
}

# Create public IPs
resource "azurerm_public_ip" "corporate-webserver-vm-01-ip" {
  name                = "corporate-webserver-vm-01-ip"
  location            = azurerm_resource_group.emc-eus-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "emc-eus-corporate-nsg" {
  name                = "emc-eus-corporate-nsg"
  location            = azurerm_resource_group.emc-eus-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "corporate-webserver-vm-01-nic" {
  name                = "corporate-webserver-vm-01-nic"
  location            = azurerm_resource_group.emc-eus-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name

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
  network_security_group_id = azurerm_network_security_group.emc-eus-corporate-nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  }

  byte_length = 8
}

# Create (and display) an SSH key
resource "tls_private_key" "linuxsrvuserprivkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


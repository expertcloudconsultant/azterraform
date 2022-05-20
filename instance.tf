
resource "azurerm_virtual_machine" "emc-eus-corporate-webserver-vm-01" {
  name                  = "${var.prefix}-webserver-vm-01"
  location              = azurerm_resource_group.emc-eus-corporate-resources-rg.location
  resource_group_name   = azurerm_resource_group.emc-eus-corporate-resources-rg.name
  network_interface_ids = [azurerm_network_interface.emc-eus-corporate-nic-01.id]
  vm_size               = "Standard_DC1_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  os_disk {
    name                 = "webservervm01"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "emcosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "emc-vm-host"
    admin_username = "emcsvrusr"
    admin_password = "Tassword1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Production"
  }
}


# Create network interface
resource "azurerm_network_interface" "emc-eus-corporate-nic-01" {
  name                = "emc-eus-corporate-nic-01"
  location            = azurerm_resource_group.emc-eus-corporate-resources-rg.location
  resource_group_name = azurerm_resource_group.emc-eus-corporate-resources-rg.name

  ip_configuration {
    name                          = "${var.prefix}-vmnic"
    subnet_id                     = azurerm_subnet.presentation-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.emc-eus-corporate-nic-01-pip.id

  }
}

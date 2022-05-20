# Create virtual machine
resource "azurerm_linux_virtual_machine" "emc-eus2-corporate-webserver-vm-01" {
  name                  = "emc-eus2-corporate-webserver-vm-01"
  location              = azurerm_resource_group.emc-eus2-corporate-resources-rg.location
  resource_group_name   = azurerm_resource_group.emc-eus2-corporate-resources-rg.name
  network_interface_ids = [azurerm_network_interface.corporate-webserver-vm-01-nic.id]
  size                  = "Standard_DC1ds_v3"

  os_disk {
    name                 = "corpwebservervm01disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "corporate-webserver-vm-01"
  admin_username                  = "linuxsrvuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "linuxsrvuser"
    public_key = tls_private_key.linuxsrvuserprivkey.public_key_openssh
  }
}
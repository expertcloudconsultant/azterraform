#Use Output to Find Information

output "emc-vm-01-nic" {

  value = "${azurerm_network_interface.corporate-webserver-vm-01-nic}"
}


output "tls-private-key" {

  value = "${tls_private_key.linuxsrvuserprivkey}"
  sensitive = true
}
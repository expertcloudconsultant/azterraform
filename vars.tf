#Variable file used to store details of repetitive references
variable "location" {
  description = "availability zone that is a string type variable"
  type        = string
  default     = "eastus2"
}



variable "prefix" {
  type    = string
  default = "emc-eus2-corporate"
}

variable "rg" {
  type    = string
  default = "emc-eus2-corporate-resources-rg"

}

variable "web_server_port" {
description = "dedicated port for webserver"
default = 80

}

variable "ssh_access_port" {
description = "dedicated ssh port for webserver shell access"
default = 22

}


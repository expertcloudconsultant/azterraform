#Variable file used to store details of repetitive references
variable "location" {
  description = "availability zone that is a string type variable"
  type    = string
  default = "eastus2"
}



variable "prefix" {
  type    = string
  default = "emc-eus2-corporate"
}

variable "rg" {
type = string
default = "emc-eus2-corporate-resources-rg"

}

#data azurerm_resource_group "vm" {
#  name = var.resource_group_name
#}

data "azurerm_subnet" "sn" {
  name                 = "subnet1"
  virtual_network_name = "acctvnet"
  resource_group_name  = var.resource_group_name
}

  resource "azurerm_network_interface" "nic_udemy_web_server" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.nicname

  ip_configuration {
    name                          = "TestConfiguartion1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
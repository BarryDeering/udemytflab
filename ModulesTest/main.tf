provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "my-resources"
  location = "UK South"
}

module "vnet" {
  source              = "../modules/vnet"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
  
  
  #subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  #subnet_names        = ["subnet1", "subnet2", "subnet3"]

subnets = {

subnet1 = "10.0.1.0/24"
subnet2 = "10.0.2.0/24"
subnet3 = "10.0.3.0/24"

}


  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

#module "vm" {
#  source              = "../modules/vm"
#  resource_group_name = azurerm_resource_group.example.name
#  location            = azurerm_resource_group.example.location
#  nicname             = "modulenic"
#  subnet_id           = module.vnet.vnet_subnets.subnet.id[0]

#}




resource "azurerm_resource_group" "rg_udemy"{

    name = var.location
    location = var.resource_group
}


resource "azurerm_virtual_network" "vnet_udemy"{

  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  address_space       = [var.udemy_vnet_address_space]

}

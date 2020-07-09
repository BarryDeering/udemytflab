resource "azurerm_resource_group" "rg_udemy"{

    name = var.resource_group
    location = var.location
}


resource "azurerm_virtual_network" "vnet_udemy"{

  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  address_space       = [var.udemy_vnet_address_space]

}

resource "azurerm_subnet" "sn_udemy_subnet1" {

  name                 = "${var.prefix}-subnet1"
  resource_group_name  = azurerm_resource_group.rg_udemy.name
  virtual_network_name = azurerm_virtual_network.vnet_udemy.name
  address_prefixes     = [var.udemy_subnet1_address_prefix]

  }

  resource "azurerm_network_interface" "nic_udemy_web_server" {
  name                = "${var.prefix}-${var.udemy_web_server}-nic"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name

  ip_configuration {
    name                          = "${var.prefix}-${var.udemy_web_server}-ip"
    subnet_id                     = azurerm_subnet.sn_udemy_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "pip_udemy_web_server" {
  name                = "${var.prefix}-${var.udemy_web_server}-pip"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  #condional example (true or false) - if production then Static else Dynamic
  allocation_method   = var.environment == "production" ? "Static" : "Dynamic"

}

resource "azurerm_network_security_group" "sn_udemy_subnet1_nsg" {
  name                = "${azurerm_subnet.sn_udemy_subnet1.name}-nsg"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "sn_udemy_subnet1_nsg_asc" {
  subnet_id                 = azurerm_subnet.sn_udemy_subnet1.id
  network_security_group_id = azurerm_network_security_group.sn_udemy_subnet1_nsg.id
}
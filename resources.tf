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

resource "azurerm_windows_virtual_machine" "vm_udemy_vm1" {
  name                = var.udemy_web_server
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic_udemy_web_server.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServerSemiAnnual"
    sku       = "Datacenter-Core-1709-smalldisk"
    version   = "latest"
  }
  
}

resource "azurerm_lb" "lb_udemy_webserver" {
  name                = ${var.prefix}-${var.udemy_web_server}-lb
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name

  frontend_ip_configuration {
    name                          = "LoadBalancerFrontEnd"
    public_ip_address_id          = azurerm_public_ip.pip_udemy_web_server.id
  }
}

resource "azurerm_lb_nat_rule" "nat_udemy_webserver" {
  resource_group_name = azurerm_resource_group.rg_udemy.name
  loadbalancer_id                = azurerm_lb.lb_udemy_webserver.id
  name                           = "RDPNAT"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}


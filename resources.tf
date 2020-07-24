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
  # unique nic name using format - %02d is to format count to 2 decimal places
  name                = "${var.prefix}-${var.udemy_web_server}-${format("%02d",count.index)}-nic"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  count               = var.udemy_web_server_count

  ip_configuration {
    name                          = "TestConfiguartion1"
    subnet_id                     = azurerm_subnet.sn_udemy_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "pip_udemy_web_server" {
  name                = "${var.prefix}-${var.udemy_web_server}-pip"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  allocation_method   = "Static"
  domain_name_label =  "${var.prefix}-${var.udemy_web_server}-dns"
  #count               = var.udemy_web_server_count
}

resource "azurerm_network_security_group" "sn_udemy_subnet1_nsg" {
  name                = "${azurerm_subnet.sn_udemy_subnet1.name}-nsg"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name

  security_rule {
    name                       = "Allow_internet_remote_access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389","443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "sn_udemy_subnet1_nsg_asc" {
  subnet_id                 = azurerm_subnet.sn_udemy_subnet1.id
  network_security_group_id = azurerm_network_security_group.sn_udemy_subnet1_nsg.id
}

resource "azurerm_windows_virtual_machine" "vm_udemy_vm1" {
  name                = "${var.udemy_web_server}-${format("%02d",count.index)}"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.nic_udemy_web_server[count.index].id]
  enable_automatic_updates = true
  #availability_set_id = azurerm_availability_set.as_udemy_webserver.id 
  count               = var.udemy_web_server_count
  
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
  name                = "${var.prefix}-${var.udemy_web_server}-lb"
  location            = azurerm_resource_group.rg_udemy.location
  resource_group_name = azurerm_resource_group.rg_udemy.name
  #count               = var.udemy_web_server_count

  frontend_ip_configuration {
    name                          = "LoadBalancerFrontEnd"
    public_ip_address_id          = azurerm_public_ip.pip_udemy_web_server.id
  }
}

resource "azurerm_lb_backend_address_pool" "lbbe_udemy_webserver" {
    resource_group_name = azurerm_resource_group.rg_udemy.name
    loadbalancer_id     = azurerm_lb.lb_udemy_webserver.id
    name                = "BackEndAddressPool"
    #count = 2
}

resource "azurerm_network_interface_backend_address_pool_association" "lbbepool_udemy_webserver" {
    #network_interface_id    =   count.index == 0 ? azurerm_network_interface.nic_udemy_web_server.id : null
    network_interface_id    =   azurerm_network_interface.nic_udemy_web_server[0].id
    #ip_configuration_name   = "ipConfiguration"
    ip_configuration_name    = "TestConfiguartion1"
    backend_address_pool_id = azurerm_lb_backend_address_pool.lbbe_udemy_webserver.id 
    #count = 2  
}

resource "azurerm_lb_nat_rule" "nat_udemy_webserver" {
  resource_group_name = azurerm_resource_group.rg_udemy.name
  loadbalancer_id                = azurerm_lb.lb_udemy_webserver.id
  name                           = "RDPNAT"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  #count = 2
}

resource "azurerm_network_interface_nat_rule_association" "natasc_udemy_webserver" {
  #network_interface_id  = count.index == 0 ? azurerm_network_interface.nic_udemy_web_server.id : null
  network_interface_id  = azurerm_network_interface.nic_udemy_web_server[0].id
  ip_configuration_name = "TestConfiguartion1"
  nat_rule_id           = azurerm_lb_nat_rule.nat_udemy_webserver.id
  #count = 2
}

resource "azurerm_availability_set" "as_udemy_webserver" {
    name                = "${var.prefix}-${var.udemy_web_server}-as"
    location            = azurerm_resource_group.rg_udemy.location
    resource_group_name = azurerm_resource_group.rg_udemy.name
    platform_fault_domain_count = "2"

}
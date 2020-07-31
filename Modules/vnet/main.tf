#Azure Generic vNet Module
data azurerm_resource_group "vnet" {
  name = var.resource_group_name
}

resource azurerm_virtual_network "vnet" {
  name                = var.vnet_name
  
  resource_group_name = var.resource_group_name
  location            = var.location

  #resource_group_name = data.azurerm_resource_group.vnet.name
  #location            = data.azurerm_resource_group.vnet.location
  
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  #count                = length(var.subnet_names)
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
 
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = "${each.key}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

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

data "azurerm_subnet" "import" {
  for_each             = var.nsg_ids
  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = [azurerm_subnet.subnet]
}

#resource "azurerm_subnet_network_security_group_association" "vnet" {
#  for_each                  = var.nsg_ids
#  subnet_id                 = data.azurerm_subnet.import[each.key].id
#  network_security_group_id = each.value
#}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
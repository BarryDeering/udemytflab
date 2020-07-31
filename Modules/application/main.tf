resource "azurerm_app_service" "app01" {
  location            = var.location
  resource_group_name = var.rg01_name
  name                = var.app01_name
  app_service_plan_id = var.plan01_id
}

resource "azurerm_app_service_custom_hostname_binding" "app01" {
  depends_on          = [azurerm_app_service.app01]
  resource_group_name = var.rg01_name
  hostname            = var.app01_hostname
  app_service_name    = azurerm_app_service.app01.name
}


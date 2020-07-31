resource "azurerm_app_service" "web01" {
  location            = var.location
  resource_group_name = var.rg04_name
  name                = var.web01_name
  app_service_plan_id = var.plan01_id
}

resource "azurerm_app_service" "web02" {
  location            = var.location
  resource_group_name = var.rg04_name
  name                = var.web02_name
  app_service_plan_id = var.plan01_id
}

resource "azurerm_app_service" "web03" {
  location            = var.location
  resource_group_name = var.rg04_name
  name                = var.web03_name
  app_service_plan_id = var.plan01_id
}


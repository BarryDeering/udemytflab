terraform  {
 backend "azurerm"{
  resource_group_name = "rg-terraform"
  storage_account_name = "bwdlabterraform"
  container_name = "tfstatebackends"
  key = "udemylab.terraform.state"
 }
}

provider "azurerm" {
  version = "~> 2.17.0"
  features{}
}

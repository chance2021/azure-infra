terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "chance-test-aks"
    storage_account_name = "chancetestaccount"
    container_name       = "chancetesttfstate"
    key                  = "codelab.microsoft.tfstate"
  }
}
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}


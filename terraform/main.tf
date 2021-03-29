terraform {
  required_version = ">=0.14"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.51.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

provider "azuread" {}
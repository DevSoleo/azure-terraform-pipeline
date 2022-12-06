terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {

  subscription_id = "8f7ce552-1171-4141-9803-d3797c089def"
  client_id       = "2a736400-ca26-4084-bf7c-6d3d1be21519"
  client_secret   = "JTh8Q~AAAHzVlp3Yb_iTsRFxSA8e6k21mycb5acn"
  tenant_id       = "0eb69488-ad5b-4e22-a678-ab0b5b9febaa"

  features {}
}

provider "azuread" {
  client_id     = "2a736400-ca26-4084-bf7c-6d3d1be21519"
  client_secret = "JTh8Q~AAAHzVlp3Yb_iTsRFxSA8e6k21mycb5acn"
  tenant_id     = "0eb69488-ad5b-4e22-a678-ab0b5b9febaa"
}

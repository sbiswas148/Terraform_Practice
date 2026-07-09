terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "e09e6601-1b61-43c8-a92c-095c5db5bc00"
}

resource "azurerm_virtual_network" "example" {
 name= "test1"
 location = "East US 2"
 address_space = ["10.0.0.0/16"]
 resource_group_name = "Test"

 tags = {
    environment = "Dev"
    Owner = "subrata"
    Department = "Infra"
 } 
}

resource "azurerm_virtual_network" "example-2" {
  name                = "test2"
  resource_group_name = azurerm_virtual_network.example.resource_group_name
  address_space       = ["20.0.2.0/24"]
  location            = azurerm_virtual_network.example.location
}

resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_virtual_network.example.resource_group_name
  virtual_network_name      = azurerm_virtual_network.example.name
  remote_virtual_network_id = azurerm_virtual_network.example-2.id
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_virtual_network.example.resource_group_name
  virtual_network_name      = azurerm_virtual_network.example-2.name
  remote_virtual_network_id = azurerm_virtual_network.example.id
}

resource "azurerm_subnet" "new_subnet" {
  name                 = "subnet_1"
  resource_group_name  = azurerm_virtual_network.example.resource_group_name
  virtual_network_name = azurerm_virtual_network.example-2.name
  address_prefixes     = ["20.0.2.16/28"] # Ensure this does not overlap existing subnets

  delegation {
    name = "dnsresolver-delegation"

    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "new_subnet-2" {
  name                 = "subnet-2"
  resource_group_name  = azurerm_virtual_network.example.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/28"] # Ensure this does not overlap existing subnets
}
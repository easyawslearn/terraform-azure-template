resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.resourse_grp.location
  resource_group_name = azurerm_resource_group.resourse_grp.name
  address_space       = var.vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "api_gateway_subnet" {
  name                 = var.api_gateway_subnet_name
  resource_group_name  = azurerm_resource_group.resourse_grp.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.api_gateway_address_prefixes
}

resource "azurerm_subnet" "api_m_subnet" {
  name                 = var.api_m_subnet_name
  resource_group_name  = azurerm_resource_group.resourse_grp.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.api_m_address_prefixes
}
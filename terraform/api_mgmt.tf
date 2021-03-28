resource "azurerm_api_management" "api_mgmt" {
  name                = "${var.api_mgmt_name}-${random_string.random.result}"
  location            = azurerm_resource_group.resourse_grp.location
  resource_group_name = azurerm_resource_group.resourse_grp.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_name = "Developer_1"

  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.api_m_subnet.id
  }

  #   hostname_configuration {
  #        proxy {
  #             hostname= "api7.outstacart.com"
  #             certificate = "value"
  #             certificate_password = "value"
  #     }
  #   }

  #   hostname_configuration {
  #    portal {
  #             hostname= "portal7.outstacart.com"
  #             certificate = "value"
  #             certificate_password = "value"
  #     }

  #   }


  tags = var.tags

}

resource "random_string" "random" {
  length           = 5
  special          = true
  override_special = "/@£$"
}
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

  hostname_configuration {
    proxy {
      host_name            = "api7.outstacart.com"
      certificate          = base64encode("${path.module}/resources/api7/api7.outstacart.com.p12")
      certificate_password = "welcome123"
    }
  }

  hostname_configuration {
    portal {
      host_name            = "portal7.outstacart.com"
      certificate          = base64encode("${path.module}/resources/portal7/portal7.outstacart.com.p12")
      certificate_password = "welcome123"
    }

  }


  tags = var.tags

}

resource "random_string" "random" {
  length           = 5
  special          = true
  override_special = "/@£$"
}
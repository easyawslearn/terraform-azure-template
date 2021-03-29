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

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_role_assignment" "api_mgmt_user_identity_keyvault_admin" {
  scope                = azurerm_key_vault.rg_keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_api_management.api_mgmt.identity[0].principal_id
}

resource "azurerm_api_management_custom_domain" "custom_domain" {
  api_management_id = azurerm_api_management.api_mgmt.id

  proxy {
    host_name    = "api7.helloapi.uk"
    key_vault_id = azurerm_key_vault_certificate.api_mgmt_cert_api7.secret_id
    //      certificate          = base64encode("${path.module}/resources/api7/api7.outstacart.com.p12")
    //      certificate_password = "welcome123"
  }

  portal {
    host_name    = "portal7.helloapi.uk"
    key_vault_id = azurerm_key_vault_certificate.api_mgmt_cert_portal7.secret_id
    //      certificate          = base64encode("${path.module}/resources/portal7/portal7.outstacart.com.p12")
    //      certificate_password = "welcome123"
  }

  depends_on = [
    azurerm_role_assignment.api_mgmt_user_identity_keyvault_admin
  ]
}

resource "random_string" "random" {
  length           = 5
  special          = true
  override_special = "/@£$"
}
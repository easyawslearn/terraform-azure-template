# AppGateway - User Managed Identity

resource "azurerm_user_assigned_identity" "api_mgmt_user_identity" {
  name                = "${var.api_mgmt_name}-${random_string.random.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "app_gateway_user_identity_keyvault_admin" {
  scope                = azurerm_key_vault.rg_keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.api_mgmt_user_identity.principal_id
}
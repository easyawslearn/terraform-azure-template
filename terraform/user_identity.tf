# AppGateway - User Managed Identity

resource "azurerm_role_assignment" "app_gateway_user_identity_keyvault_admin" {
  scope                = azurerm_key_vault.rg_keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_api_management.api_mgmt.identity[0].principal_id
}
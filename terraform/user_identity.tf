# AppGateway - User Managed Identity

resource "azurerm_user_assigned_identity" "app_gateway_user_identity" {
  name                = "appgwapim-pip_appgatway"
  location            = azurerm_resource_group.resourse_grp.location
  resource_group_name = azurerm_resource_group.resourse_grp.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "app_gateway_user_identity_keyvault_contributor" {
  scope                = azurerm_key_vault.rg_keyvault.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = azurerm_user_assigned_identity.app_gateway_user_identity.principal_id
}
data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "key_vault_administrator" {
  name = "Key Vault Administrator"
}

data "azuread_users" "user" {
  user_principal_names = var.admin_user_principal
}

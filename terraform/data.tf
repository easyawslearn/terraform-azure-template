data "azurerm_client_config" "current" {}

data "azuread_users" "user" {
  user_principal_names = var.admin_user_principal
}

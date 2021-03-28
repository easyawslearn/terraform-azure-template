resource "azurerm_resource_group" "resourse_grp" {
  name     = var.resource_group_name
  location = var.location
    tags = var.tags

}

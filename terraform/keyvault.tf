resource "azurerm_key_vault" "rg_keyvault" {
  name                        = "${var.resource_group_name}-key"
  location                    = azurerm_resource_group.resourse_grp.location
  resource_group_name         = azurerm_resource_group.resourse_grp.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  sku_name                    = "standard"
  soft_delete_enabled         = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id


    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore"
    ]


  }
}

resource "azurerm_role_assignment" "iam_access" {

  for_each = toset(data.azuread_users.user.object_ids)

  scope                = azurerm_key_vault.rg_keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.key
}


resource "azurerm_key_vault_certificate" "api_mgmt_cert" {
  name         = "api-mgmt-cert"
  key_vault_id = azurerm_key_vault.rg_keyvault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=helloapi.uk"
      validity_in_months = 12

      subject_alternative_names {
        dns_names = [
          "api7.helloapi.uk",
          "portal7.helloapi.uk",
        ]
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.iam_access
  ]

}
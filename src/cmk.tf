resource "azurerm_key_vault" "main" {
  name                            = var.md_metadata.name_prefix
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  sku_name                        = "premium"
  tenant_id                       = var.azure_service_principal.data.tenant_id
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  tags                            = var.md_metadata.default_tags

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = ["xx.xx.xx.xx"]
    virtual_network_subnet_ids = [var.vnet.data.infrastructure.default_subnet_id]
  }

  access_policy {
    tenant_id = var.azure_service_principal.data.tenant_id
    object_id = data.azurerm_client_config.main.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Update",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge",
      "WrapKey",
      "UnwrapKey"
    ]
  }
}

resource "azurerm_key_vault_key" "main" {
  name            = var.md_metadata.name_prefix
  key_vault_id    = azurerm_key_vault.main.id
  key_type        = "RSA-HSM"
  key_size        = 2048
  expiration_date = timeadd(timestamp(), "4380h")
  tags            = var.md_metadata.default_tags

  key_opts = [
    "unwrapKey",
    "wrapKey"
  ]
}

resource "azurerm_disk_encryption_set" "main" {
  name                = var.md_metadata.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  key_vault_key_id    = azurerm_key_vault_key.main.id
  tags                = var.md_metadata.default_tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "disk" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = azurerm_disk_encryption_set.main.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.main.identity.0.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]
}

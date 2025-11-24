resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = var.tags
}

resource "azurerm_storage_account_static_website" "this" {
  count                = var.enable_static_website ? 1 : 0
  storage_account_id   = azurerm_storage_account.this.id
  index_document       = var.index_document
  error_404_document   = "404.html"
}
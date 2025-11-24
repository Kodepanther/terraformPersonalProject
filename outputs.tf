output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.learning_rg.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.learning_rg.location
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.learning_vnet.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.learning_vnet.address_space
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.website_storage.storage_account_name
}

output "primary_web_endpoint" {
  description = "Primary web endpoint for static website"
  value       = module.website_storage.primary_web_endpoint
}

output "website_url" {
  description = "URL to access the static website"
  value       = "https://${module.website_storage.primary_web_host}"
}
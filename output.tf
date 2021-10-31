output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = local.location
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = element(concat(azurerm_storage_account.storeacc.*.id, [""]), 0)
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = element(concat(azurerm_storage_account.storeacc.*.name, [""]), 0)
}

output "primary_sql_server_id" {
  description = "The primary Microsoft SQL Server ID"
  value       = azurerm_sql_server.primary.id
}

output "primary_sql_server_fqdn" {
  description = "The fully qualified domain name of the primary Azure SQL Server"
  value       = azurerm_sql_server.primary.fully_qualified_domain_name
}

output "secondary_sql_server_id" {
  description = "The secondary Microsoft SQL Server ID"
  value       = element(concat(azurerm_sql_server.secondary.*.id, [""]), 0)
}

output "secondary_sql_server_fqdn" {
  description = "The fully qualified domain name of the secondary Azure SQL Server"
  value       = element(concat(azurerm_sql_server.secondary.*.fully_qualified_domain_name, [""]), 0)
}

output "sql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = azurerm_sql_server.primary.administrator_login
  sensitive   = true
}

output "sql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = azurerm_sql_server.primary.administrator_login_password
  sensitive   = true
}

output "sql_database_id" {
  description = "The SQL Database ID"
  value       = azurerm_sql_database.db.id
}

output "sql_database_name" {
  description = "The SQL Database Name"
  value       = azurerm_sql_database.db.name
}

output "sql_failover_group_id" {
  description = "A failover group of databases on a collection of Azure SQL servers."
  value       = element(concat(azurerm_sql_failover_group.fog.*.id, [""]), 0)
}

output "primary_sql_server_private_endpoint" {
  description = "id of the Primary SQL server Private Endpoint"
  value       = element(concat(azurerm_private_endpoint.pep1.*.id, [""]), 0)
}

output "secondary_sql_server_private_endpoint" {
  description = "id of the Primary SQL server Private Endpoint"
  value       = element(concat(azurerm_private_endpoint.pep2.*.id, [""]), 0)
}

output "sql_server_private_dns_zone_domain" {
  description = "DNS zone name of SQL server Private endpoints dns name records"
  value       = var.existing_private_dns_zone == null && var.enable_private_endpoint ? element(concat(azurerm_private_dns_zone.dnszone1.*.name, [""]), 0) : var.existing_private_dns_zone
}

output "primary_sql_server_private_endpoint_ip" {
  description = "Priamary SQL server private endpoint IPv4 Addresses "
  value       = element(concat(data.azurerm_private_endpoint_connection.private-ip1.*.private_service_connection.0.private_ip_address, [""]), 0)
}

output "primary_sql_server_private_endpoint_fqdn" {
  description = "Priamary SQL server private endpoint IPv4 Addresses "
  value       = element(concat(azurerm_private_dns_a_record.arecord1.*.fqdn, [""]), 0)
}

output "secondary_sql_server_private_endpoint_ip" {
  description = "Secondary SQL server private endpoint IPv4 Addresses "
  value       = element(concat(data.azurerm_private_endpoint_connection.private-ip2.*.private_service_connection.0.private_ip_address, [""]), 0)
}

output "secondary_sql_server_private_endpoint_fqdn" {
  description = "Secondary SQL server private endpoint IPv4 Addresses "
  value       = element(concat(azurerm_private_dns_a_record.arecord2.*.fqdn, [""]), 0)
}

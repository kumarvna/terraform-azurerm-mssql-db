output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = module.mssql-server.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = module.mssql-server.resource_group_location
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.mssql-server.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mssql-server.storage_account_name
}

output "primary_sql_server_id" {
  description = "The primary Microsoft SQL Server ID"
  value       = module.mssql-server.primary_sql_server_id
}

output "primary_sql_server_fqdn" {
  description = "The fully qualified domain name of the primary Azure SQL Server"
  value       = module.mssql-server.primary_sql_server_fqdn
}

output "secondary_sql_server_id" {
  description = "The secondary Microsoft SQL Server ID"
  value       = module.mssql-server.secondary_sql_server_id
}

output "secondary_sql_server_fqdn" {
  description = "The fully qualified domain name of the secondary Azure SQL Server"
  value       = module.mssql-server.secondary_sql_server_fqdn
}

output "sql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = module.mssql-server.sql_server_admin_user
  sensitive   = true
}

output "sql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = module.mssql-server.sql_server_admin_password
  sensitive   = true
}

output "sql_database_id" {
  description = "The SQL Database ID"
  value       = module.mssql-server.sql_database_id
}

output "sql_database_name" {
  description = "The SQL Database Name"
  value       = module.mssql-server.sql_database_name
}

output "sql_failover_group_id" {
  description = "A failover group of databases on a collection of Azure SQL servers."
  value       = module.mssql-server.sql_failover_group_id
}

output "primary_sql_server_private_endpoint" {
  description = "id of the Primary SQL server Private Endpoint"
  value       = module.mssql-server.primary_sql_server_private_endpoint
}

output "secondary_sql_server_private_endpoint" {
  description = "id of the Primary SQL server Private Endpoint"
  value       = module.mssql-server.secondary_sql_server_private_endpoint
}

output "sql_server_private_dns_zone_domain" {
  description = "DNS zone name of SQL server Private endpoints dns name records"
  value       = module.mssql-server.sql_server_private_dns_zone_domain
}

output "primary_sql_server_private_endpoint_ip" {
  description = "Priamary SQL server private endpoint IPv4 Addresses "
  value       = module.mssql-server.primary_sql_server_private_endpoint_ip
}

output "primary_sql_server_private_endpoint_fqdn" {
  description = "Priamary SQL server private endpoint IPv4 Addresses "
  value       = module.mssql-server.primary_sql_server_private_endpoint_fqdn
}

output "secondary_sql_server_private_endpoint_ip" {
  description = "Secondary SQL server private endpoint IPv4 Addresses "
  value       = module.mssql-server.secondary_sql_server_private_endpoint_ip
}

output "secondary_sql_server_private_endpoint_fqdn" {
  description = "Secondary SQL server private endpoint IPv4 Addresses "
  value       = module.mssql-server.secondary_sql_server_private_endpoint_fqdn
}

# Azure SQL Database Terraform Module

Terraform module for Azure to create a MS SQL server with initial database, Azure AD login, Firewall rules, Failover Group, Private endpoint, and corresponding private DNS zone. It also supports creating a database with a custom SQL script initialization.

## Module Usage for

- [Simple SQL Single DB Creation](Simple_SQL_Single_Database_creation/)
- [Simple SQL Single DB with Private link Endpoint](Simple_SQL_Single_Database_Using_Private_Endpoint/)
- [SQL DB with Geo-Replication and Auto Failover Groups](SQL_DB_Using_Geo-replication_with_Auto-Failover_Groups/)
- [SQL DB with Geo-Replication, Private Endpoints, and Auto Failover Groups](SQL_DB_Using_Geo-replication_with_Auto-Failover_Groups_and_Private_Endpoints/)

## Terraform Usage

To run this example you need to execute following Terraform commands

```bash
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.

## Outputs

Name | Description
---- | -----------
`resource_group_name` | The name of the resource group in which resources are created
`resource_group_location`| The location of the resource group in which resources are created
`storage_account_id`|The ID of the storage account
`storage_account_name`|The name of the storage account
`primary_sql_server_id`|The primary Microsoft SQL Server ID
`primary_sql_server_fqdn`|The fully qualified domain name of the primary Azure SQL Server
`secondary_sql_server_id`|The secondary Microsoft SQL Server ID
`secondary_sql_server_fqdn`|The fully qualified domain name of the secondary Azure SQL Server
`sql_server_admin_user`|SQL database administrator login id
`sql_server_admin_password`|SQL database administrator login password
`sql_database_id`|The SQL Database ID
`sql_database_name`|The SQL Database Name
`sql_failover_group_id`|A failover group of databases on a collection of Azure SQL servers
`primary_sql_server_private_endpoint`|id of the Primary SQL server Private Endpoint
`secondary_sql_server_private_endpoint`|id of the Primary SQL server Private Endpoint
`sql_server_private_dns_zone_domain`|DNS zone name of SQL server Private endpoints DNS name records
`primary_sql_server_private_endpoint_ip`|Primary SQL server private endpoint IPv4 Addresses
`primary_sql_server_private_endpoint_fqdn`|Primary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_ip`|Secondary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_fqdn`|Secondary SQL server private endpoint FQDN Addresses

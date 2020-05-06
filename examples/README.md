# Azure SQL Database Using Failover Groups with Private endpoints

Terraform module for Azure to create a SQL server with initial database, Azure AD login, Firewall rules for SQL, Failover Group, Private endpoint, and corresponding private DNS zone for privatelink A records. It also allows creating an SQL server database with a SQL script initialization.

## Configure the Azure Provider

Add AzureRM provider to start with the module configuration. Whilst the `version` attribute is optional, we recommend, not to pinning to a given version of the Provider.

## Create resource group

By default, this module will not create a resource group and the name of an existing resource group to be given in an argument `create_resource_group`. If you want to create a new resource group, set the argument `create_resource_group = true`.

*If you are using an existing resource group, then this module uses the same resource group location to create all resources in this module.*

## Tagging

Use tags to organize your Azure resources and management hierarchy. You can apply tags to your Azure resources, resource groups, and subscriptions to logically organize them into a taxonomy. Each tag consists of a name and a value pair. For example, you can apply the name "Environment" and the value "Production" to all the resources in production. You can manage these values variables directly or mapping as a variable using `variables.tf`.

All Azure resources which support tagging can be tagged by specifying key-values in argument `tags`. Tag Name is added automatically on all resources. For example, you can specify `tags` like this:

```
module "mssql-server" {
  source = "github.com/kumarvit/terraform-azurerm-mssql-db"
  create_resource_group = false

  # ... omitted

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

## Create schema and Initialize SQL Database

This module uses the tool slqcmd as a local provisioner to connect and inject the SQL initialization. To enable this feature set the argument `initialize_sql_script_execution = true` and use `sqldb_init_script_file` argument to provide the path to SQL script.

> #### *Note: To run this utility from your desktop, to create SQL database schema using SQL script requires firewall rule. Allow access to Azure services can be enabled by setting `start_ip_address` and `end_ip_address` to `0.0.0.0` and add your machine public IP to SQL firewall rules to run this feature else this will fail to run and exit the terraform plan.*

> #### *Note: Enabling `extended_auditing_policy` and `threat_detection_policy` features on SQL servers and database going to create a storage account to keep all audit logs. Log retention policy to be configured to keep the size within limits for this storage account. Note that this module creates resources that can cost money.* 

> #### *Note: If you prefer private endpoints feature, firewall rules are not relevant. However, this module can support both the Public and Private availability of the Database. Disable the firewall rules, in case you want to create the database using private endpoints only.*

## Module Usage

### Simple Azure SQL single database creation

Following example is to create a simple database with basic firewall rules to make SQL database available to Azure resources, services and client IP ranges. This module also supports optional AD admin user for DB, Audit Polices, and creation of database schema using SQL script. 

```
module "mssql-server" {
  source = "github.com/kumarvit/terraform-azurerm-mssql-db"

# Resource Group, VNet and Subnet declarations
  create_resource_group           = false
  resource_group_name             = "rg-demo-westeurope-01"
  location                        = "westeurope"
  virtual_network_name            = "vnet-demo-westeurope-001"
  private_subnet_address_prefix   = "10.0.5.0/29"

# SQL Server and Database scaling options
  sqlserver_name                  = "sqldbserver-db01"
  database_name                   = "demomssqldb"
  sql_database_edition            = "Standard"
  sqldb_service_objective_name    = "S1"

# SQL Server and Database Audit policies  
  enable_auditing_policy          = true
  enable_threat_detection_policy  = true
  log_retention_days              = 30
  email_addresses_for_alerts      = ["user@example.com"]

# AD administrator for an Azure SQL server
  enable_sql_ad_admin             = true
  ad_admin_login_name             = "firstname.lastname@tieto.com"

# Firewall Rules to allow azure and external clients
  enable_firewall_rules           = true
  firewall_rules = [
                {name             = "access-to-azure"
                start_ip_address  = "0.0.0.0"
                end_ip_address    = "0.0.0.0"},
                {name             = "desktop-ip"
                start_ip_address  = "123.201.75.71"
                end_ip_address    = "123.201.75.71"}]

# Create and initialize a database with SQL script
  initialize_sql_script_execution = false
  sqldb_init_script_file          = "./artifacts/db-init-sample.sql"

# Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

### Simple Azure SQL single database using private Endpoint 

Following example to create a SQL single database using private endpoints. This module also supports optional AD admin user for DB, Audit Policies, and creation of database schema using SQL script. 

```
module "mssql-server" {
  source = "github.com/kumarvit/terraform-azurerm-mssql-db"

# Resource Group, VNet and Subnet declarations
  create_resource_group           = false
  resource_group_name             = "rg-demo-westeurope-01"
  location                        = "westeurope"
  virtual_network_name            = "vnet-demo-westeurope-001"
  private_subnet_address_prefix   = "10.0.5.0/29"

# SQL Server and Database scaling options
  sqlserver_name                  = "sqldbserver-db01"
  database_name                   = "demomssqldb"
  sql_database_edition            = "Standard"
  sqldb_service_objective_name    = "S1"

# SQL Server and Database Audit policies  
  enable_auditing_policy          = true
  enable_threat_detection_policy  = true
  log_retention_days              = 30
  email_addresses_for_alerts      = ["user@example.com"]

# AD administrator for an Azure SQL server
  enable_sql_ad_admin             = true
  ad_admin_login_name             = "firstname.lastname@tieto.com"

# Private Endpoint for Sql servers
  enable_private_endpoint         = true

# Create and initialize a database with SQL script
  initialize_sql_script_execution = false
  sqldb_init_script_file          = "./artifacts/db-init-sample.sql"

# Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

### Azure SQL database creation using geo-replication with auto-failover groups 

Following example to create a SQL database using geo-replication with auto-failover groups. This module also supports optional AD admin user for DB, Audit Policies, Firewall Rules, and creation of database schema using SQL script. 

```
module "mssql-server" {
  source = "github.com/kumarvit/terraform-azurerm-mssql-db"

# Resource Group, VNet and Subnet declarations
  create_resource_group           = false
  resource_group_name             = "rg-demo-westeurope-01"
  location                        = "westeurope"
  virtual_network_name            = "vnet-demo-westeurope-001"
  private_subnet_address_prefix   = "10.0.5.0/29"

# SQL Server and Database scaling options
  sqlserver_name                  = "sqldbserver-db01"
  database_name                   = "demomssqldb"
  sql_database_edition            = "Standard"
  sqldb_service_objective_name    = "S1"

# SQL Server and Database Audit policies  
  enable_auditing_policy          = true
  enable_threat_detection_policy  = true
  log_retention_days              = 30
  email_addresses_for_alerts      = ["user@example.com"]

# AD administrator for an Azure SQL server
  enable_sql_ad_admin             = true
  ad_admin_login_name             = "firstname.lastname@tieto.com"

# Firewall Rules to allow azure and external clients
  enable_firewall_rules           = true
  firewall_rules = [
                {name             = "access-to-azure"
                start_ip_address  = "0.0.0.0"
                end_ip_address    = "0.0.0.0"},
                {name             = "desktop-ip"
                start_ip_address  = "123.201.75.71"
                end_ip_address    = "123.201.75.71"}]

# Sql failover group
  enable_failover_group           = true
  secondary_sql_server_location   = "northeurope"

# Create and initialize a database with SQL script
  initialize_sql_script_execution = false
  sqldb_init_script_file          = "./artifacts/db-init-sample.sql"

# Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

### Azure SQL database creation using geo-replication with auto-failover groups and Private Endpoints 

Following example to create a SQL database using geo-replication with auto-failover groups and private endpoints. This module also supports optional AD admin user for DB, Audit Policies, Firewall Rules, and creation of database schema using SQL script. 

```
module "mssql-server" {
  source = "github.com/kumarvit/terraform-azurerm-mssql-db"

# Resource Group, VNet and Subnet declarations
  create_resource_group           = false
  resource_group_name             = "rg-demo-westeurope-01"
  location                        = "westeurope"
  virtual_network_name            = "vnet-demo-westeurope-001"
  private_subnet_address_prefix   = "10.0.5.0/29"

# SQL Server and Database scaling options
  sqlserver_name                  = "sqldbserver-db01"
  database_name                   = "demomssqldb"
  sql_database_edition            = "Standard"
  sqldb_service_objective_name    = "S1"

# SQL Server and Database Audit policies  
  enable_auditing_policy          = true
  enable_threat_detection_policy  = true
  log_retention_days              = 30
  email_addresses_for_alerts      = ["user@example.com"]

# AD administrator for an Azure SQL server
  enable_sql_ad_admin             = true
  ad_admin_login_name             = "firstname.lastname@tieto.com"

# Sql failover group
  enable_failover_group           = true
  secondary_sql_server_location   = "northeurope"

# Private Endpoint for Sql servers
  enable_private_endpoint         = true

# Create and initialize a database with SQL script
  initialize_sql_script_execution = false
  sqldb_init_script_file          = "./artifacts/db-init-sample.sql"

# Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

## Terraform Usage

To run this example you need to execute following Terraform commands

```
$ terraform init
$ terraform plan
$ terraform apply
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
`sql_server_private_dns_zone_domain`|DNS zone name of SQL server Private endpoints dns name records
`primary_sql_server_private_endpoint_ip`|Priamary SQL server private endpoint IPv4 Addresses
`primary_sql_server_private_endpoint_fqdn`|Priamary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_ip`|Secondary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_fqdn`|Secondary SQL server private endpoint IPv4 Addresses
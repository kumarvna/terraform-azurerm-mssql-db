# Azure SQL Database - Using Failover Groups with Private Endpoints

[![Terraform](https://img.shields.io/badge/Terraform%20-0.12-brightgreen.svg?style=flat)](https://github.com/hashicorp/terraform/releases) [![License](https://img.shields.io/badge/License%20-MIT-brightgreen.svg?style=flat)](https://github.com/kumarvna/cloudascode/blob/master/LICENSE)

Terraform module for Azure to create a SQL server with initial database, Azure AD login, Firewall rules for SQL, Failover Group, Private endpoint, and corresponding private DNS zone for privatelink A records. It also allows creating an SQL server database with a SQL script initialization.

A single database is the quickest and simplest deployment option for Azure SQL Database. You manage a single database within a SQL Database server, which is inside an Azure resource group in a specified Azure region. In this quickstart, you create a new resource group and SQL server for the new database.

You can create a single database in the provisioned or serverless compute tier. A provisioned database is pre-allocated a fixed amount of compute resources, including CPU and memory, and uses one of two purchasing models. This quickstart creates a provisioned database using the vCore-based purchasing model, but you can also choose a DTU-based model.

## These types of resources are supported

* [SQL Servers](https://www.terraform.io/docs/providers/azurerm/r/sql_server.html)
* [SQL Database](https://www.terraform.io/docs/providers/azurerm/r/mysql_database.html)
* [Storage account for diagnostics](https://www.terraform.io/docs/providers/azurerm/r/storage_account.html) 
* [Active Directory Administrator](https://www.terraform.io/docs/providers/azurerm/r/sql_active_directory_administrator.html)
* [Firewall rule for azure services, resources, and client IP](https://www.terraform.io/docs/providers/azurerm/r/sql_firewall_rule.html)
* [SQL Failover Group](https://www.terraform.io/docs/providers/azurerm/r/sql_failover_group.html)
* [SQL Private Endpoint](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* [Private DNS zone for privatelink A records](https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html)
* [SQL Script execution to create Database](https://docs.microsoft.com/en-us/sql/ssms/scripting/sqlcmd-run-transact-sql-script-files?view=sql-server-ver15)

> #### *Note: If you prefer private endpoints feature, firewall rules are not relevant. However, this module can support both the Public and Private availability of the Database. Disable the firewall rules, in case you want to create the database using private endpoints only.*

## Module Usage

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

## Prerequisites

### Resource Group

By default, this module will not create a resource group and the name of an existing resource group to be given in an argument `create_resource_group`. If you want to create a new resource group, set the argument `create_resource_group = true`.

*If you are using an existing resource group, then this module uses the same resource group location to create all resources in this module.*

### VNet and Subnets

This module is not going to create a Vnet and corresponding services. However, this module expect you to provide VPC and Subnet address space for private end points. 

Deploy Azure Vnet terraform module to overcome with this dependency. The [`terraform-azurerm-vnet`](https://github.com/tietoevry-cloud-infra/terraform-azurerm-vnet) module currently available from [GitHub](https://github.com/tietoevry-cloud-infra/terraform-azurerm-vnet), also aligned with this module.

### `sqlcmd` utility  

This module uses the tool [slqcmd](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15) as a local provisioner to connect and inject the SQL initialization. Therefore, the following dependencies must be installed beforehand on your machine:

* [Microsoft OBDC Driver](https://www.microsoft.com/en-us/download/details.aspx?id=56567)

* Install the Microsoft sqlcmd utility on [Ubuntu](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15#ubuntu) or on [Windows](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15)

## `extended_auditing_policy` - Auditing for SQL Database

Auditing for Azure SQL Database tracks database events and writes them to an audit log in an Azure storage account, Log Analytics workspace, or Event Hubs. If server auditing is enabled, it always applies to the database. The database will be audited, regardless of the database auditing settings.
By default, this feature not enabled on the module. To enable the threat detection policy for the database, set the argument `enable_auditing_policy = true`.

## `threat_detection_policy` - SQL Database Advanced Threat Protection

Advanced Threat Protection for single and pooled databases detects anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases. Advanced Threat Protection can identify Potential SQL injection, Access from unusual location or data center, Access from the unfamiliar principal or potentially harmful application, and Brute force SQL credentials - see more details in Advanced Threat Protection alerts.

By default, this feature not enabled on this module. To enable the threat detection policy for the database, set the argument `enable_threat_detection_policy = true`.

> #### Note: Enabling `extended_auditing_policy` and `threat_detection_policy` features on SQL servers and database going to create a storage account to keep all audit logs. Log retention policy to be configured to keep the size within limits for this storage account. Note that this module creates resources that can cost money.

## Adding Active Directory Administrator to SQL Database

Azure Active Directory authentication is a mechanism of connecting to Microsoft Azure SQL Database by using identities in Azure Active Directory (Azure AD). This module adds the provided Azure Active Directory user/group to SQL Database as an administrator so that the user can login to this database with Azure AD authentication.   

By default, this feature not enabled on this module. To add the Active Directory Administrator to SQL database, set the argument `enable_sql_ad_admin = true` and provide valid Azure AD user login name (`ad_admin_login_name`). 

## Configuring the Azure SQL Database Firewall

The Azure SQL Database firewall lets you decide which IP addresses may or may not have access to either your Azure SQL Server or your Azure SQL database.  When creating an Azure SQL Database, the firewall needs to be configured before anyone will be able to access the database. 

**Server level rules:** 

Server level rules allow access to the Azure SQL Server. Which means that the client will have access to all the databases stored on that SQL Server. As a best practice, server level access should only be given when absolutely necessary and database level rules must be used wherever possible.

**Database level rules:** 

Using database level rules adds security by ensuring that clients do not have access to database that they don’t need and it also makes it easier to move databases, since the rules are contained within the database itself.

By default, no external access to your SQL Database will be allowed until you explicitly assign permission by creating a firewall rule.  To add the firewall rules to the SQL database, set the argument `enable_firewall_rules = true` and provide the required IP ranges. 

> #### Additionally, If you enable Private endpoint feature, firewall rules are not relevant. It does not require adding any IP addresses to the firewall on Azure SQL Database or changing the connection string of your application for private links.

## Azure SQL Geo-Replication and Failover Groups

Microsoft Azure offers different types of business continuity solutions for their SQL database. One of these solutions is Geo-Replication that provides an asynchronous database copy. You can store this copy in the same or different regions. You can setup up to four readable database copies. In the documentation of Microsoft notes, the recovery point objective (RPO is the maximum acceptable amount of data loss measured in time) is less than 5 seconds. If we want to automate and make (users will not affect) failover mechanism transparent, we have to create the auto-failover group.

![enter image description here](https://docs.microsoft.com/en-us/azure/sql-database/media/sql-database-auto-failover-group/auto-failover-group.png)

You can put several single databases on the same SQL Database server into the same failover group. If you add a single database to the failover group, it automatically creates a secondary database using the same edition and the compute size on the secondary server. You specified that server when the failover group was created.

By default, this feature not enabled on this module. To create SQL geo-replicated auto failover groups, set the argument `enable_failover_group = true`. This create a failover groups secondary server location `secondary_sql_server_location` to be provided. 


## Using Failover Groups with Private Link for Azure SQL Database

Azure SQL Database offers the ability to manage geo-replication and failover of a group of databases by adding them to the failover group.  A failover group spans two servers – a primary server where the databases are accessed by the end-user or application & a secondary server in a different region where a copy of each database is kept in sync using active geo-replication.

Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet.

![enter image description here](https://docs.microsoft.com/en-us/azure/sql-database/media/sql-database-get-started-portal/pe-connect-overview.png)

With Private Link, Microsoft offering the ability to associate a logical server to a specific private IP address (also known as private endpoint) within the Vnet. This module helps to implement Failover Groups using private endpoint for SQL Database instead of the public endpoint thus ensuring that customers can get security benefits that it offers.

Clients can connect to the Private endpoint from the same VNet, peered VNet in same region, or via VNet-to-VNet connection across regions. Additionally, clients can connect from on-premises using ExpressRoute, private peering, or VPN tunneling. Below is a simplified diagram showing the common use cases.

## Create schema and Initialize SQL Database

This module uses the tool slqcmd as a local provisioner to connect and inject the SQL initialization. To enable this feature set the argument `initialize_sql_script_execution = true` and use `sqldb_init_script_file` argument to provide the path to SQL script.

> #### Note: To run this utility from your desktop, to create SQL database schema using SQL script requires firewall rule. Allow access to Azure services can be enabled by setting `start_ip_address` and `end_ip_address` to `0.0.0.0` and add your machine public IP to SQL firewall rules to run this feature else this will fail to run and exit the terraform plan.

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

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`create_resource_group` | Whether to create resource group and use it for all networking resources | string | `"false"`
`resource_group_name`|The name of an existing resource group.|string|`"rg-demo-westeurope-01"`
`location`|The location for all resources while creating a new resource group.|string|`"westeurope"`
`sqlserver_name`|The name of the Microsoft SQL Server|string|`""`
`database_name`|The name of the SQL database|string|`""`
`sql_database_edition`|The edition of the database to be created|string|`"Standard"`
`sqldb_service_objective_name`|The service objective name for the database|string|`"S1"`
`enable_auditing_policy`|Auditing for SQL Database|string|`"false"`
`enable_threat_detection_policy`|Threat detection policy configuration|string|`"false"`
`log_retention_days`|Specifies the number of days to retain logs for in the storage account|`number`|`30`
`email_addresses_for_alerts`|Account administrators email for alerts|`list(string)`|`""`
`enable_sql_ad_admin`|Set a user or group as the AD administrator for an Azure SQL server|string|`"false"`
`ad_admin_login_name`|The login name of the principal to set as the server administrator|string|`""`
`enable_firewall_rules`|Manages a Firewall Rule for a MySQL Server|string|`"false"`
`firewall_rules`| list of firewall rules to add SQL servers| `list(string)`| `""`
`enable_failover_group`|Create a failover group of databases on a collection of Azure SQL servers|string| `"false"`
`secondary_sql_server_location`|The location of the secondary SQL server (applicable if Failover groups enabled)|`"northeurope"`
`enable_private_endpoint`|Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link|string|`"false"`
`virtual_network_name` | The name of the virtual network|string|`""`
`private_subnet_address_prefix`|A list of subnets address prefixes inside virtual network| list |`[]`
`initialize_sql_script_execution`|enable sqlcmd tool to connect and create database schema|string| `"false"`
`sqldb_init_script_file`|SQL file to execute via sqlcmd utility to create required database schema |string|`""`
`Tags`|A map of tags to add to all resources|map|`{}`

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

## Resource Graph

![](graph.png)

## Authors

Module is maintained by [Kumaraswamy Vithanala](mailto:kumaraswamy.vithanala@tieto.com) with the help from other awesome contributors.

## Other resources

* [Azure SQL Database documentation](https://docs.microsoft.com/en-us/azure/sql-database/)

* [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)
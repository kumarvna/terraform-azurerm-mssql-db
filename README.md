# Azure SQL Database - Using Failover Groups with Private Endpoints

Terraform module to create an MS SQL server with initial database, Azure AD login, Firewall rules, geo-replication using auto-failover groups, Private endpoints, and corresponding private DNS zone. It also supports creating a database with a custom SQL script initialization.

A single database is the quickest and simplest deployment option for Azure SQL Database. You manage a single database within a SQL Database server, which is inside an Azure resource group in a specified Azure region with this module.

You can also create a single database in the provisioned or serverless compute tier. A provisioned database is pre-allocated a fixed amount of computing resources, including CPU and memory, and uses one of two purchasing models. This module creates a provisioned database using the vCore-based purchasing model, but you can choose a DTU-based model as well.

> **[NOTE]**
> **This module now supports the meta arguments including `providers`, `depends_on`, `count`, and `for_each`.**

## Resources supported

* [SQL Servers](https://www.terraform.io/docs/providers/azurerm/r/sql_server.html)
* [SQL Database](https://www.terraform.io/docs/providers/azurerm/r/mysql_database.html)
* [Storage account for diagnostics](https://www.terraform.io/docs/providers/azurerm/r/storage_account.html)
* [Active Directory Administrator](https://www.terraform.io/docs/providers/azurerm/r/sql_active_directory_administrator.html)
* [Firewall rule for azure services, resources, and client IP](https://www.terraform.io/docs/providers/azurerm/r/sql_firewall_rule.html)
* [SQL Auto-Failover Group](https://www.terraform.io/docs/providers/azurerm/r/sql_failover_group.html)
* [Private Endpoints](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* [Private DNS zone for `privatelink` A records](https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html)
* [SQL Script execution to create Database](https://docs.microsoft.com/en-us/sql/ssms/scripting/sqlcmd-run-transact-sql-script-files?view=sql-server-ver15)
* [SQL Server and Database Extended Auditing Policy](https://docs.microsoft.com/en-us/azure/azure-sql/database/auditing-overview)
* [Azure Defender for SQL](https://docs.microsoft.com/en-us/azure/azure-sql/database/azure-defender-for-sql)
* [SQL Vulnerability Assessment](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-vulnerability-assessment)
* [SQL Log Monitoring and Diagnostics](https://docs.microsoft.com/en-us/azure/azure-sql/database/metrics-diagnostic-telemetry-logging-streaming-export-configure?tabs=azure-portal)

## Module Usage

```hcl
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.2.0"

  # By default, this module will create a resource group
  # proivde a name to use an existing resource group and set the argument 
  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  create_resource_group         = false
  resource_group_name           = "rg-shared-westeurope-01"
  location                      = "westeurope"
  virtual_network_name          = "vnet-shared-hub-westeurope-001"
  private_subnet_address_prefix = ["10.1.5.0/29"]

  # SQL Server and Database details
  # The valid service objective name for the database include S0, S1, S2, S3, P1, P2, P4, P6, P11 
  sqlserver_name               = "sqldbserver01"
  database_name                = "demomssqldb"
  sql_database_edition         = "Standard"
  sqldb_service_objective_name = "S1"

  # SQL server extended auditing policy defaults to `true`. 
  # To turn off set enable_sql_server_extended_auditing_policy to `false`  
  # DB extended auditing policy defaults to `false`. 
  # to tun on set the variable `enable_database_extended_auditing_policy` to `true` 
  # To enable Azure Defender for database set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # schedule scan notifications to the subscription administrators
  # Manage Vulnerability Assessment set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = false
  email_addresses_for_alerts      = ["user@example.com", "firstname.lastname@example.com"]

  # Sql failover group creation. required secondary locaiton input. 
  enable_failover_group         = true
  secondary_sql_server_location = "northeurope"

  # enabling the Private Endpoints for Sql servers
  enable_private_endpoint = true

  # AD administrator for an Azure SQL server
  # Allows you to set a user or group as the AD administrator for an Azure SQL server
  ad_admin_login_name = "firstname.lastname@example.com"

  # (Optional) To enable Azure Monitoring for Azure SQL database including audit logs
  # log analytic workspace name required
  enable_log_monitoring        = true
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Firewall Rules to allow azure and external clients and specific Ip address/ranges. 
  enable_firewall_rules = true
  firewall_rules = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "desktop-ip"
      start_ip_address = "49.204.225.134"
      end_ip_address   = "49.204.225.134"
    }
  ]

  # Create and initialize a database with custom SQL script
  # need sqlcmd utility to run this command 
  # your desktop public IP must be added to firewall rules to run this command 
  initialize_sql_script_execution = true
  sqldb_init_script_file          = "../artifacts/db-init-sample.sql"

  # Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

## Default Local Administrator and the Password

This module utilizes __`sqladmin`__ as a local administrator on SQL servers. If you want to you use custom username, then specify the same by setting up the argument `admin_username` with a valid user string.

By default, this module generates a strong password for all virtual machines also allows you to change the length of the random password (currently 24) using the `random_password_length = 32` variable. If you want to set the custom password, specify the argument `admin_password` with a valid string.

### Resource Group

By default, this module will not create a resource group and the name of an existing resource group to be given in an argument `resource_group_name`. If you want to create a new resource group, set the argument `create_resource_group = true`.

*If you are using an existing resource group, then this module uses the same resource group location to create all resources in this module.*

### VNet and Subnets

This module is not going to create a `VNet` and corresponding services. However, this module expect you to provide VPC and Subnet address space for private end points.

Deploy Azure VNet terraform module to overcome with this dependency. The [`terraform-azurerm-vnet`](https://github.com/tietoevry-cloud-infra/terraform-azurerm-vnet) module currently available from [GitHub](https://github.com/tietoevry-cloud-infra/terraform-azurerm-vnet), also aligned with this module.

## Advance usage of module

### `extended_auditing_policy` - Auditing for SQL Database

Auditing for Azure SQL Database and servers tracks database events and writes them to an audit log in an Azure storage account. If server auditing is enabled, it always applies to the database. The database will be audited, regardless of the database auditing settings.

By default, this feature enabled on SQL servers. To manage the threat detection policy for the severs set `enable_sql_server_extended_auditing_policy`to valid string. For database auditing, set the argument `enable_database_extended_auditing_policy` to `true`

### `threat_detection_policy` - SQL Database Advanced Threat Protection

Advanced Threat Protection for single and pooled databases detects anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases. Advanced Threat Protection can identify Potential SQL injection, Access from an unusual location or data center, Access from the unfamiliar principal or potentially harmful application, and Brute force SQL credentials - see more details in Advanced Threat Protection alerts.

By default, this feature not enabled on this module. To enable the threat detection policy for the database, set the argument `enable_threat_detection_policy = true`.

> #### Note: Enabling `extended_auditing_policy` and `threat_detection_policy` features on SQL servers and database going to create a storage account to keep all audit logs. Log retention policy to be configured to keep the size within limits for this storage account. Note that this module creates resources that can cost money

### Adding Active Directory Administrator to SQL Database

Azure Active Directory authentication is a mechanism of connecting to Microsoft Azure SQL Database by using identities in Azure Active Directory (Azure AD). This module adds the provided Azure Active Directory user/group to SQL Database as an administrator so that the user can login to this database with Azure AD authentication.

By default, this feature not enabled on this module. To add the Active Directory Administrator to SQL database, set the argument `ad_admin_login_name` with a valid Azure AD user login name.

### Configuring the Azure SQL Database Firewall

The Azure SQL Database firewall lets you decide which IP addresses may or may not have access to your Azure SQL Server or your Azure SQL database.  When creating an Azure SQL Database, one must add firewall rules before anyone to access the database.

By default, no external access to your SQL Database will be allowed until you explicitly assign permission by creating a firewall rule. To add the firewall rules to the SQL database, set the argument `enable_firewall_rules = true` and provide the required IP ranges.

> #### Additionally, If you enable Private endpoint feature, firewall rules are not relevant. It does not require adding any IP addresses to the firewall on Azure SQL Database or changing the connection string of your application for private links

### Azure SQL Geo-Replication and Failover Groups

Microsoft Azure offers different types of business continuity solutions for their SQL database. One of these solutions is Geo-Replication that provides an asynchronous database copy. You can store this copy in the same or different regions. You can setup up to four readable database copies. If we want to automate and make (users will not affect) failover mechanism transparent, we have to create the auto-failover group.

You can put several single databases on the same SQL Database server into the same failover group. If you add a single database to the failover group, it automatically creates a secondary database using the same edition and the compute size on the secondary server.

For more information, check the [Microsoft Documentation](https://docs.microsoft.com/en-us/azure/azure-sql/database/active-geo-replication-overview)

By default, this feature not enabled on this module. To create SQL geo-replicated auto-failover groups, set the argument `enable_failover_group = true`. To create a failover group, set the secondary server location argument `secondary_sql_server_location` to a valid region.

### Using Failover Groups with Private Link for Azure SQL Database

Azure SQL Database offers the ability to manage geo-replication and failover of a group of databases by adding them to the failover group.  A failover group spans two servers – a primary server where the databases are accessed by the end-user or application & a secondary server in a different region where a copy of each database is kept in sync using active geo-replication.

Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet.

With Private Link, Microsoft offering the ability to associate a logical server to a specific private IP address (also known as private endpoint) within the VNet. This module helps to implement Failover Groups using private endpoint for SQL Database instead of the public endpoint thus ensuring that customers can get security benefits that it offers.

Clients can connect to the Private endpoint from the same VNet, peered VNet in same region, or via VNet-to-VNet connection across regions. Additionally, clients can connect from on-premises using ExpressRoute, private peering, or VPN tunneling.

### Create schema and Initialize SQL Database

This module uses the tool slqcmd as a local provisioner to connect and inject the SQL initialization. To enable this feature set the argument `initialize_sql_script_execution = true` and use `sqldb_init_script_file` argument to provide the path to SQL script.

> #### Note: To create SQL database schema using SQL script from your desktop requires the addition of a firewall rule. Add your machine public IP to firewall rules to run this feature else this will fail to run and exit the terraform plan

Installation of the Microsoft `sqlcmd` utility on [Ubuntu](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15#ubuntu) or on [Windows](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15) found here.

## Recommended naming and tagging conventions

Applying tags to your Azure resources, resource groups, and subscriptions to logically organize them into a taxonomy. Each tag consists of a name and a value pair. For example, you can apply the name `Environment` and the value `Production` to all the resources in production.
For recommendations on how to implement a tagging strategy, see Resource naming and tagging decision guide.

>**Important** :
Tag names are case-insensitive for operations. A tag with a tag name, regardless of the casing, is updated or retrieved. However, the resource provider might keep the casing you provide for the tag name. You'll see that casing in cost reports. **Tag values are case-sensitive.**

An effective naming convention assembles resource names by using important resource information as parts of a resource's name. For example, using these [recommended naming conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#example-names), a public IP resource for a production SharePoint workload is named like this: `pip-sharepoint-prod-westus-001`.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| azurerm | >= 2.59.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.59.0 |
| random |>= 3.1.0 |
| null | >= 3.1.0 |

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`create_resource_group` | Whether to create resource group and use it for all networking resources | string | `"false"`
`resource_group_name`|The name of an existing resource group.|string|`""`
`location`|The location for all resources while creating a new resource group.|string|`""`
`sqlserver_name`|The name of the Microsoft SQL Server|string|`""`
`database_name`|The name of the SQL database|string|`""`
`admin_username`|The username of the local administrator used for the SQL Server|string|`"azureadmin"`
`admin_password`|The Password which should be used for the local-administrator on this SQL Server|string|`null`
`sql_database_edition`|The edition of the database to be created. Valid values are: `Basic`, `Standard`, `Premium`, `DataWarehouse`, `Business`, `BusinessCritical`, `Free`, `GeneralPurpose`, `Hyperscale`, `Premium`, `PremiumRS`, `Standard`, `Stretch`, `System`, `System2`, or `Web`|string|`"Standard"`
`sqldb_service_objective_name`|The service objective name for the database. Valid values depend on edition and location and may include `S0`, `S1`, `S2`, `S3`, `P1`, `P2`, `P4`, `P6`, `P11`|string|`"S1"`
`enable_sql_server_extended_auditing_policy`|Manages Extended Audit policy for SQL servers|string|`"true"`
`enable_database_extended_auditing_policy`|Manages Extended Audit policy for SQL database|string|`"false"`
`enable_threat_detection_policy`|Threat detection policy configuration|string|`"false"`
`log_retention_days`|Specifies the number of days to retain logs for in the storage account|`number`|`30`
`email_addresses_for_alerts`|Account administrators email for alerts|`list(any)`|`""`
`ad_admin_login_name`|The login name of the principal to set as the server administrator|string|`null`
`enable_firewall_rules`|Manages a Firewall Rule for a MySQL Server|string|`"false"`
`firewall_rules`| list of firewall rules to add SQL servers| `list(object({}))`| `[]`
`enable_failover_group`|Create a failover group of databases on a collection of Azure SQL servers|string| `"false"`
`secondary_sql_server_location`|The location of the secondary SQL server (applicable if Failover groups enabled)|string|`"northeurope"`
`enable_private_endpoint`|Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link|string|`"false"`
`virtual_network_name` | The name of the virtual network|string|`""`
`private_subnet_address_prefix`|A list of subnets address prefixes inside virtual network| list |`[]`
`initialize_sql_script_execution`|enable sqlcmd tool to connect and create database schema|string| `"false"`
`sqldb_init_script_file`|SQL file to execute via sqlcmd utility to create required database schema |string|`""`
`enable_log_monitoring`|Enable audit events to Azure Monitor?|string|`false`
`storage_account_name`|The name of the storage account name|string|`null`
`log_analytics_workspace_name`|The name of log analytics workspace name|string|`null`
`random_password_length`|The desired length of random password created by this module|number|`24`
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
`sql_server_private_dns_zone_domain`|DNS zone name of SQL server Private endpoints DNS name records
`primary_sql_server_private_endpoint_ip`|Primary SQL server private endpoint IPv4 Addresses
`primary_sql_server_private_endpoint_fqdn`|Primary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_ip`|Secondary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_fqdn`|Secondary SQL server private endpoint FQDN Addresses

## Resource Graph

![](graph.png)

## Authors

Originally created by [Kumaraswamy Vithanala](mailto:kumarvna@gmail.com)

## Other resources

* [Azure SQL Database documentation](https://docs.microsoft.com/en-us/azure/sql-database/)

* [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)

<a href="https://trackgit.com">
<img src="https://us-central1-trackgit-analytics.cloudfunctions.net/token/ping/ksoy6wbtv96k7qirtaks" alt="trackgit-views" />
</a>

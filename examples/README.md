# Azure SQL Database Using Failover Groups with Private endpoints

Terraform module for Azure to create a MS SQL server with initial database, Azure AD login, Firewall rules, Failover Group, Private endpoint, and corresponding private DNS zone. It also supports creating a database with a custom SQL script initialization.

## Module Usage

### Simple Azure SQL single database creation

```hcl
module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.1.0"


  # By default, this module will not create a resource group
  # proivde a name to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG. 
  resource_group_name  = "rg-shared-westeurope-01"
  location             = "westeurope"
  virtual_network_name = "vnet-shared-hub-westeurope-001"

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
  # To enable Azure Defender for Azure SQL database servers set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # schedule scan notifications to the subscription administrators
  # Manages the Vulnerability Assessment for a MS SQL Server set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = false
  sql_admin_email_addresses       = ["user@example.com", "firstname.lastname@example.com"]

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
  # your desktop public IP must be added firewall rules to run this command 
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

### Simple Azure SQL single database using private Endpoint

```hcl
module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.1.0"

  # By default, this module will not create a resource group
  # proivde a name to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG.
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
  # To enable Azure Defender for Azure SQL database servers set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # schedule scan notifications to the subscription administrators
  # Manages the Vulnerability Assessment for a MS SQL Server set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = true
  sql_admin_email_addresses       = ["user@example.com", "firstname.lastname@example.com"]

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

### Azure SQL database creation using geo-replication with auto-failover groups

```hcl
module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.1.0"

  # By default, this module will not create a resource group
  # proivde a name to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG. 
  resource_group_name  = "rg-shared-westeurope-01"
  location             = "westeurope"
  virtual_network_name = "vnet-shared-hub-westeurope-001"

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
  # To enable Azure Defender for Azure SQL database servers set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # schedule scan notifications to the subscription administrators
  # Manages the Vulnerability Assessment for a MS SQL Server set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = false
  sql_admin_email_addresses       = ["user@example.com", "firstname.lastname@example.com"]

  # AD administrator for an Azure SQL server
  # Allows you to set a user or group as the AD administrator for an Azure SQL server
  ad_admin_login_name = "firstname.lastname@example.com"

  # (Optional) To enable Azure Monitoring for Azure SQL database including audit logs
  # log analytic workspace name required
  enable_log_monitoring        = true
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Sql failover group creation. required secondary locaiton input. 
  enable_failover_group         = true
  secondary_sql_server_location = "northeurope"

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
  # your desktop public IP must be added firewall rules to run this command 
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

### Azure SQL database creation using geo-replication with auto-failover groups and Private Endpoints

```hcl
module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.1.0"

  # By default, this module will not create a resource group
  # proivde a name to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG.
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
  # To enable Azure Defender for Azure SQL database servers set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # schedule scan notifications to the subscription administrators
  # Manages the Vulnerability Assessment for a MS SQL Server set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = true
  sql_admin_email_addresses       = ["user@example.com", "firstname.lastname@example.com"]

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
`sql_server_private_dns_zone_domain`|DNS zone name of SQL server Private endpoints dns name records
`primary_sql_server_private_endpoint_ip`|Primary SQL server private endpoint IPv4 Addresses
`primary_sql_server_private_endpoint_fqdn`|Primary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_ip`|Secondary SQL server private endpoint IPv4 Addresses
`secondary_sql_server_private_endpoint_fqdn`|Secondary SQL server private endpoint IPv4 Addresses

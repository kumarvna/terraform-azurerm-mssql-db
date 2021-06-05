module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.1.0"

  # By default, this module will create a resource group, proivde the name here
  # to use an existing resource group, specify the existing resource group name,
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

  # SQL Server and Database Audit policies 
  # By default database servers extended auditing policy enabled. you can turn of using  enable_sql_server_extended_auditing_policy 
  # By default database extended auditing policy is turned off. you can manage the setting by adding `enable_database_extended_auditing_policy` 
  # To manage Azure Defender for Azure SQL database servers set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # schedule scan notifications to the subscription administrators
  # Manages the Vulnerability Assessment for a MS SQL Server set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = true
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

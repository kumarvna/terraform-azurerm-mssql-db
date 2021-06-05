module "mssql-server" {
  //source                          = "kumarvna/mssql-db/azurerm"
  //version                         = "1.0.0"
  source = "github.com/kumarvna/terraform-azurerm-mssql-db?ref=develop"
  //source = "../../"

  # By default, this module will create a resource group, proivde the name here
  # to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG.
  create_resource_group         = false
  resource_group_name           = "rg-shared-westeurope-01"
  location                      = "westeurope"
  virtual_network_name          = "vnet-shared-hub-westeurope-001"
  private_subnet_address_prefix = ["10.1.5.0/29"]

  # SQL Server and Database scaling options
  sqlserver_name               = "sqldbserver-db01"
  database_name                = "demomssqldb"
  sql_database_edition         = "Standard"
  sqldb_service_objective_name = "S1"

  # SQL Server and Database Audit policies  
  enable_extended_auditing_policy = true
  enable_threat_detection_policy  = true
  log_retention_days              = 30
  sql_admin_email_addresses       = ["user@example.com"]

  # AD administrator for an Azure SQL server
  enable_sql_ad_admin = true
  ad_admin_login_name = "firstname.lastname@example.com"

  enable_vulnerability_assessment = false

  # Firewall Rules to allow azure and external clients
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
  }]

  # Create and initialize a database with SQL script
  initialize_sql_script_execution = true
  sqldb_init_script_file          = "../artifacts/db-init-sample.sql"

  # Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}

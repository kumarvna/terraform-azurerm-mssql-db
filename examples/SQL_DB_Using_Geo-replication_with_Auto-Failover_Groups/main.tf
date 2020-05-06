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
                start_ip_address  = "123.201.42.91"
                end_ip_address    = "123.201.42.91"}]

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
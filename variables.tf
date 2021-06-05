variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = true
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "rg-demo-westeurope-01"
}

variable "storage_account_name" {
  description = "The name of the storage account name"
  default     = null
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "westeurope"
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "enable_extended_auditing_policy" {
  description = "Audit policy for SQL server and database"
  default     = false
}

variable "enable_threat_detection_policy" {
  description = ""
  default     = false
}

variable "sqlserver_name" {
  description = "SQL server Name"
  default     = "sqldbserver-demodbapp"
}

variable "database_name" {
  description = "The name of the database"
  default     = ""
}

variable "sql_database_edition" {
  description = "The edition of the database to be created"
  default     = "Standard"
}

variable "sqldb_service_objective_name" {
  description = " The service objective name for the database"
  default     = "S1"
}

variable "log_retention_days" {
  description = "Specifies the number of days to keep in the Threat Detection audit logs"
  default     = "30"
}

variable "threat_detection_audit_logs_retention_days" {
  description = "Specifies the number of days to keep in the Threat Detection audit logs."
  default     = 0
}

variable "enable_vulnerability_assessment" {
  description = "Manages the Vulnerability Assessment for a MS SQL Server"
  default     = false
}

variable "sql_admin_email_addresses" {
  description = "A list of email addresses which alerts should be sent to."
  type        = list(any)
  default     = []
}

variable "disabled_alerts" {
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  type        = list(any)
  default     = []
}

variable "enable_sql_ad_admin" {
  description = "Allows you to set a user or group as the AD administrator for an Azure SQL server"
  default     = false
}

variable "ad_admin_login_name" {
  description = "The login name of the principal to set as the server administrator"
  default     = ""
}

variable "identity" {
  description = "If you want your SQL Server to have an managed identity. Defaults to false."
  default     = false
}

variable "enable_firewall_rules" {
  description = "Manage an Azure SQL Firewall Rule"
  default     = false
}

variable "enable_failover_group" {
  description = "Create a failover group of databases on a collection of Azure SQL servers"
  default     = false
}

variable "secondary_sql_server_location" {
  description = "Specifies the supported Azure location to create secondary sql server resource"
  default     = "northeurope"
}

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to SQL database"
  default     = false
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
}

variable "private_subnet_address_prefix" {
  description = "The name of the subnet for private endpoints"
  default     = null
}

variable "firewall_rules" {
  description = "Range of IP addresses to allow firewall connections."
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}

variable "initialize_sql_script_execution" {
  description = "Allow/deny to Create and initialize a Microsoft SQL Server database"
  default     = false
}

variable "sqldb_init_script_file" {
  description = "SQL Script file name to create and initialize the database"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

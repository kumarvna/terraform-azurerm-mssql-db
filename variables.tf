variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "storage_account_name" {
  description = "The name of the storage account name"
  default     = null
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 32
}

variable "enable_sql_server_extended_auditing_policy" {
  description = "Manages Extended Audit policy for SQL servers"
  default     = true
}

variable "enable_database_extended_auditing_policy" {
  description = "Manages Extended Audit policy for SQL database"
  default     = false
}

variable "enable_threat_detection_policy" {
  description = ""
  default     = false
}

variable "sqlserver_name" {
  description = "SQL server Name"
  default     = ""
}

variable "admin_username" {
  description = "The administrator login name for the new SQL Server"
  default     = null
}

variable "admin_password" {
  description = "The password associated with the admin_username user"
  default     = null
}

variable "database_name" {
  description = "The name of the database; DEPRECATED - use 'databases'"
  default     = ""
}

variable "sql_database_edition" {
  description = "The edition of the database to be created; DEPRECATED - use 'databases'"
  default     = "Standard"
}

variable "sqldb_service_objective_name" {
  description = " The service objective name for the database; DEPRECATED - use 'databases'"
  default     = "S1"
}

variable "databases" {
  description = "The list of databases to create"
  type = list(object({
    name                   = string
    edition                = string
    service_objective_name = string
    sqldb_init_script_file = string
  }))
  default = []
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

variable "email_addresses_for_alerts" {
  description = "A list of email addresses which alerts should be sent to."
  type        = list(any)
  default     = []
}

variable "disabled_alerts" {
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  type        = list(any)
  default     = []
}

variable "ad_admin_login_name" {
  description = "The login name of the principal to set as the server administrator"
  default     = null
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
  default     = ""
}

variable "private_subnet_address_prefix" {
  description = "The name of the subnet for private endpoints"
  default     = null
}

variable "existing_vnet_id" {
  description = "The resoruce id of existing Virtual network"
  default     = null
}

variable "existing_subnet_id" {
  description = "The resource id of existing subnet"
  default     = null
}

variable "existing_private_dns_zone" {
  description = "Name of the existing private DNS zone"
  default     = null
}

variable "create_private_dns_zone" {
  description = "Whether or not to create a private DNS zone if existing_private_dns_zone is set to null, e.g. if there is already a DNS zone creatted in a shared subscription and the DNS record is deployed by policy"
  type        = bool
  default     = true
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

variable "enable_log_monitoring" {
  description = "Enable audit events to Azure Monitor?"
  default     = false
}

variable "initialize_sql_script_execution" {
  description = "Allow/deny to Create and initialize a Microsoft SQL Server database"
  default     = false
}

variable "sqldb_init_script_file" {
  description = "SQL Script file name to create and initialize the database"
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Specifies the ID of a Log Analytics Workspace where Diagnostics Data to be sent"
  default     = null
}

variable "storage_account_id" {
  description = "The name of the storage account to store the all monitoring logs"
  default     = null
}

variable "extaudit_diag_logs" {
  description = "Database Monitoring Category details for Azure Diagnostic setting"
  default     = ["SQLSecurityAuditEvents", "SQLInsights", "AutomaticTuning", "QueryStoreRuntimeStatistics", "QueryStoreWaitStatistics", "Errors", "DatabaseWaitStatistics", "Timeouts", "Blocks", "Deadlocks"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "public_network_access_enabled" {
  description = "Whether or not the database should be accessible from the internet"
  type        = bool
  default     = true
}
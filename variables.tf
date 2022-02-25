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

variable "connection_policy" {
  description = "The connection policy the server will use. Possible values are `Default`, `Proxy`, and `Redirect`"
  default     = "Default"
}

variable "minimum_tls_version" {
  description = "The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases associated with the server. Valid values are: `1.0`, `1.1` and `1.2`."
  default     = null
}

variable "enable_public_network_access" {
  description = "Whether public network access is allowed for this server."
  default     = true
}

variable "enable_outbound_network_restriction" {
  description = "Whether outbound network traffic is restricted for this server."
  default     = false
}

variable "primary_user_assigned_identity_id" {
  description = "Specifies the primary user managed identity id. Required if using Identiy block with `UserAssigned` type and should be combined with `user_assigned_identity_ids`."
  default     = null
}

variable "managed_identity_type" {
  description = "Specifies the identity type of the Microsoft SQL Server. Possible values are `SystemAssigned` (where Azure will generate a Service Principal for you) and `UserAssigned` where you can specify the Service Principal IDs in the `user_assigned_identity_ids` field."
  default     = null
}

variable "managed_identity_ids" {
  description = "Specifies a list of User Assigned Identity IDs to be assigned. Required if type is `UserAssigned` and should be combined with `primary_user_assigned_identity_id`."
  default     = null
}

variable "ad_admin_login_name" {
  description = "The login name of the principal to set as the server administrator"
  default     = null
}

variable "ad_admin_object_id" {
  description = "The object id of the Azure AD Administrator of this SQL Server."
  default     = null
}

variable "ad_admin_tenant_id" {
  description = "The tenant id of the Azure AD Administrator of this SQL Server."
  default     = null
}

variable "azuread_authentication_only" {
  description = "Specifies whether only AD Users and administrators (like azuread_administrator.0.login_username) can be used to login or also local database users (like administrator_login)."
  default     = false
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

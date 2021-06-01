locals {
  resource_group_name                 = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location                            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  if_threat_detection_policy_enabled  = var.enable_threat_detection_policy ? [{}] : []
  if_extended_auditing_policy_enabled = var.enable_auditing_policy ? [{}] : []
}

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

#---------------------------------------------------------
# Storage Account to keep Audit logs - Default is "false"
#----------------------------------------------------------

resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_threat_detection_policy || var.enable_auditing_policy ? 1 : 0
  name                      = "stsqlauditlogs"
  resource_group_name       = local.resource_group_name
  location                  = local.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = merge({ "Name" = format("%s", "stsqlauditlogs") }, var.tags, )
}

#-------------------------------------------------------------
# SQL servers - Secondary server is depends_on Failover Group
#-------------------------------------------------------------

resource "random_password" "main" {
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    administrator_login_password = var.sqlserver_name
  }
}

resource "azurerm_sql_server" "primary" {
  name                         = format("%s-primary", var.sqlserver_name)
  resource_group_name          = local.resource_group_name
  location                     = local.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.main.result
  tags                         = merge({ "Name" = format("%s-primary", var.sqlserver_name) }, var.tags, )

  dynamic "extended_auditing_policy" {
    for_each = local.if_extended_auditing_policy_enabled
    content {
      storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
      storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
      retention_in_days          = var.log_retention_days
    }
  }
}

resource "azurerm_sql_server" "secondary" {
  count                        = var.enable_failover_group ? 1 : 0
  name                         = format("%s-secondary", var.sqlserver_name)
  resource_group_name          = local.resource_group_name
  location                     = var.secondary_sql_server_location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.main.result
  tags                         = merge({ "Name" = format("%s-secondary", var.sqlserver_name) }, var.tags, )

  dynamic "extended_auditing_policy" {
    for_each = local.if_extended_auditing_policy_enabled
    content {
      storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
      storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
      retention_in_days          = var.log_retention_days
    }
  }
}

#--------------------------------------------------------------------
# SQL Database creation - Default edition:"Standard" and objective:"S1"
#--------------------------------------------------------------------

resource "azurerm_sql_database" "db" {
  name                             = var.database_name
  resource_group_name              = local.resource_group_name
  location                         = local.location
  server_name                      = azurerm_sql_server.primary.name
  edition                          = var.sql_database_edition
  requested_service_objective_name = var.sqldb_service_objective_name
  tags                             = merge({ "Name" = format("%s-primary", var.database_name) }, var.tags, )

  dynamic "threat_detection_policy" {
    for_each = local.if_threat_detection_policy_enabled
    content {
      state                      = "Enabled"
      storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
      storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
      retention_days             = var.log_retention_days
      email_addresses            = var.email_addresses_for_alerts
    }
  }

  dynamic "extended_auditing_policy" {
    for_each = local.if_extended_auditing_policy_enabled
    content {
      storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
      storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
      retention_in_days          = var.log_retention_days
    }
  }
}

#-----------------------------------------------------------------------------------------------
# Create and initialize a Microsoft SQL Server database using sqlcmd utility - Default is "false"
#-----------------------------------------------------------------------------------------------

resource "null_resource" "create_sql" {
  count = var.initialize_sql_script_execution ? 1 : 0
  provisioner "local-exec" {
    command = "sqlcmd -I -U ${azurerm_sql_server.primary.administrator_login} -P ${azurerm_sql_server.primary.administrator_login_password} -S ${azurerm_sql_server.primary.fully_qualified_domain_name} -d ${azurerm_sql_database.db.name} -i ${var.sqldb_init_script_file} -o ${format("%s.log", replace(var.sqldb_init_script_file, "/.sql/", ""))}"
  }
}

#-----------------------------------------------------------------------------------------------
# Adding AD Admin to SQL Server - Secondary server depend on Failover Group - Default is "false"
#-----------------------------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_sql_active_directory_administrator" "aduser1" {
  count               = var.enable_sql_ad_admin ? 1 : 0
  server_name         = azurerm_sql_server.primary.name
  resource_group_name = local.resource_group_name
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

resource "azurerm_sql_active_directory_administrator" "aduser2" {
  count               = var.enable_failover_group && var.enable_sql_ad_admin ? 1 : 0
  server_name         = azurerm_sql_server.secondary.0.name
  resource_group_name = local.resource_group_name
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

#---------------------------------------------------------
# Azure SQL Firewall Rule - Default is "false"
#---------------------------------------------------------

resource "azurerm_sql_firewall_rule" "fw01" {
  count               = var.enable_firewall_rules && length(var.firewall_rules) > 0 ? length(var.firewall_rules) : 0
  name                = element(var.firewall_rules, count.index).name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_sql_server.primary.name
  start_ip_address    = element(var.firewall_rules, count.index).start_ip_address
  end_ip_address      = element(var.firewall_rules, count.index).end_ip_address
}

resource "azurerm_sql_firewall_rule" "fw02" {
  count               = var.enable_failover_group && var.enable_firewall_rules && length(var.firewall_rules) > 0 ? length(var.firewall_rules) : 0
  name                = element(var.firewall_rules, count.index).name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_sql_server.secondary.0.name
  start_ip_address    = element(var.firewall_rules, count.index).start_ip_address
  end_ip_address      = element(var.firewall_rules, count.index).end_ip_address
}

#---------------------------------------------------------
# Azure SQL Failover Group - Default is "false" 
#---------------------------------------------------------

resource "azurerm_sql_failover_group" "fog" {
  count               = var.enable_failover_group ? 1 : 0
  name                = "sqldb-failover-group"
  resource_group_name = local.resource_group_name
  server_name         = azurerm_sql_server.primary.name
  databases           = [azurerm_sql_database.db.id]
  tags                = merge({ "Name" = format("%s", "sqldb-failover-group") }, var.tags, )

  partner_servers {
    id = azurerm_sql_server.secondary.0.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  readonly_endpoint_failover_policy {
    mode = "Enabled"
  }
}

#---------------------------------------------------------
# Private Link for SQL Server - Default is "false" 
#---------------------------------------------------------

data "azurerm_virtual_network" "vnet01" {
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "snet-ep" {
  count                                          = var.enable_private_endpoint ? 1 : 0
  name                                           = "snet-endpoint-shared-${local.location}"
  resource_group_name                            = local.resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = var.private_subnet_address_prefix
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-primary", "sqldb-private-endpoint")
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.snet-ep.0.id
  tags                = merge({ "Name" = format("%s", "sqldb-private-endpoint") }, var.tags, )

  private_service_connection {
    name                           = "sqldbprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.primary.id
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_endpoint" "pep2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = format("%s-secondary", "sqldb-private-endpoint")
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.snet-ep.0.id
  tags                = merge({ "Name" = format("%s", "sqldb-private-endpoint") }, var.tags, )

  private_service_connection {
    name                           = "sqldbprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.secondary.0.id
    subresource_names              = ["sqlServer"]
  }
}

#------------------------------------------------------------------
# DNS zone & records for SQL Private endpoints - Default is "false" 
#------------------------------------------------------------------

data "azurerm_private_endpoint_connection" "private-ip1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep1.0.name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_sql_server.primary]
}

data "azurerm_private_endpoint_connection" "private-ip2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep2.0.name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_sql_server.secondary]
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.database.windows.net"
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "SQL-Private-DNS-Zone") }, var.tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link1" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone1.0.name
  virtual_network_id    = data.azurerm_virtual_network.vnet01.id
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.tags, )
}

resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_sql_server.primary.name
  zone_name           = azurerm_private_dns_zone.dnszone1.0.name
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1.0.private_service_connection.0.private_ip_address]
}

resource "azurerm_private_dns_a_record" "arecord2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = azurerm_sql_server.secondary.0.name
  zone_name           = azurerm_private_dns_zone.dnszone1.0.name
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip2.0.private_service_connection.0.private_ip_address]

}

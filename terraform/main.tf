terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115.0"
    }
  }

  required_version = ">= 1.7.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# ====================================================
# 1️⃣ Resource Group
# ====================================================
resource "azurerm_resource_group" "rg" {
  name     = "saja-rg-1"
  location = "Central India"
}

# ====================================================
# 2️⃣ Virtual Network + Subnets
# ====================================================
resource "azurerm_virtual_network" "vnet" {
  name                = "saja-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Database Subnet
resource "azurerm_subnet" "db_subnet" {
  name                 = "database-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "postgres-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [azurerm_virtual_network.vnet]
}

# Container Apps Subnet
resource "azurerm_subnet" "apps_subnet" {
  name                 = "apps-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/23"]

  depends_on = [azurerm_virtual_network.vnet]
}





# ====================================================
# 3️⃣ Private DNS Zone + Link
# ====================================================
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_link" {
  name                  = "dnslink-to-vnet"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# ====================================================
# 4️⃣ PostgreSQL Flexible Server + DB
# ====================================================
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "saja-postgres-db"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "pgadmin"
  administrator_password = var.db_password
  version                = "16"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"

  authentication {
    password_auth_enabled = true
  }

  delegated_subnet_id           = azurerm_subnet.db_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "appdb" {
  name      = "burgerbuilder"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

# ====================================================
# 5️⃣ Azure Container Registry (ACR)
# ====================================================
resource "azurerm_container_registry" "acr" {
  name                = "sajaregistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# ====================================================
# 6️⃣ Azure Container Apps Environment
# ====================================================
resource "azurerm_container_app_environment" "env" {
  name                = "saja-aca-env"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  infrastructure_subnet_id        = azurerm_subnet.apps_subnet.id
  internal_load_balancer_enabled  = true
  # set to true and configure private DNS zone with wildcard (*.container_apps_environment_fqdn) point to container apps env private IPv4

  depends_on = [
    azurerm_subnet.apps_subnet,
    azurerm_private_dns_zone_virtual_network_link.postgres_link
  ]
}

# ====================================================
# Private DNS Zone for Container Apps Environment
# ====================================================
resource "azurerm_private_dns_zone" "containerapps_zone" {
  name                = azurerm_container_app_environment.env.default_domain
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "containerapps_link" {
  name                  = "containerapps-dnslink"
  private_dns_zone_name = azurerm_private_dns_zone.containerapps_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}
# Wildcard record to route all container apps to the private environment IP
resource "azurerm_private_dns_a_record" "containerapps_wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.containerapps_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
}



# ====================================================
# 7️⃣ Backend Container App
# ====================================================
resource "azurerm_container_app" "backend" {
  name                         = "backend-app"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  ingress {
    external_enabled = true
    target_port      = 8080
    allow_insecure_connections = true

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
    

  template {
    container {
      name   = "backend"
      image  = "sajaregistry.azurecr.io/backend:latest"
      cpu    = 0.5
      memory = "1.0Gi"

      env {
        name  = "DB_HOST"
        value = "saja-postgres-db.postgres.database.azure.com"
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_NAME"
        value = "burgerbuilder"
      }

      env {
        name  = "DB_USERNAME"
        value = "pgadmin"
      }

      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }

      env {
        name  = "DB_DRIVER"
        value = "org.postgresql.Driver"
      }

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "default"
      }

      env {
        name  = "SERVER_PORT"
        value = "8080"
      }
    }
    min_replicas = 1  
    max_replicas = 5 
  }

  secret {
    name  = "acr-password"
    value = var.acr_password
  }

  registry {
    server               = "sajaregistry.azurecr.io"
    username             = "sajaregistry"
    password_secret_name = "acr-password"
  }

  depends_on = [
    azurerm_container_app_environment.env,
    azurerm_postgresql_flexible_server.db
  ]

  
    
  
}

# ====================================================
# 8️⃣ Frontend Container App
# ====================================================
resource "azurerm_container_app" "frontend" {
  name                         = "frontend-app"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  ingress {
    external_enabled           = true
    target_port                = 80
    allow_insecure_connections = true

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "frontend"
      image  = "sajaregistry.azurecr.io/frontend:3.0.0"
      cpu    = 0.5
      memory = "1.0Gi"

      env {
        name  = "VITE_API_BASE_URL"
        value = "http://74.225.172.165" # Value should be App Gateway Public IP
        # APP GW backend backend settings - change port from 8080
        # APP GW Add health probes as they are seted now
      }
    }
    min_replicas = 1
    max_replicas = 5
  }

  secret {
    name  = "acr-password"
    value = var.acr_password
  }

  registry {
    server               = "sajaregistry.azurecr.io"
    username             = "sajaregistry"
    password_secret_name = "acr-password"
  }

  depends_on = [azurerm_container_app_environment.env]
}


# ====================================================
#  Subnet for Application Gateway
# ====================================================

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgateway-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

# ====================================================
# Public IP for Application Gateway
# ====================================================
resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "saja-appgw-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


# ====================================================
# Application Gateway
# ====================================================
resource "azurerm_application_gateway" "appgw" {
  name                = "saja-appgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendPublicIP"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  # ================================
  # FRONTEND
  # ================================
  backend_address_pool {
    name  = "frontend-pool"
    fqdns = ["frontend-app.${azurerm_container_app_environment.env.default_domain}"]
  }#fqdns = ["frontend-app.{azurerm_container_app.env.default.fqdn}"]
  # terraform destroy --target=application gateway
  backend_http_settings {
    name                            = "frontend-http"
    port                            = 80
    protocol                        = "Http"
    request_timeout                 = 30
    pick_host_name_from_backend_address = true
    cookie_based_affinity            = "Disabled"
    probe_name                      = "frontend-health-probe"

  }

  # ================================
  # BACKEND
  # ================================
  probe {
    name                = "backend-health-probe"
    protocol            = "Http"
    port                = 80
    path                = "/actuator/health"
    #host                = "backend-app.icydesert-966b86df.centralindia.azurecontainerapps.io"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 5
    pick_host_name_from_backend_http_settings = true
  match {
  status_code = ["200-399"]
}

  }
  probe {
  name                = "frontend-health-probe"
  protocol            = "Http"
  port                = 80
  path                = "/"
  #host                = "frontend-app.icydesert-966b86df.centralindia.azurecontainerapps.io"
  interval            = 30
  timeout             = 10
  unhealthy_threshold = 5
  pick_host_name_from_backend_http_settings = true
  match {
    status_code = ["200-399"]
  }
}


  backend_address_pool {
    name  = "backend-pool"
    fqdns = ["backend-app.${azurerm_container_app_environment.env.default_domain}"]
  }

  backend_http_settings {
    name                            = "backend-http"
    port                            = 80
    protocol                        = "Http"
    request_timeout                 = 60
    pick_host_name_from_backend_address = true
    cookie_based_affinity            = "Disabled"
    probe_name                      = "backend-health-probe"
  }

  # ================================
  # LISTENERS & ROUTING
  # ================================
  http_listener {
    name                           = "appgw-listener"
    frontend_ip_configuration_name = "frontendPublicIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                        = "routing-rule"
    rule_type                   = "PathBasedRouting"
    http_listener_name           = "appgw-listener"
    priority                     = 100
    url_path_map_name             = "urlmap"
  }

  url_path_map {
    name                               = "urlmap"
    default_backend_address_pool_name  = "frontend-pool"
    default_backend_http_settings_name = "frontend-http"

    path_rule {
      name                       = "api-path"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "backend-http"
    }
  }
}

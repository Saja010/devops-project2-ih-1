# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
}


# Subnet - Container Apps Env
resource "azurerm_subnet" "snet_aca" {
  name                 = "snet-aca"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/23"]
}

# Subnet - PostgreSQL
resource "azurerm_subnet" "db" {
  name                 = "saja-db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/28"]

  delegation {
    name = "dbdelegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "sajaregistry123"   
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------
# Subnet for AppGW
# ---------------------------
resource "azurerm_subnet" "subnet_appgw" {
  name                 = "saja-appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.6.0/24"]
}

# ---------------------------
# Public IP for AppGW
# ---------------------------
resource "azurerm_public_ip" "appgw" {
  name                = "saja-appgw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ---------------------------
# Application Gateway
# ---------------------------
resource "azurerm_application_gateway" "appgw" {
  name                = "saja-burger-builder-appgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  backend_address_pool {
    name  = "frontend-backend-pool"
    fqdns = ["frontend-app.internal.calmforest-0d6fd79f.centralindia.azurecontainerapps.io"]
  }

  backend_address_pool {
    name  = "backend-backend-pool"
    fqdns = ["backend-app.internal.calmforest-0d6fd79f.centralindia.azurecontainerapps.io"]
  }

  probe {
    name                = "frontend-health-probe"
    protocol            = "Http"
    path                = "/"  # يفحص الصفحة الرئيسية
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                = "backend-health-probe"
    protocol            = "Http"
    path                = "/api/health"  # endpoint الخاص بالباك اند
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                                = "frontend-http-settings"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
    probe_name                          = "frontend-health-probe"
  }

  backend_http_settings {
    name                                = "backend-http-settings"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
    probe_name                          = "backend-health-probe"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "path-based-routing"
    default_backend_address_pool_name  = "frontend-backend-pool"
    default_backend_http_settings_name = "frontend-http-settings"

    path_rule {
      name                       = "api-routing"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-backend-pool"
      backend_http_settings_name = "backend-http-settings"
    }

    path_rule {
      name                       = "actuator-routing"
      paths                      = ["/actuator/*"]
      backend_address_pool_name  = "backend-backend-pool"
      backend_http_settings_name = "backend-http-settings"
    }
  }

  request_routing_rule {
    name               = "path-based-routing-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "http-listener"
    url_path_map_name  = "path-based-routing"
    priority           = 100
  }

  enable_http2 = false
}

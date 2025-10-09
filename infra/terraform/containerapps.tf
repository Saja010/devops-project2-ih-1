# Container App Environment(for backend and frontend)
resource "azurerm_container_app_environment" "aca_env" {
  name                = "saja-aca-env"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  infrastructure_subnet_id = azurerm_subnet.snet_aca.id
}

# Container App (Frontend)
resource "azurerm_container_app" "frontend" {
  name                         = "frontend-app"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend"
      image  = "${azurerm_container_registry.acr.login_server}/frontend:v4"
      cpu    = 0.5
      memory = "1Gi"
    }

  min_replicas = 1
  max_replicas = 3
}

  ingress {
    external_enabled = false
    target_port      = 80
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }
  
}


# Container App (Backend)
resource "azurerm_container_app" "backend" {
  name                         = "backend-app"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  revision_mode                = "Single"

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  template {
    container {
      name   = "backend"
      image  = "${azurerm_container_registry.acr.login_server}/backend:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "docker"
      }
      env {
        name  = "DB_HOST"
        value = azurerm_postgresql_flexible_server.db.fqdn
      }
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_NAME"
        value = "appdb"
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
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = false
    transport        = "auto"
    target_port      = 8080
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}


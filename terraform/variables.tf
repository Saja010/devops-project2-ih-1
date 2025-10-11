variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "db_password" {
  description = "Database password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "acr_password" {
  description = "Azure Container Registry password"
  type        = string
  sensitive   = true
}

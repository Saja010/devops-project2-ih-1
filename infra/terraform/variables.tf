variable "subscription_id" {
  description = "The Subscription ID in which to create the resources."
  type        = string
  
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string
  
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  
}

variable "db_password" {
  description = "Postgres admin password"
  sensitive   = true
}

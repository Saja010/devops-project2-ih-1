variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the subnet will be created"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name where the subnet belongs"
  type        = string
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
}


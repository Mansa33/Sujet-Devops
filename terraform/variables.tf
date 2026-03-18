variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "mygroupe"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "switzerlandnorth"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "myVM"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

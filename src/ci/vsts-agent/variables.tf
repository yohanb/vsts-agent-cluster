variable "subscription_id" {
  description = "The Azure subscription id"
}

variable "tenant_id" {
  description = "The Azure AD tenant id"
}

variable "client_secret" {
  description = "The Azure AD application client secret"
}

variable "client_id" {
  description = "The Azure AD application client id"
}

variable "vm_resource_group" {
  description = "gravt-ci-agents"
}

variable "image_name" {
  description = "The name of the existing Image"
}

variable "image_resource_group" {
  description = "The name of the Resource Group where the Image is located."
}

variable "vm_name" {
  description = "Virtual machine name."
}

variable "location" {
  description = "The location where the Resources will be provisioned. This needs to be the same as where the Image exists."
}

variable "admin_username" {
  description = "The username associated with the local administrator account on the Virtual Machine"
}

variable "vsts_account_name" {
  description = "The VSTS account name"
}

variable "vsts_pat" {
  description = "The VSTS personal access token"
}
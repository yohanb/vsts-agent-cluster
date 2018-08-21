variable "subscription_id" {
  description = "The Azure subscription id"
}

variable "location" {
  description = "The location where the resources will be provisioned. This needs to be the same as where the image exists."
}

variable "vm_resource_group" {
  description = "Name of the resource group in which to create the agents VMs."
}

variable "image_name" {
  description = "The name of the image to use for the VM."
}

variable "image_resource_group" {
  description = "The name of the resource group where the image is located."
}

variable "vm_name" {
  description = "Virtual machine name. (a dash with the number of the VM will be appended to the name.  ex: agent-0, agent-1, etc.)"
}

variable "vm_admin" {
  description = "The username associated with the local administrator account on the VM (defaults to admin)."
  default = "admin"
}

variable "vsts_account_name" {
  description = "The VSTS account name."
}

variable "vsts_pat" {
  description = "The VSTS personal access token."
}

variable "vsts_agent_install_folder" {
  description = "The folder in which the agent was install (defaults to '/a1')."
  default = "/a1"
}

variable "vsts_agent_pool" {
  description = "The VSTS agent pool name (defaults to 'default')."
  default = "default"
}
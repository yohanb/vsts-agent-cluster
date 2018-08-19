provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

# Locate the existing custom/golden image
data "azurerm_image" "search" {
  name                = "${var.image_name}"
  resource_group_name = "${var.image_resource_group}"
}

output "image_id" {
  value = "${data.azurerm_image.search.id}"
}

# Create a Resource Group for the new Virtual Machine.
resource "azurerm_resource_group" "main" {
  name     = "${var.vm_resource_group}"
  location = "canadaeast"
}

# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name                = "${var.vm_name}-network"
  address_space       = ["172.16.0.0/16"]
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "172.16.1.0/24"
}

# Create a Public IP for the Virtual Machine
resource "azurerm_public_ip" "main" {
  name                         = "${var.vm_name}-pip"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  public_ip_address_allocation = "dynamic"
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${var.vm_name}-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "main" {
  name                      = "${var.vm_name}-nic"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

# Create a new Virtual Machine based on the Golden Image
resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.vm_name}"
  location                         = "${azurerm_resource_group.main.location}"
  resource_group_name              = "${azurerm_resource_group.main.name}"
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "Standard_F2s_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "40"
  }

  storage_data_disk {
    name              = "${var.vm_name}-data1"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1024"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data  = "${file("~/.ssh/id_rsa.pub")}"
      path      = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }
}

data "template_file" "agent_command" {
  template = "$${cd} && $${config} && $${install_svc} && $${start_svc}"
  vars {
    cd = "cd /a1"
    config = "./bin/Agent.Listener configure --unattended --url https://${var.vsts_account_name}.visualstudio.com --auth pat --token ${var.vsts_pat} --pool default --agent ${var.vm_name} --acceptTeeEula"
    install_svc = "./svc.sh install"
    start_svc = "./svc.sh start"
  }
}

resource "azurerm_virtual_machine_extension" "agent_script" {
  name                 = "agent_script"
  location             = "${azurerm_resource_group.main.location}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.vm.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "${data.template_file.agent_command.rendered}"
    }
  SETTINGS
}
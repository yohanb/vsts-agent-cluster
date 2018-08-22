provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

data "azurerm_image" "search" {
  name                = "${var.image_name}"
  resource_group_name = "${var.image_resource_group}"
}

output "image_id" {
  value = "${data.azurerm_image.search.id}"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.vm_resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.vm_name}-network"
  address_space       = ["172.16.0.0/16"]
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "172.16.1.0/24"
}

resource "azurerm_public_ip" "main" {
  name                         = "${var.vm_name}-pip--${count.index}"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  public_ip_address_allocation = "dynamic"
  count                        = "${var.vm_instance_count}"
}

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

resource "azurerm_network_interface" "main" {
  name                      = "${var.vm_name}-nic-${count.index}"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  count                     = "${var.vm_instance_count}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.main.*.id, count.index)}"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.vm_name}-${count.index}"
  location                         = "${azurerm_resource_group.main.location}"
  resource_group_name              = "${azurerm_resource_group.main.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  vm_size                          = "${var.vm_size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  count                            = "${var.vm_instance_count}"

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "${var.vm_name}-${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "40"
  }

  storage_data_disk {
    name              = "${var.vm_name}-${count.index}-data"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1024"
  }

  os_profile {
    computer_name  = "${var.vm_name}-${count.index}"
    admin_username = "${var.vm_admin}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data  = "${file("~/.ssh/id_rsa.pub")}"
      path      = "/home/${var.vm_admin}/.ssh/authorized_keys"
    }
  }
}

data "template_file" "agent_command" {
  template = "$${chdir} && $${config} && $${install_svc} && $${start_svc}"
  vars {
    chdir = "cd ${var.vsts_agent_install_folder}"
    config = "sudo ./bin/Agent.Listener configure --unattended --url https://${var.vsts_account_name}.visualstudio.com --auth pat --token ${var.vsts_pat} --pool ${var.vsts_agent_pool} --agent $(hostname) --acceptTeeEula"
    install_svc = "sudo ./svc.sh install"
    start_svc = "sudo ./svc.sh start"
  }
}

resource "azurerm_virtual_machine_extension" "agent_script" {
  name                 = "agent_script"
  location             = "${azurerm_resource_group.main.location}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${element(azurerm_virtual_machine.vm.*.name, count.index)}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  count                = "${var.vm_instance_count}"

  settings = <<SETTINGS
    {
        "commandToExecute": "${data.template_file.agent_command.rendered}"
    }
  SETTINGS
}
# provider "azurerm" {
#   # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
#   version = "=2.20.0"
#   features {}
# }

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.44.0"

  subscription_id = "535a22bc-653b-4d3e-bb2c-281f000a4a06"
  tenant_id       = "80a3bc8a-6d35-41fc-88a3-fbefdb06743f"
}
##variables
variable "prefix" {
  default = "ankita-poc"
}

variable "location" {
    default = "Central US"
}

variable "resource_group_name" {
    default = "ABInBev_PoC"
}

variable "vm_size" {
    default = "Standard_DS1_v2"
}

##NIC
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.1.0.0/16"]
  location            = "Central US"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "default"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.1.0.0/24"
}

resource "azurerm_network_interface" "vm_interface" {
  name                = "${var.prefix}-nic"
  location            = "Central US"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.prefix}-testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

####################################################VIRTUAL MACHINE
resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  location              = "Central US"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.vm_interface.id}"]
  vm_size               = "${var.vm_size}"

 storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

 storage_os_disk {
    name              = "${var.prefix}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "dev"
  }
}
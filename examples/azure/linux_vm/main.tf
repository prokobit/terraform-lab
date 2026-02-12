resource "azurerm_resource_group" "tfpk" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "tfpk" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tfpk.location
  resource_group_name = azurerm_resource_group.tfpk.name
}

resource "azurerm_subnet" "tfpk" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.tfpk.name
  virtual_network_name = azurerm_virtual_network.tfpk.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "tfpk" {
  name                    = "${var.prefix}-pip"
  location                = azurerm_resource_group.tfpk.location
  resource_group_name     = azurerm_resource_group.tfpk.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "tfpk"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.tfpk.location
  resource_group_name = azurerm_resource_group.tfpk.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tfpk.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfpk.id
  }
}

resource "azurerm_linux_virtual_machine" "tfpk" {
  name                = "${var.prefix}-linux-vm"
  resource_group_name = azurerm_resource_group.tfpk.name
  location            = azurerm_resource_group.tfpk.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "data" {
  name                 = "${var.prefix}-data"
  location             = azurerm_resource_group.tfpk.location
  create_option        = "Empty"
  disk_size_gb         = 10
  resource_group_name  = azurerm_resource_group.tfpk.name
  storage_account_type = "Standard_LRS"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  virtual_machine_id = azurerm_linux_virtual_machine.tfpk.id
  managed_disk_id    = azurerm_managed_disk.data.id
  lun                = 0
  caching            = "None"
}

resource "azurerm_network_security_group" "tfpk" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.tfpk.location
  resource_group_name = azurerm_resource_group.tfpk.name
  security_rule {
    name                       = "AllowTLS"
    access                     = "Allow"
    direction                  = "Inbound"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowSSH"
    access                     = "Allow"
    direction                  = "Inbound"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "tfpk"
  }
}

resource "azurerm_network_interface_security_group_association" "tfpk" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.tfpk.id
}

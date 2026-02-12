resource "azurerm_resource_group" "tfpk" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "tfpk" {
  name                     = "${var.prefix}stor"
  resource_group_name      = azurerm_resource_group.tfpk.name
  location                 = azurerm_resource_group.tfpk.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "tfpk" {
  name                 = "html-share"
  storage_account_name = azurerm_storage_account.tfpk.name
  quota                = 1
}

resource "azurerm_storage_share_file" "index" {
  name             = "index.html"
  storage_share_id = azurerm_storage_share.tfpk.id
  source           = "index.html"
}

resource "azurerm_container_group" "tfpk" {
  name                = "${var.prefix}-continst"
  location            = azurerm_resource_group.tfpk.location
  resource_group_name = azurerm_resource_group.tfpk.name
  ip_address_type     = "Public"
  dns_name_label      = "${var.prefix}-continst"
  os_type             = "Linux"

  container {
    name   = "webserver"
    image  = "nginx"
    cpu    = "1"
    memory = "0.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    volume {
      name       = "content"
      mount_path = "/usr/share/nginx/html"
      read_only  = true
      share_name = azurerm_storage_share.tfpk.name

      storage_account_name = azurerm_storage_account.tfpk.name
      storage_account_key  = azurerm_storage_account.tfpk.primary_access_key
    }
  }

  tags = {
    environment = "dev"
  }
}
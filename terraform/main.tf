# ============================================================
# Configuration du provider Terraform pour Azure
# Utilise le provider azurerm version 4.x
# ============================================================
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Authentification Azure via les variables (subscription_id)
# resource_provider_registrations = "none" evite les erreurs de permissions
provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

# ============================================================
# Groupe de ressources — conteneur logique de toutes les ressources
# ============================================================
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ============================================================
# Reseau virtuel (VNET) — isolation reseau de la VM
# Plage d'adresses : 10.1.0.0/16
# ============================================================
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Sous-reseau par defaut dans le VNET
# Plage : 10.1.0.0/24 (256 adresses disponibles)
resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

# ============================================================
# Network Security Group — pare-feu avec regles de trafic entrant
# Chaque regle definit un port autorise depuis Internet
# ============================================================
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Acces SSH pour l'administration de la VM
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Acces HTTP pour l'application web Nginx
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Acces Grafana pour les dashboards de monitoring
  security_rule {
    name                       = "Grafana"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Acces Prometheus pour les metriques
  security_rule {
    name                       = "Prometheus"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ============================================================
# IP publique statique — adresse fixe accessible depuis Internet
# SKU Standard requis pour les zones de disponibilite
# ============================================================
resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

# ============================================================
# Interface reseau — connecte la VM au sous-reseau et a l'IP publique
# ============================================================
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Association du NSG a l'interface reseau
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ============================================================
# Machine Virtuelle Linux — Ubuntu 22.04 LTS
# Taille : Standard_B2als_v2 (2 vCPU, 4 Go RAM)
# Le cloud-init installe automatiquement Docker et tous les services
# ============================================================
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B2als_v2"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  zone                            = "1"

  # Script cloud-init encode en base64 — s'execute au premier demarrage
  # Installe Docker, clone le repo, demarre tous les services
  custom_data = base64encode(file("${path.module}/cloud-init.sh"))

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # Cle SSH pour acces securise sans mot de passe
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image Ubuntu 22.04 LTS officielle de Canonical
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

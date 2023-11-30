terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.80.0"
    }
  }
}

provider "azurerm" {
  #authenticating in Azure
  subscription_id = "TESTE"
  client_id       = "TESTE"
  client_secret   = "TESTE"
  tenant_id       = "TESTE"
  features {
    resource_group {
        prevent_deletion_if_contains_resources = false
        }

  }
}

#creating variables - get external input from a keyboard
#variable "storage_account_name" {
#type = string
#description = "Please type Storage Account Name"
#}

#local variables
locals {
  resource_group_name   = "terrastudyform"
  storage_account_name  = "terrastoacc2023"
  storage_account_name2 = "terrasto20232b"
  vm_name = "testbk-vm"
  location = "West Europe"

}
#creating resources
resource "azurerm_resource_group" "mainRG" {
  name     = local.resource_group_name
  location = local.location
  tags = {
    Owner      = "Teste TerraForm"
    Department = "FIOCC"
  }
}
data "azurerm_subnet" "existentsubnet" {
  name                 = "default"
  resource_group_name  = local.resource_group_name
  virtual_network_name = "terraform-vnet"
  
}


resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = local.location
  resource_group_name = azurerm_resource_group.mainRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.existentsubnet
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.mainRG.name
  location            = azurerm_resource_group.mainRG.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password = "teste2023@@"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  depends_on = [ azurerm_network_interface.example ]
}




#------- general comments ---------
# first you will execute 'terraform init', this will start terraform, must be a valid config file on the executed path
# then you will validate the actions terraform is about to execute with plan 'terraform plan -out main.tfplan'
#To perform exactly these actions, run the following command to apply: 'terraform apply "main.tfplan"'
# BE AWARE, if you remove a resource block this could destroy the created resource.
#if made any outside change from config.file eg. portal, if you plan the terraform you are able to see the difference from the actual config state file
#removing any command line will return to the original state either
# you can use depends_on when a block depends of other resource has been createad
#variables block you can get an user typed input while local you declare on the begining the variable value
#data block is used do retrieve existent resources - most know as attributes, when there are created resources

















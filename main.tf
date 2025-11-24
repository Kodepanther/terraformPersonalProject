terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

   backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate20225"  # Replace with your actual storage account name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedBy   = "Learning Project"
  }
  
  resource_prefix = "${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "learning_rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "learning_vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.learning_rg.location
  resource_group_name = azurerm_resource_group.learning_rg.name
  address_space       = var.vnet_address_space

  tags = local.common_tags
}


resource "azurerm_subnet" "learning_subnet" {
  name                 = "subnet-web-${var.environment}"
  resource_group_name  = azurerm_resource_group.learning_rg.name
  virtual_network_name = azurerm_virtual_network.learning_vnet.name
  address_prefixes     = var.subnet_address_prefix
}

module "website_storage" {
  source = "./modules"
  
  storage_account_name     = "st${var.project_name}${var.environment}001"
  resource_group_name      = azurerm_resource_group.learning_rg.name
  location                 = azurerm_resource_group.learning_rg.location
  enable_static_website    = true
  index_document           = "index.html"
  tags                     = local.common_tags
}



resource "azurerm_storage_blob" "index_html" {
  name                   = "index.html"
  storage_account_name   = module.website_storage.storage_account_name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = <<-EOT
    <!DOCTYPE html>
    <html>
    <head>
        <title>My Terraform Project - Using Modules!</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }
            .container {
                background: rgba(255, 255, 255, 0.1);
                padding: 40px;
                border-radius: 10px;
                backdrop-filter: blur(10px);
            }
            h1 { font-size: 2.5em; margin-bottom: 20px; }
            p { font-size: 1.2em; line-height: 1.6; }
            .badge {
                background: rgba(255,255,255,0.2);
                padding: 5px 15px;
                border-radius: 20px;
                display: inline-block;
                margin: 5px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Phase 7: Modules!</h1>
            <p>This website now uses a reusable Terraform module!</p>
            <div>
                <span class="badge">Environment: ${var.environment}</span>
                <span class="badge">Project: ${var.project_name}</span>
            </div>
            <p>✅ Resource Group<br>
               ✅ Virtual Network<br>
               ✅ Storage Module<br>
               ✅ Remote State Backend</p>
            <p>You're now writing production-ready Terraform code!</p>
        </div>
    </body>
    </html>
  EOT

  depends_on = [module.website_storage]
}
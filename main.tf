
# https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html#vpc-limits-security-groups

locals {
  # Read json files and append them into a single directory
  inputfiles = [for f in fileset(path.module, "JsonObjects/${var.file_pattern}") : jsondecode(file(f))]

  security_group_resources = merge(local.inputfiles...)
}

data "azurerm_resource_group" "this" {
  name = var.rg_name
}

# For test
# module "web_server_nsg" {
#   source  = "Azure/network-security-group/azurerm"
#   version = "3.6.0"

#   resource_group_name = data.azurerm_resource_group.this.name
#   location            = data.azurerm_resource_group.this.location
#   security_group_name = "web-nsg"

#   custom_rules = [
#     {
#       name                    = "HTTPS"
#       priority                = 100
#       direction               = "Inbound"
#       access                  = "Allow"
#       protocol                = "Tcp"
#       source_port_range       = "*"
#       destination_port_range  = "*"
#       source_address_prefixes = ["10.151.0.0/24", "10.151.1.0/24"]
#       description             = "description-https"
#     }
#   ]

#   tags = data.azurerm_resource_group.this.tags
# }

# create network security groups
module "appid_nsg" {
  source  = "Azure/network-security-group/azurerm"
  version = "3.6.0"

  for_each            = local.security_group_resources
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  security_group_name = each.key
  custom_rules = [
    {
      name                    = "${each.key}-https"
      priority                = 100
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "443"
      source_address_prefixes = lookup(each.value, "ipaddr", [])
      description             = "Security group from Json"
    }
  ]

  tags = data.azurerm_resource_group.this.tags
}

variable "tags" {
  type        = map
  default     = {}
  description = "tags"
}


variable "resource_group_name" {
  type    = string
  default = "APIM-PDL-DEV-NC"
}

variable "location" {
  type    = string
  default = "North Central US"
}

variable "vnet_name" {
  type    = string
  default = "myvnet-vnet"
}

variable "vnet_address_space" {
  type    = list
  default = ["10.0.0.0/16"]
}

variable "api_m_subnet_name" {
  type    = string
  default = "apim-subnet"
}
variable "api_gateway_subnet_name" {
  type    = string
  default = "appgw-subnet"
}

variable "api_gateway_address_prefixes" {
  type    = list
  default = ["10.0.0.0/24"]
}

variable "api_m_address_prefixes" {
  type    = list
  default = ["10.0.1.0/24"]

}
variable "api_mgmt_name" {
  type    = string
  default = "APIM-POC"
}

variable "publisher_name" {
  type    = string
  default = "PDL-APIM"
}

variable "publisher_email" {
  type    = string
  default = "srikanth.randhi@labs.com"
}

variable "api_gateway_name" {
  type    = string
  default = "apim-app-gw-pdl"
}

variable "admin_user_principal" {
  type    = list
  default = ["AWS_EASY_LEARN_hotmail.com#EXT#@AWSEASYLEARNhotmail.onmicrosoft.com"]
}

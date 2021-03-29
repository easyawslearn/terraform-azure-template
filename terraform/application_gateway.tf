//resource "azurerm_public_ip" "app_gateway_public_ip" {
//
//  name                    = "appgwapim-pip"
//  location                = azurerm_resource_group.resourse_grp.location
//  resource_group_name     = azurerm_resource_group.resourse_grp.name
//  sku                     = "Standard"
//  allocation_method       = "Dynamic"
//  idle_timeout_in_minutes = 5
//  ip_version              = "IPv4"
//
//  tags = var.tags
//}
//
//resource "azurerm_application_gateway" "app_gateway" {
//  name                = var.api_gateway_name
//  location            = azurerm_resource_group.resourse_grp.location
//  resource_group_name = azurerm_resource_group.resourse_grp.name
//
//  # step 11 - change App Gateway SKU and instances (# instances can be configured as required)
//  sku {
//    name     = "WAF_Medium"
//    tier     = "WAF"
//    capacity = 1
//  }
//
//  # step 1 - create App GW IP config
//  gateway_ip_configuration {
//    name      = "gatewayIP"
//    subnet_id = azurerm_subnet.api_gateway_subnet.id
//  }
//
//  # step 2 - configure the front-end IP port for the public IP endpoint
//  frontend_port {
//    name = "frontend-port443"
//    port = 443
//  }
//
//  # step 3 - configure the front-end IP with the public IP endpoint
//  frontend_ip_configuration {
//    name                 = "frontend1"
//    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.ip_address
//  }
//
//  # step 4 - configure certs for the App Gateway
//  ssl_certificate {
//    name     = "apim-gw-cert01"
//    key_vault_id = azurerm_key_vault_certificate.api_mgmt_cert.secret_id
//    //    data     = base64encode("${path.module}/resources/api7/api7.outstacart.com.p12")
//    //    password = "welcome123"
//  }
//
//  ssl_certificate {
//    name     = "apim-portal-cert01"
//    key_vault_id = azurerm_key_vault_certificate.api_mgmt_cert.secret_id
////    data     = base64encode("${path.module}/resources/portal7/portal7.outstacart.com.p12")
////    password = "welcome123"
//  }
//
//  # step 5 - configure HTTP listeners for the App Gateway
//  http_listener {
//    name                           = "apim-gw-listener01"
//    frontend_ip_configuration_name = "frontend1"
//    frontend_port_name             = "frontend-port443"
//    protocol                       = "Https"
//    ssl_certificate_name           = "apim-gw-cert01"
//    require_sni                    = true
//  }
//
//  http_listener {
//    name                           = "apim-portal-listener02"
//    frontend_ip_configuration_name = "frontend1"
//    frontend_port_name             = "frontend-port443"
//    protocol                       = "Https"
//    require_sni                    = true
//    ssl_certificate_name           = "apim-portal-cert01"
//  }
//
//  # step 6 - create custom probes for API-M endpoints
//  probe {
//    name                = "apim-gw-proxyprobe"
//    host                = "api7.outstacart.com"
//    path                = "/status-0123456789abcdef"
//    protocol            = "Https"
//    interval            = 30
//    timeout             = 120
//    unhealthy_threshold = 8
//  }
//
//  probe {
//    name                = "apim-portal-probe"
//    host                = "portal7.outstacart.com"
//    path                = "/signin"
//    protocol            = "Https"
//    interval            = 60
//    timeout             = 300
//    unhealthy_threshold = 8
//  }
//
//  # step 7 - upload cert for SSL-enabled backend pool resources
//  authentication_certificate {
//    name = "whitelistcert1"
//    data = base64encode("${path.module}/resources/api7/api7.outstacart.com.crt")
//  }
//
//  # step 8 - configure HTTPs backend settings for the App Gateway
//  backend_http_settings {
//    name                  = "apim-gw-poolsetting"
//    cookie_based_affinity = "Disabled"
//    probe_name            = "apim-gw-proxyprobe"
//    port                  = 443
//    protocol              = "Https"
//    request_timeout       = 180
//    authentication_certificate {
//      name = "whitelistcert1"
//    }
//  }
//
//  backend_http_settings {
//    name                  = "apim-portal-poolsetting"
//    cookie_based_affinity = "Disabled"
//    probe_name            = "apim-portal-probe"
//    port                  = 443
//    protocol              = "Https"
//    request_timeout       = 180
//    authentication_certificate {
//      name = "whitelistcert1"
//    }
//  }
//
//  # step 9a - configure back-end IP address pool with internal IP of API-M i.e. 10.0.1.5
//  backend_address_pool {
//    name         = "apimbackend"
//    ip_addresses = azurerm_api_management.api_mgmt.private_ip_addresses
//  }
//
//  # step 9b - create sinkpool for API-M requests we want to discard
//  backend_address_pool {
//    name = "sinkpool"
//  }
//
//  # step 10 - create a routing rule to allow external Internet access to the developer portal
//  request_routing_rule {
//    name                       = "apim-portal-rule01"
//    http_listener_name         = "apim-portal-listener02"
//    rule_type                  = "Basic"
//    backend_address_pool_name  = "apimbackend"
//    backend_http_settings_name = "apim-portal-poolsetting"
//  }
//
//  # step 12 - configure WAF to be in prevention mode
//  waf_configuration {
//    enabled          = true
//    firewall_mode    = "Prevention"
//    rule_set_version = "3.1"
//  }
//
//  # Line 125
//  url_path_map {
//    name = "external-urlpathmapconfig"
//    path_rule {
//      name                       = "external"
//      paths                      = ["/external/*"]
//      backend_address_pool_name  = "apimbackend"
//      backend_http_settings_name = "apim-gw-poolsetting"
//    }
//    default_backend_address_pool_name  = "sinkpool"
//    default_backend_http_settings_name = "apim-gw-poolsetting"
//  }
//
//  # Line 129
//  request_routing_rule {
//    name                       = "apim-gw-external-rule01"
//    http_listener_name         = "apim-gw-listener01"
//    rule_type                  = "PathBasedRouting"
//    backend_address_pool_name  = "apimbackend"
//    backend_http_settings_name = "apim-gw-poolsetting"
//    url_path_map_name          = "external-urlpathmapconfig"
//  }
//
//  tags = var.tags
//}
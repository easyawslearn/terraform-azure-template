resource "azurerm_application_gateway" "app_gateway" {
  name                = var.api_gateway_name
   location            = azurerm_resource_group.resourse_grp.location
  resource_group_name = azurerm_resource_group.resourse_grp.name
  enable_http2        = true
  firewall_policy_id  = var.firewall_policy_id

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      fqdns        = lookup(backend_address_pool.value, "fqdns", null)
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", "Enabled")
      affinity_cookie_name                = lookup(backend_http_settings.value, "affinity_cookie_name", null)
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", 5)
      port                                = lookup(backend_http_settings.value, "port", 80)
      path                                = lookup(backend_http_settings.value, "path", null)
      protocol                            = lookup(backend_http_settings.value, "protocol", "Http")
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", false)
      host_name                           = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", true) == true ? null : lookup(backend_http_settings.value, "host_name", null)
      trusted_root_certificate_names      = lookup(backend_http_settings.value, "trusted_root_certificate_names", null)

      dynamic "authentication_certificate" {
        for_each = lookup(backend_http_settings.value, "authentication_certificate", [])
        content {
          name = authentication_certificate.value.name
        }
      }

      dynamic "connection_draining" {
        for_each = lookup(backend_http_settings.value, "connection_draining", null) == null ? [] : ["true"]
        content {
          drain_timeout_sec = backend_http_settings.value.connection_draining.drain_timeout_sec
          enabled           = backend_http_settings.value.connection_draining.enabled
        }
      }
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.value.name
      subnet_id                     = lookup(frontend_ip_configuration.value, "subnet_id", null)
      private_ip_address            = lookup(frontend_ip_configuration.value, "private_ip_address", null)
      public_ip_address_id          = lookup(frontend_ip_configuration.value, "public_ip_address_id", null)
      private_ip_address_allocation = lookup(frontend_ip_configuration.value, "private_ip_address_allocation", "Dynamic")
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "authentication_certificate" {
    for_each = var.authentication_certificates
    content {
      name = authentication_certificate.value.name
      data = authentication_certificate.value.data
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates
    content {
      name = trusted_root_certificate.value.name
      data = trusted_root_certificate.value.data
    }
  }


  dynamic "gateway_ip_configuration" {
    for_each = var.gateway_ip_configurations
    content {

      name      = gateway_ip_configuration.value.name
      subnet_id = gateway_ip_configuration.value.subnet_id
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = lookup(http_listener.value, "host_name", null)
      host_names                     = lookup(http_listener.value, "host_names", null) == null ? [] : http_listener.value.host_names
      require_sni                    = lookup(http_listener.value, "require_sni", null)
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
      firewall_policy_id             = lookup(http_listener.value, "firewall_policy_id", null)

      dynamic "custom_error_configuration" {
        for_each = lookup(http_listener.value, "custom_error_configuration", null) == null ? [] : http_listener.value.custom_error_configuration
        content {
          custom_error_page_url = custom_error_configuration.value.custom_error_page_url
          status_code           = custom_error_configuration.value.status_code
        }
      }

    }
  }

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : ["true"]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "custom_error_configuration" {
    for_each = var.custom_error_configurations
    content {
      custom_error_page_url = custom_error_configuration.value.custom_error_page_url
      status_code           = custom_error_configuration.value.status_code
    }
  }


  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      http_listener_name          = request_routing_rule.value.http_listener_name
      name                        = request_routing_rule.value.name
      rule_type                   = request_routing_rule.value.rule_type
      backend_address_pool_name   = lookup(request_routing_rule.value, "backend_address_pool_name", null)
      backend_http_settings_name  = lookup(request_routing_rule.value, "backend_http_settings_name", null)
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
      rewrite_rule_set_name       = lookup(request_routing_rule.value, "rewrite_rule_set_name", null)
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
    }
  }

  dynamic "sku" {
    for_each = var.sku == null ? [] : ["true"]
    content {
      name     = var.sku.name
      tier     = var.sku.tier
      capacity = var.autoscale_configuration == null ? var.sku.capacity : null
    }
  }

  dynamic "ssl_policy" {
    for_each = var.ssl_policy
    content {
      disabled_protocols   = lookup(ssl_policy.value, "disabled_protocols", null)
      policy_type          = ssl_policy.value.policy_type
      policy_name          = lookup(ssl_policy.value, "policy_name", null)
      cipher_suites        = lookup(ssl_policy.value, "cipher_suites", null)
      min_protocol_version = lookup(ssl_policy.value, "min_protocol_version", null)
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = lookup(ssl_certificate.value, "data", null)
      password            = lookup(ssl_certificate.value, "password", null)
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      host                                      = lookup(probe.value, "pick_host_name_from_backend_http_settings", false) == true ? null : lookup(probe.value, "host", null)
      interval                                  = probe.value.interval
      name                                      = probe.value.name
      path                                      = probe.value.path
      protocol                                  = probe.value.protocol
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", false)
      minimum_servers                           = probe.value.minimum_servers
      dynamic "match" {
        for_each = lookup(probe.value, "match", null) == null ? [] : ["true"]
        content {
          body        = probe.value.match.body
          status_code = probe.value.match.status_code
        }
      }
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = lookup(url_path_map.value, "default_backend_address_pool_name", null)
      default_backend_http_settings_name  = lookup(url_path_map.value, "default_backend_http_settings_name", null)
      default_redirect_configuration_name = lookup(url_path_map.value, "default_redirect_configuration_name", null)
      default_rewrite_rule_set_name       = lookup(url_path_map.value, "default_rewrite_rule_set_name", null)
      dynamic "path_rule" {
        for_each = url_path_map.value.path_rule
        content {
          name                        = path_rule.value.name
          paths                       = path_rule.value.paths
          backend_address_pool_name   = lookup(path_rule.value, "backend_address_pool_name", null)
          backend_http_settings_name  = lookup(path_rule.value, "backend_http_settings_name", null)
          redirect_configuration_name = lookup(path_rule.value, "redirect_configuration_name", null)
          rewrite_rule_set_name       = lookup(path_rule.value, "rewrite_rule_set_name", null)
        }
      }
    }
  }

  dynamic "custom_error_configuration" {
    for_each = var.custom_error_configurations
    content {
      custom_error_page_url = custom_error_configuration.value.custom_error_page_url
      status_code           = custom_error_configuration.value.status_code
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirect_configuration == null ? [] : ["true"]
    content {
      name                 = var.redirect_configuration.name
      redirect_type        = var.redirect_configuration.redirect_type
      target_listener_name = lookup(var.redirect_configuration, "target_listener_name", null)
      target_url           = lookup(var.redirect_configuration, "target_url", null)
      include_path         = lookup(var.redirect_configuration, "include_path", null)
      include_query_string = lookup(var.redirect_configuration, "include_query_string", null)
    }
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration == null ? [] : ["true"]
    content {
      min_capacity = var.autoscale_configuration.min_capacity
      max_capacity = lookup(var.autoscale_configuration, "max_capacity", 2)
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_set
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rewrite_rule
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = rewrite_rule.value.condition
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = lookup(condition.value, "ignore_case", false)
              negate      = lookup(condition.value, "negate", false)
            }
          }

          dynamic "request_header_configuration" {
            for_each = rewrite_rule.value.request_header_configuration

            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = rewrite_rule.value.response_header_configuration
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

        }
      }
    }
  }

  tags = local.tags
}
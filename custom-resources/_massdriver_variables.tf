// Auto-generated variable declarations from massdriver.yaml
variable "azure_service_principal" {
  type = object({
    data = object({
      client_id       = string
      client_secret   = string
      subscription_id = string
      tenant_id       = string
    })
    specs = object({})
  })
}
variable "cluster" {
  type = object({
    enable_log_analytics = bool
  })
}
variable "core_services" {
  type = object({
    azure_dns_zones = optional(list(string))
    enable_ingress  = optional(bool)
  })
}
variable "md_metadata" {
  type = object({
    default_tags = object({
      managed-by  = string
      md-manifest = string
      md-package  = string
      md-project  = string
      md-target   = string
    })
    deployment = object({
      id = string
    })
    name_prefix = string
    observability = object({
      alarm_webhook_url = string
    })
    package = object({
      created_at             = string
      deployment_enqueued_at = string
      previous_status        = string
      updated_at             = string
    })
    target = object({
      contact_email = string
    })
  })
}
variable "monitoring" {
  type = object({
    prometheus = object({
      grafana_enabled  = bool
      grafana_password = optional(string)
    })
  })
}
variable "node_groups" {
  type = object({
    additional_node_groups = optional(list(object({
      compute_type = string
      max_size     = number
      min_size     = number
      name         = string
      node_size    = optional(string)
    })))
    default_node_group = object({
      compute_type = string
      max_size     = number
      min_size     = number
      name         = string
      node_size    = optional(string)
    })
  })
}
variable "vnet" {
  type = object({
    data = object({
      infrastructure = object({
        cidr              = string
        default_subnet_id = string
        id                = string
      })
    })
    specs = optional(object({
      azure = optional(object({
        region = string
      }))
    }))
  })
}

locals {
  dns_zones           = try(var.core_services.azure_dns_zones.dns_zones, [])
  dns_resource_group  = try(var.core_services.azure_dns_zones.resource_group, "")
  enable_cert_manager = length(local.dns_zones) > 0 && length(local.dns_resource_group) > 0
}

data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "cert_manager" {
  count        = local.enable_cert_manager ? 1 : 0
  display_name = "${var.md_metadata.name_prefix}-certmanager"
}

resource "kubernetes_manifest" "cluster_issuer" {
  count = local.enable_cert_manager ? 1 : 0
  manifest = {
    "apiVersion" = "cert-manager.io/v1",
    "kind"       = "ClusterIssuer",
    "metadata" = {
      "name" : "letsencrypt-prod"
    },
    "spec" = {
      "acme" = {
        // need to get this e-mail from the domain
        "email" : "support+letsencrypt@massdriver.cloud"
        "server" : "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" : "letsencrypt-prod-issuer-account-key"
        },
        "solvers" = concat([for zone in var.core_services.azure_dns_zones.dns_zones : {
          "selector" = {
            "dnsZones" = [
              zone
            ]
          },
          "dns01" = {
            "azureDNS" = {
              clientID = data.azuread_service_principal.cert_manager.0.application_id
              clientSecretSecretRef = {
                name = "cert-manager-auth"
                key  = "client-cert"
              }
              subscriptionID    = data.azurerm_client_config.current.subscription_id
              tenantID          = data.azurerm_client_config.current.tenant_id
              resourceGroupName = var.core_services.azure_dns_zones.resource_group
              hostedZoneName    = zone
            }
          }
          }], [ // could put other solvers here
        ])
      }
    }
  }
}

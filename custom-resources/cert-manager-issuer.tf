locals {
  enable_azure_dns = length(var.core_services.azure_dns_zones.dns_zone) > 0
  split_zone_id    = split("/", var.core_services.azure_dns_zones.dns_zone[0])
  azure_dns_zones = local.enable_azure_dns ? { # This is hardcoded to expect a single element. Will need to change this when multiple DNS zones are supported by external DNS.
    dns_zones      = element(local.split_zone_id, index(local.split_zone_id, "dnszones") + 1)
    resource_group = element(local.split_zone_id, index(local.split_zone_id, "resourceGroups") + 1)
  } : null
  enable_cert_manager = local.enable_azure_dns
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
        "solvers" = [{
          "selector" = {
            "dnsZones" = [
              local.azure_dns_zones.dns_zones
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
              resourceGroupName = local.azure_dns_zones.resource_group
              hostedZoneName    = local.azure_dns_zones.dns_zones
            }
          }
        }]
      }
    }
  }
}

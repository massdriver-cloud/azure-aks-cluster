locals {
  dns_zones           = try(var.core_services.azure_dns_zones, [])
  enable_cert_manager = length(local.dns_zones) > 0

  # The zone id returned by the dropdown is the entire resource id.
  zones_with_resource_group = [
    for zone_id in local.dns_zones : {
      name           = element(split("/", zone_id), index(split("/", zone_id), "dnszones") + 1)
      resource_group = element(split("/", zone_id), index(split("/", zone_id), "resourceGroups") + 1)
    }
  ]
}

data "azurerm_client_config" "current" {
}

data "azurerm_user_assigned_identity" "cert_manager" {
  count               = local.enable_cert_manager ? 1 : 0
  name                = "${var.md_metadata.name_prefix}-certmanager"
  resource_group_name = data.azurerm_kubernetes_cluster.cluster.resource_group_name
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
        "email" : var.md_metadata.target.contact_email
        "server" : "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" : "letsencrypt-prod-issuer-account-key"
        },
        "solvers" = concat([for zone in local.zones_with_resource_group : {
          "selector" = {
            "dnsZones" = [
              zone.name
            ]
          },
          "dns01" = {
            "azureDNS" = {
              subscriptionID    = data.azurerm_client_config.current.subscription_id
              resourceGroupName = zone.resource_group
              hostedZoneName    = zone.name
              managedIdentity = {
                clientID = data.azurerm_user_assigned_identity.cert_manager[0].client_id
              }
            }
          }
          }], [ // could put other solvers here
        ])
      }
    }
  }
}

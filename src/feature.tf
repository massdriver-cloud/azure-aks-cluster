locals {
  token_response = jsondecode(data.http.token.response_body)
  token          = lookup(local.token_response, "access_token", "")
}

data "http" "token" {
  url    = "https://login.microsoftonline.com/${var.azure_service_principal.data.tenant_id}/oauth2/token"
  method = "POST"

  request_body = "grant_type=Client_Credentials&client_id=${var.azure_service_principal.data.client_id}&client_secret=${var.azure_service_principal.data.client_secret}&resource=https://management.azure.com/"
}

data "http" "feature" {
  url    = "https://management.azure.com/subscriptions/${var.azure_service_principal.data.subscription_id}/providers/Microsoft.Features/providers/Microsoft.ContainerService/features/EnableWorkloadIdentityPreview/register?api-version=2021-07-01"
  method = "POST"

  request_headers = {
    "Authorization" = "Bearer ${local.token}"
  }
}

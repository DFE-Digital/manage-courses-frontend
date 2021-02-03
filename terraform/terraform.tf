terraform {
  required_version = "~> 0.13.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.45.1"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }
    statuscake = {
      source  = "terraform-providers/statuscake"
      version = "1.0.0"
    }
  }
  backend azurerm {
  }
}

provider cloudfoundry {
  api_url      = local.cf_api_url
  user         = local.infra_secrets.CF_USER
  password     = local.infra_secrets.CF_PASSWORD
  sso_passcode = var.cf_sso_passcode
}

provider statuscake {
  username = local.infra_secrets.STATUSCAKE_USERNAME
  apikey   = local.infra_secrets.STATUSCAKE_PASSWORD
}

provider azurerm {
  features {}

  skip_provider_registration = true
  subscription_id            = local.azure_credentials.subscriptionId
  client_id                  = local.azure_credentials.clientId
  client_secret              = local.azure_credentials.clientSecret
  tenant_id                  = local.azure_credentials.tenantId
}


module paas {
  source = "./modules/paas"

  cf_space                  = var.cf_space
  app_environment           = var.paas_app_environment
  docker_image              = var.paas_docker_image
  dockerhub_credentials     = local.dockerhub_credentials
  web_app_host_name         = var.paas_web_app_host_name
  web_app_memory            = var.paas_web_app_memory
  web_app_instances         = var.paas_web_app_instances
  app_environment_variables = local.paas_app_environment_variables
}

module statuscake {
  source = "./modules/statuscake"

  alerts = var.statuscake_alerts
}

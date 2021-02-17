ifndef VERBOSE
.SILENT:
endif

help:
	echo "Environment setup targets:"
	echo "  review     - configure for review app"
	echo "  qa"
	echo "  staging"
	echo "  production"
	echo ""
	echo "Commands:"
	echo "  deploy-plan - Print out the plan for the deploy, does not deploy."
	echo ""
	echo "Command Options:"
	echo "      APP_NAME  - name of the review application being setup, only required when DEPLOY_ENV is review"
	echo "      IMAGE_TAG - git sha of a built image, see builds in GitHub Actions"
	echo "      PASSCODE  - your authentication code for GOVUK PaaS, retrieve from"
	echo "                  https://login.london.cloud.service.gov.uk/passcode"
	echo ""
	echo "Examples:"
	echo "  Create a review app"
	echo "    You will need to retrieve the authentication code from GOVUK PaaS"
	echo "    visit https://login.london.cloud.service.gov.uk/passcode. Then run"
	echo "    deploy-plan to test:"
	echo ""
	echo "        make review APP_NAME=<APP_NAME> deploy-plan IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"
	echo "  Delete a review app"
	echo ""
	echo "        make review APP_NAME=<APP_NAME> destroy IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"
	echo "Examples:"
	echo "  Deploy an pre-built image to qa"
	echo ""
	echo "        make qa deploy IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"

review:
	$(eval DEPLOY_ENV=review)
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a name for your review app))
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval backend_key=-backend-config=key=$(APP_NAME).terraform.tfstate)
	$(eval export TF_VAR_paas_app_environment_config=review)
	$(eval export TF_VAR_paas_app_environment=review-$(APP_NAME))
	$(eval export TF_VAR_paas_web_app_host_name-$(APP_NAME))
	echo https://publish-teacher-training-$(APP_NAME).london.cloudapps.digital will be created in bat-qa space

.PHONY: local
local: ## Configure local dev environment
	$(eval DEPLOY_ENV=local)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

.PHONY: qa
qa: ## Set DEPLOY_ENV to qa
	$(eval DEPLOY_ENV=qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

.PHONY: staging
staging: ## Set DEPLOY_ENV to staging
	$(eval DEPLOY_ENV=staging)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)

.PHONY: sandbox
sandbox: ## Set DEPLOY_ENV to sandbox
	$(eval DEPLOY_ENV=sandbox)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)

.PHONY: production
production: ## Set DEPLOY_ENV to production
	$(eval DEPLOY_ENV=production)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))

install-fetch-config:
	[[ ! -f bin/fetch_config.rb ]] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

set-azure-account:
	az account set -s ${AZ_SUBSCRIPTION} && az account show

edit-app-secrets: install-fetch-config set-azure-account
	. terraform/workspace_variables/$(DEPLOY_ENV).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} \
		-e -d azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} -f yaml

edit-infra-secrets: install-fetch-config set-azure-account
	. terraform/workspace_variables/$(DEPLOY_ENV).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_infra_secret_name} \
		-e -d azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_infra_secret_name} -f yaml

deploy-init:
	$(eval export TF_DATA_DIR=./terraform/.terraform)
	$(if $(IMAGE_TAG), , $(error Missing environment variable "IMAGE_TAG"))
	$(eval export TF_VAR_paas_docker_image=dfedigital/publish-teacher-training:paas-$(IMAGE_TAG))
	$(eval export TF_VAR_paas_app_config_file=./terraform/workspace_variables/app_config.yml)
	$(eval export TF_VAR_paas_app_secrets_file=./terraform/workspace_variables/app_secrets.yml)
	az account set -s ${AZ_SUBSCRIPTION} && az account show
	terraform init -reconfigure -backend-config=terraform/workspace_variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key) terraform
	echo "🚀 DEPLOY_ENV is $(DEPLOY_ENV)"

deploy-plan: deploy-init
	. terraform/workspace_variables/$(DEPLOY_ENV).sh \
		&& terraform plan -var-file=terraform/workspace_variables/$(DEPLOY_ENV).tfvars terraform

deploy: deploy-init
	. terraform/workspace_variables/$(DEPLOY_ENV).sh \
		&& terraform apply -var-file=terraform/workspace_variables/$(DEPLOY_ENV).tfvars -auto-approve terraform

destroy: deploy-init
	. terraform/workspace_variables/$(DEPLOY_ENV).sh \
		&& terraform destroy -var-file=terraform/workspace_variables/$(DEPLOY_ENV).tfvars terraform

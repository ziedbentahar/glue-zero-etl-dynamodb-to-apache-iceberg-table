.PHONY: all clean build deploy destroy terraform-init terraform-plan terraform-apply terraform-destroy

all: build deploy

clean:
	@rm -rf ./src/dist

build:
	pnpm -C ./src/ install
	pnpm -C ./src/ run bundle

deploy: terraform-init terraform-plan terraform-apply

deploy-glue-zero-etl:
	@./infra/create-zero-etl-integration.sh

destroy: terraform-destroy

terraform-init:
	@terraform -chdir=./infra init

terraform-plan:
	@terraform -chdir=./infra plan

terraform-apply:
	@terraform -chdir=./infra apply -auto-approve

terraform-destroy:
	@terraform -chdir=./infra destroy -auto-approve

destroy-glue-zero-etl:
	@./infra/delete-zero-etl-integration.sh
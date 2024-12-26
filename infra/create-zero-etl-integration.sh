#!/bin/bash

AWS_REGION=eu-west-1
INFRA_DIR=./infra
APP_INFO=xcxcxc
APP_ENV=dev

INTEGRATION_PARAM_NAME="/$APP_INFO/$APP_ENV/zero-etl-integration"

output_value=$(terraform -chdir=$INFRA_DIR output -raw integration_parameters_arns)

json_value=$(aws ssm get-parameter \
    --name "$output_value" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text --region $AWS_REGION)

source_arn=$(echo "$json_value" | jq -r '.sourceArn')
target_arn=$(echo "$json_value" | jq -r '.targetArn')
role_arn=$(echo "$json_value" | jq -r '.roleArn')
integration_name=$(echo "$json_value" | jq -r '.integrationName')

create_glue_integration_result=$(aws glue create-integration \
    --integration-name $integration_name \
    --source-arn $source_arn \
    --target-arn $target_arn \
    --region $AWS_REGION)

integration_arn=$(echo "$create_glue_integration_result" | jq -r '.IntegrationArn')





aws ssm put-parameter \
    --name  $INTEGRATION_PARAM_NAME\
    --value $integration_arn \
    --type "String" \
    --region $AWS_REGION

update_glue_integration_result=$(aws glue create-integration-resource-property\
   --resource-arn $target_arn \
   --target-processing-properties RoleArn=$role_arn \
   --region $AWS_REGION)


update_glue_integration_result=$(aws glue create-integration-table-properties\
   --resource-arn $target_arn \
   --table-name testzied \
   --target-table-config "UnnestSpec=FULL,PartitionSpec=[{FieldName=orderdate,FunctionSpec=day}],TargetTableName=testzied" \
   --region $AWS_REGION)










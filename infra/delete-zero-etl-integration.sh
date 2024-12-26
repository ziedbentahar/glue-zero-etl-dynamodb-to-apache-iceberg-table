#!/bin/bash

AWS_REGION=eu-west-1
INFRA_DIR=./infra

APP_INFO=xcxcxc
APP_ENV=dev
INTEGRATION_PARAM_NAME="/$APP_INFO/$APP_ENV/zero-etl-integration"


integration_arn=$(aws ssm get-parameter \
    --name "$INTEGRATION_PARAM_NAME" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text --region $AWS_REGION)

aws glue delete-integration --integration-identifier $integration_arn --region $AWS_REGION

aws ssm delete-parameters --names "$INTEGRATION_PARAM_NAME" --region $AWS_REGION



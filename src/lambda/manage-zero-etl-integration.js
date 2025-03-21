import { GlueClient, CreateIntegrationCommand, CreateIntegrationResourcePropertyCommand, DeleteIntegrationCommand, CreateIntegrationTablePropertiesCommand } from "@aws-sdk/client-glue";
import { SSMClient, PutParameterCommand, GetParameterCommand } from "@aws-sdk/client-ssm";


export const handler = async (event) => {

    let glueClient = new GlueClient({ region: process.env.AWS_REGION });
    let paramStore = new SSMClient({ region: process.env.AWS_REGION });

    if(event.sourceArn == null || event.targetArn == null || event.roleArn == null) {
        throw new Error("SourceArn, TargetArn and RoleArn are required");
    }

    if (event.tf.action === "create") {

        const integrationResourcePropertyResult =  await glueClient.send(new CreateIntegrationResourcePropertyCommand({
            ResourceArn: event.targetArn,
            TargetProcessingProperties: {
                RoleArn: event.roleArn
            }
        }));
        
        const integrationResult = await glueClient.send(new CreateIntegrationCommand({
            IntegrationName : event.integrationName,
            SourceArn : event.sourceArn,
            TargetArn : event.targetArn,
    
        }));

        await glueClient.send(new CreateIntegrationTablePropertiesCommand({
            ResourceArn: integrationResult.IntegrationArn,
            TableName: event.tableConfig.tableName,
            TargetTableConfig: {
                PartitionSpec: event.tableConfig.partitionSpec ? event.tableConfig.partitionSpec : undefined,
                UnnestSpec: event.tableConfig.unnestSpec ? event.tableConfig.unnestSpec : undefined,
                TargetTableName: event.tableConfig.tableName ? event.tableConfig.tableName : undefined
            }
            
        }));

        await paramStore.send(new PutParameterCommand({
            Name: event.integrationName,
            Value: JSON.stringify({
                integrationArn:  integrationResult.IntegrationArn,
                resourcePropertyArn: integrationResourcePropertyResult.ResourceArn
            }),
            Type: "String",
            Overwrite: true
        }));
      
        return;
    }

    if (event.tf.action === "delete") {
        const integrationParams = await paramStore.send(new GetParameterCommand({
            Name: event.integrationName,
        }));

        const { integrationArn } = JSON.parse(integrationParams.Parameter.Value);

        await glueClient.send(new DeleteIntegrationCommand({
            IntegrationIdentifier: integrationArn
        }));
     
        return;
    }
 
};

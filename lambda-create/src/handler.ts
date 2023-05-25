import type {APIGatewayProxyEvent, APIGatewayProxyResult} from 'aws-lambda';
import middy from '@middy/core';
import getDynamodbClient from '../../lambda-shared-utils/src/dynamodb';
import {Logger, injectLambdaContext} from '@aws-lambda-powertools/logger';
import { DocumentClient } from 'aws-sdk/clients/dynamodb';

const logger = new Logger({serviceName: 'lambda-create.handler'})

const TABLENAME = `my-table-${process.env.ENV}`

async function createHandler(event: APIGatewayProxyEvent): Promise <APIGatewayProxyResult> {
    const body = JSON.parse(event.body || '"');

    const client = getDynamodbClient();

    const params: DocumentClient.PutItemInput = {
        TableName: TABLENAME,
        Item: {
            id: body.id
        }
    }

    try {
        await client.put(params).promise();
    } catch (e) {
        logger.error(`${e}`);
    }

    return {
        statusCode: 201,
        body: JSON.stringify({})
    }
}

const handler = middy(createHandler).use(injectLambdaContext(logger, { logEvent: true}));

export default handler;
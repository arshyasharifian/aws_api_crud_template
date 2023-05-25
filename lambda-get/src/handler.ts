import type {APIGatewayProxyEvent, APIGatewayProxyResult} from 'aws-lambda';
import middy from '@middy/core';
import getDynamodbClient from '../../lambda-shared-utils/src/dynamodb';
import {Logger, injectLambdaContext} from '@aws-lambda-powertools/logger';
import { DocumentClient } from 'aws-sdk/clients/dynamodb';

const logger = new Logger({serviceName: 'lambda-get.handler'})

const TABLENAME = `my-table-${process.env.ENV}`

async function getHandler(event: APIGatewayProxyEvent): Promise <APIGatewayProxyResult> {
    const body = JSON.parse(event.body || '"');

    const client = getDynamodbClient();

    let response: DocumentClient.GetItemOutput = {}

    const params: DocumentClient.GetItemInput = {
        TableName: TABLENAME,
        Key: {
            id: body.id
        }
    }

    try {
        response = await client.get(params).promise();
    } catch (e) {
        logger.error(`${e}`);
    }

    return {
        statusCode: 200,
        body: JSON.stringify({response})
    }
}

const handler = middy(getHandler).use(injectLambdaContext(logger, { logEvent: true}));

export default handler;
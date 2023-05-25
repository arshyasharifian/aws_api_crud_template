import { DocumentClient} from "aws-sdk/clients/dynamodb";

let client: DocumentClient

function getDynamodbClient(): DocumentClient {
    if (!client) {
        client = new DocumentClient({
            apiVersion: '2012-08-10',
            maxRetries: 2,
            httpOptions: {
                timeout: 1000,
            },
        });
    }
    return client;
}

export default getDynamodbClient;
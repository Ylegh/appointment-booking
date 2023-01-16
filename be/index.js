const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const { v4: uuid } = require("uuid");

const ddbClient = new DynamoDBClient({
    endpoint: `http://${process.env.LOCALSTACK_HOSTNAME || "localhost"}:4566`,
    region: "eu-west-2"
});

module.exports = {
    handler: (event, context, callback) => {
        if (event.httpMethod === "GET") {
            const ddbCommand = new ScanCommand({
                TableName: "appointment"
            });

            ddbClient.send(ddbCommand, (err, data) => {
                if (err) {
                    callback(err);
                }

                callback(null, {
                    statusCode: 200,
                    body: JSON.stringify(data.Items || [])
                });
            });
        } else if (event.httpMethod === 'POST') {
            const body = JSON.parse(event.body);
            const ddbCommand = new PutItemCommand({
                TableName: "appointment",
                Item: {
                    date: {
                        S: body.date
                    },
                    time: {
                        S: body.time
                    },
                    uuid: {
                        S: uuid()
                    },
                    created: {
                        S: new Date().toISOString()
                    }
                }
            });
            ddbClient.send(ddbCommand, (err, data) => {
                if (err) {
                    callback(err);
                }

                callback(null, {
                    statusCode: 201,
                    body: null
                });
            });
        } else {
            return callback(
                new Error("Not implemented")
            );
        }
    }
};
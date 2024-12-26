import { DynamoDBClient, PutItemCommand } from '@aws-sdk/client-dynamodb';
import { randomUUID } from 'crypto';

const client = new DynamoDBClient({ region: 'eu-west-1'  });
const tableName = "orders";

function generateShippingAddress() {
    const countries = ["USA", "Canada", "UK", "Germany", "Australia"];
    const cities = ["New York", "Toronto", "London", "Berlin", "Sydney"];
    const streets = ["1st Ave", "Main St", "Broadway", "High St", "Park Ave"];

    return {
        country: countries[Math.floor(Math.random() * countries.length)],
        zip: Math.floor(10000 + Math.random() * 90000).toString(),
        city: cities[Math.floor(Math.random() * cities.length)],
        street: streets[Math.floor(Math.random() * streets.length)],
    };
}

function generateItems() {
    const products = ["P001", "P002", "P003", "P004", "P005", "P006", "P007", "P008", "P009", "P010"];
    const items = [];
    const itemCount = Math.floor(1 + Math.random() * 3);

    for (let i = 0; i < itemCount; i++) {
        items.push({
            productId: products[Math.floor(Math.random() * products.length)],
            quantity: Math.floor(1 + Math.random() * 5),
            price: parseFloat((10 + Math.random() * 90).toFixed(2))
        });
    }

    return items;
}


function pickRandom(arr, ) {
    const numItems = Math.floor(Math.random() * arr.length) + 1;
    const shuffled = arr.slice().sort(() => 0.5 - Math.random()); 
    return shuffled.slice(0, numItems);
}

let numberOfItems = 10_000;
(async function createOrders() {
    for (let i = 0; i < numberOfItems; i++) {
        const orderId = randomUUID();
        const customerId = randomUUID();
        const orderDate = new Date(Date.now() - Math.floor(Math.random() * 30 * 24 * 60 * 60 * 1000)).toISOString();
        const status = ["Pending", "Shipped", "Delivered", "Cancelled"][
            Math.floor(Math.random() * 4)
        ];
        const shippingAddress = generateShippingAddress();
        const items = generateItems();

        const item = {
            orderId: { S: orderId },
            customerId: { S: customerId },
            orderDate: { S: orderDate },
            status: { S: status },
            shippingAddress: { M: {
                country: { S: shippingAddress.country },
                zip: { S: shippingAddress.zip },
                city: { S: shippingAddress.city },
                street: { S: shippingAddress.street }
            } },
            deliveryPreferences: { SS:  pickRandom(["LeaveAtDoor", "Contactless", "DeliverInTheMorning", "DeliverInTheAfternoon", "CallBeforeDelivery"]) },
            items: { L: items.map(item => ({
                M: {
                    productId: { S: item.productId },
                    quantity: { N: item.quantity.toString() },
                    price: { N: item.price.toString() }
                }
            })) }
        };

        try {
            const command = new PutItemCommand({ TableName: tableName, Item: item });
            await client.send(command);
            console.log(`Successfully inserted OrderId: ${orderId}`);
        } catch (error) {
            console.error(`Error inserting OrderId: ${orderId}, Error:`, error);
        }
    }
})();

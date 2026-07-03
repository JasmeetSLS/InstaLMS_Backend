const admin = require("../config/firebase");
const { pool } = require("../config/db");

exports.sendNotificationToAllUsers = async (title, body, data = {}) => {
    let connection;

    try {
        connection = await pool.getConnection();

        const [users] = await connection.query(`
            SELECT id, name, fcm_token
            FROM users
            WHERE status = 'active'
            AND fcm_token IS NOT NULL
            AND fcm_token != ''
        `);

        if (users.length === 0) {
            console.log("❌ No active users with FCM token found.");
            return;
        }

        const tokens = users.map(user => user.fcm_token);

        console.log("====================================");
        console.log("Push Notification Started");
        console.log("Total Users :", users.length);
        console.log("Total Tokens:", tokens.length);

        const message = {
            notification: {
                title,
                body,
            },
            data,
            android: {
                priority: "high",
            },
            apns: {
                payload: {
                    aps: {
                        sound: "default",
                    },
                },
            },
            tokens,
        };

        const response = await admin
            .messaging()
            .sendEachForMulticast(message);

        console.log("====================================");
        console.log("Success :", response.successCount);
        console.log("Failed  :", response.failureCount);

        response.responses.forEach((result, index) => {
            if (result.success) {
                console.log(
                    `✅ User ${users[index].id} (${users[index].name}) -> Notification Sent`
                );
            } else {
                console.log(
                    `❌ User ${users[index].id} (${users[index].name})`
                );
                console.log("Token :", users[index].fcm_token);
                console.log("Code  :", result.error.code);
                console.log("Error :", result.error.message);
                console.log("------------------------------------");
            }
        });

        console.log("====================================");

        return response;

    } catch (error) {
        console.error("Firebase Notification Error:");
        console.error(error);
    } finally {
        if (connection) {
            connection.release();
        }
    }
};
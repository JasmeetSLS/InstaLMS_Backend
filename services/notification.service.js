const { messaging } = require("../config/firebase");
const { pool } = require("../config/db");

exports.sendNotificationToAllUsers = async (title, body, data = {}) => {
    let connection;

    try {
        connection = await pool.getConnection();

        const [users] = await connection.query(`
            SELECT id,name,fcm_token
            FROM users
            WHERE status='active'
            AND fcm_token IS NOT NULL
            AND fcm_token <> ''
        `);

        const tokens = users.map(x => x.fcm_token);

        console.log("====================================");
        console.log("Push Notification Started");
        console.log("Total Users :", users.length);
        console.log("Total Tokens:", tokens.length);

        if (!tokens.length) {
            return;
        }

        const response = await messaging.sendEachForMulticast({
            tokens,
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
        });

        console.log("Success :", response.successCount);
        console.log("Failure :", response.failureCount);

        response.responses.forEach((r, i) => {
            if (!r.success) {
                console.log(users[i].id);
                console.log(r.error.code);
                console.log(r.error.message);
            }
        });

    } catch (err) {
        console.error(err);
    } finally {
        if (connection) connection.release();
    }
};
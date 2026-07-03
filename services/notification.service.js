const admin = require("../config/firebase");
const { pool } = require("../config/db");

exports.sendNotificationToAllUsers = async (title, body, data = {}) => {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(`
            SELECT fcm_token
            FROM users
            WHERE status = 'active'
              AND fcm_token IS NOT NULL
              AND fcm_token <> ''
        `);

        const tokens = rows.map(r => r.fcm_token);

        if (!tokens.length) {
            console.log("No FCM tokens found.");
            return;
        }

        const message = {
            notification: {
                title,
                body,
            },
            data,
            tokens,
        };

        const response = await admin.messaging().sendEachForMulticast(message);

        console.log("Success:", response.successCount);
        console.log("Failed :", response.failureCount);

        return response;
    } finally {
        connection.release();
    }
};
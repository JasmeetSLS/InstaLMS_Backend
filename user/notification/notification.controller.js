const { pool } = require('../../config/db');

// ------ Single mark as read (unchanged) ------
exports.markAsRead = async (req, res) => {
    try {
        const userId = req.user.userId;
        const notificationId = req.params.id;
        const connection = await pool.getConnection();
        try {
            const [existing] = await connection.query(
                `SELECT id FROM user_notification_reads WHERE user_id = ? AND notification_id = ?`,
                [userId, notificationId]
            );
            if (!existing.length) {
                await connection.query(
                    `INSERT INTO user_notification_reads (user_id, notification_id, is_read, read_at)
                     VALUES (?, ?, 1, NOW())`,
                    [userId, notificationId]
                );
                return res.json({ success: true, message: 'Marked as read' });
            }
            return res.json({ success: true, message: 'Already read' });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, error: 'Failed to mark as read' });
    }
};

// ------ Bulk mark as read (new) ------
exports.markAsReadBulk = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { notificationIds } = req.body; // array of integers

        if (!notificationIds || !Array.isArray(notificationIds) || notificationIds.length === 0) {
            return res.status(400).json({ success: false, error: 'notificationIds array is required' });
        }

        const connection = await pool.getConnection();
        try {
            // Insert each missing record
            for (const notificationId of notificationIds) {
                const [existing] = await connection.query(
                    `SELECT id FROM user_notification_reads WHERE user_id = ? AND notification_id = ?`,
                    [userId, notificationId]
                );
                if (!existing.length) {
                    await connection.query(
                        `INSERT INTO user_notification_reads (user_id, notification_id, is_read, read_at)
                         VALUES (?, ?, 1, NOW())`,
                        [userId, notificationId]
                    );
                }
            }

            res.json({ success: true, message: 'Notifications marked as read' });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Bulk mark read error:', error);
        res.status(500).json({ success: false, error: 'Failed to mark notifications as read' });
    }
};
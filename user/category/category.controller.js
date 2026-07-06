const { pool } = require('../../config/db');

// Get all active categories, active users, active comments, and unread notifications
exports.ActiveUsersCategoriesComments = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        const userId = req.user.userId;
        const userRoleId = req.user.role_id;

        try {
            // 1. Active categories with posts & views (unchanged)
            const [categories] = await connection.query(
                `SELECT 
                    c.id, 
                    c.name, 
                    c.icon_url, 
                    c.created_at,
                    COALESCE((
                        SELECT COUNT(DISTINCT p.id)
                        FROM posts p
                        WHERE p.status = 'active' 
                        AND p.role_id = ?
                        AND p.my_course = 0
                        AND (c.id = 1 OR p.category_id = c.id)
                    ), 0) as total_posts,
                    COALESCE((
                        SELECT COUNT(DISTINCT pv.post_id)
                        FROM post_views pv
                        INNER JOIN posts p ON pv.post_id = p.id
                        WHERE pv.user_id = ?
                        AND p.status = 'active'
                        AND p.role_id = ?
                        AND p.my_course = 0
                        AND (c.id = 1 OR p.category_id = c.id)
                    ), 0) as total_views
                 FROM categories c
                 WHERE c.status = 'active'
                 HAVING total_posts > 0
                 ORDER BY c.id ASC`,
                [userRoleId, userId, userRoleId]
            );

            // 2. Active users (except logged-in user) – unchanged
            const [users] = await connection.query(
                `SELECT id, email, employee_id, name, phone, gender, role_id, profile_url, status, created_at 
                 FROM users 
                 WHERE status = 'active' AND id != ?
                 ORDER BY id ASC`,
                [userId]
            );

            // 3. Active comments – unchanged
            const [comments] = await connection.query(
                `SELECT id, comment, status, created_at 
                 FROM comments 
                 WHERE status = 'active'
                 ORDER BY id ASC`
            );

            // 4. Unread notification count
            const [countResult] = await connection.query(
                `SELECT COUNT(*) as count
                 FROM notifications n
                 LEFT JOIN user_notification_reads unr 
                    ON n.id = unr.notification_id AND unr.user_id = ?
                 WHERE unr.id IS NULL`,
                [userId]
            );
            const unreadCount = countResult[0].count || 0;

            // 5. Fetch the actual unread notifications (latest 10)
            const [unreadNotifications] = await connection.query(
                `SELECT n.id, n.title, n.message, n.created_at
                 FROM notifications n
                 LEFT JOIN user_notification_reads unr 
                    ON n.id = unr.notification_id AND unr.user_id = ?
                 WHERE unr.id IS NULL
                 ORDER BY n.created_at DESC
                 LIMIT 10`,
                [userId]
            );

            // 6. Send response with notifications data
            res.json({
                success: true,
                categories: {
                    count: categories.length,
                    data: categories
                },
                users: {
                    count: users.length,
                    data: users
                },
                comments: {
                    count: comments.length,
                    data: comments
                },
                notifications: {
                    unread_count: unreadCount,
                    data: unreadNotifications   // <-- actual bell notifications
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Dashboard error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
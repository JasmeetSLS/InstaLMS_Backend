const { pool } = require('../../config/db');

// Get all active categories, active users, and active comments
exports.ActiveUsersCategoriesComments = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        
        // Get logged-in user ID and role_id from token
        const userId = req.user.userId;
        const userRoleId = req.user.role_id;

        try {
            // Get active categories with total posts and total views based on user role
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
                        AND (c.id = 1 OR p.category_id = c.id)
                    ), 0) as total_posts,
                    COALESCE((
                        SELECT COUNT(DISTINCT pv.post_id)
                        FROM post_views pv
                        INNER JOIN posts p ON pv.post_id = p.id
                        WHERE pv.user_id = ?
                        AND p.status = 'active'
                        AND p.role_id = ?
                        AND (c.id = 1 OR p.category_id = c.id)
                    ), 0) as total_views
                 FROM categories c
                 WHERE c.status = 'active'
                 ORDER BY c.id ASC`,
                [userRoleId, userId, userRoleId]
            );

            // Get active users except the logged-in user
            const [users] = await connection.query(
                `SELECT id, email, employee_id, name, phone, gender, role_id, profile_url, status, created_at 
                 FROM users 
                 WHERE status = 'active' AND id != ?
                 ORDER BY id ASC`,
                [userId]
            );

            // Get all active comments
            const [comments] = await connection.query(
                `SELECT id, comment, status, created_at 
                 FROM comments 
                 WHERE status = 'active'
                 ORDER BY id ASC`
            );

            const [notificationCount] = await connection.query(
                `SELECT COUNT(*) as count
                 FROM notifications n
                 LEFT JOIN user_notification_reads unr 
                    ON n.id = unr.notification_id AND unr.user_id = ?
                 WHERE unr.id IS NULL`,
                [userId]
            );

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
                    unread_count: notificationCount[0].count || 0
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get active categories error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
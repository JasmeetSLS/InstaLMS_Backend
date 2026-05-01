const { pool } = require('../../config/db');

// Get all active categories, active users, and active comments
exports.ActiveUsersCategoriesComments = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        
        // Get logged-in user ID from token
        const userId = req.user.userId;

        try {
            // Get active categories with total posts and total views
            const [categories] = await connection.query(
                `SELECT c.id, c.name, c.icon_url, c.created_at,
                        CASE 
                            WHEN c.id = 1 THEN (
                                SELECT COUNT(DISTINCT p.id)
                                FROM posts p
                                WHERE p.status = 'active'
                            )
                            ELSE COUNT(DISTINCT p.id)
                        END as total_posts,
                        CASE 
                            WHEN c.id = 1 THEN (
                                SELECT SUM(CASE 
                                    WHEN (
                                        SELECT COUNT(*) FROM post_media pm2 WHERE pm2.post_id = p2.id
                                    ) > 0 AND (
                                        SELECT COUNT(DISTINCT pmv.media_id)
                                        FROM post_media_views pmv
                                        WHERE pmv.post_id = p2.id AND pmv.user_id = ?
                                    ) = (
                                        SELECT COUNT(*) FROM post_media pm3 WHERE pm3.post_id = p2.id
                                    ) THEN 1 ELSE 0 
                                END)
                                FROM posts p2
                                WHERE p2.status = 'active'
                            )
                            ELSE SUM(CASE 
                                WHEN (
                                    SELECT COUNT(*) FROM post_media pm2 WHERE pm2.post_id = p.id
                                ) > 0 AND (
                                    SELECT COUNT(DISTINCT pmv.media_id)
                                    FROM post_media_views pmv
                                    WHERE pmv.post_id = p.id AND pmv.user_id = ?
                                ) = (
                                    SELECT COUNT(*) FROM post_media pm3 WHERE pm3.post_id = p.id
                                ) THEN 1 ELSE 0 
                            END)
                        END as total_views
                 FROM categories c
                 LEFT JOIN posts p ON c.id = p.category_id AND p.status = 'active'
                 WHERE c.status = 'active'
                 GROUP BY c.id, c.name, c.icon_url, c.created_at
                 ORDER BY c.id ASC`,
                [userId, userId]  // Two user IDs for the two subqueries
            );

            // Get active users except the logged-in user
            const [users] = await connection.query(
                `SELECT id, email, employee_id, name, phone, gender, role, profile_url, status, created_at 
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
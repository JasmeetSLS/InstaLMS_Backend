const { pool } = require('../../config/db');

// Get all active categories and active users (excluding logged-in user)
exports.ActiveUserCategories = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        
        // Get logged-in user ID from token
        const userId = req.user.userId;

        try {
            // Get active categories
            const [categories] = await connection.query(
                `SELECT id, name, icon_url, created_at 
                 FROM categories 
                 WHERE status = 'active'
                 ORDER BY id ASC`
            );

            // Get active users except the logged-in user
            const [users] = await connection.query(
                `SELECT id, email, employee_id, name, phone, gender, role, profile_url, status, created_at 
                 FROM users 
                 WHERE status = 'active' AND id != ?
                 ORDER BY id ASC`,
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
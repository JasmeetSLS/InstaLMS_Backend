const { pool } = require('../../config/db');

// Get all active categories for users
exports.getActiveCategories = async (req, res) => {
    try {
        const connection = await pool.getConnection();

        try {
            // Only get active categories for users
            const [categories] = await connection.query(
                `SELECT id, name, icon_url, created_at 
                 FROM categories 
                 WHERE status = 'active' 
                 ORDER BY id ASC`
            );

            res.json({
                success: true,
                count: categories.length,
                data: categories
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

// Get single category by ID (only if active)
exports.getCategoryById = async (req, res) => {
    try {
        const { id } = req.params;
        
        if (!id || isNaN(id)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid category ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            const [categories] = await connection.query(
                `SELECT id, name, icon_url, created_at 
                 FROM categories 
                 WHERE id = ? AND status = 'active'`,
                [id]
            );

            if (categories.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found'
                });
            }

            res.json({
                success: true,
                data: categories[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get category by ID error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
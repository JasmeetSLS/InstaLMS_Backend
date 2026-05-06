const { pool } = require('../../config/db');

// Get all roles
exports.getAllRoles = async (req, res) => {
    try {
        const [roles] = await pool.query(
            'SELECT id, name, status, created_at, updated_at FROM roles ORDER BY id ASC'
        );

        res.status(200).json({
            success: true,
            data: roles
        });
        
    } catch (error) {
        console.error('Get all roles error:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error: ' + error.message 
        });
    }
};

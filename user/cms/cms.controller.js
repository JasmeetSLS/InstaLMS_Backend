const { pool } = require('../../config/db');

// Get CMS page by ID using query param
exports.getCMSPageById = async (req, res) => {
    try {
        const { id } = req.query;

        if (!id) {
            return res.status(400).json({
                success: false,
                error: 'Page ID is required as query parameter'
            });
        }

        const connection = await pool.getConnection();

        try {
            const [pages] = await connection.query(
                `SELECT id, title, slug, content, image_url, status, created_at, updated_at 
                 FROM cms_pages 
                 WHERE id = ? AND status = 'active'`,
                [id]
            );

            if (pages.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'CMS page not found or inactive'
                });
            }

            res.status(200).json({
                success: true,
                data: pages[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get CMS page by ID error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
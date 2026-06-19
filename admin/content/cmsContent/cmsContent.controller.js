const { pool } = require('../../../config/db');

// Modify existing getContentsBySection or add a new one for admin list view
exports.getContentsBySection = async (req, res) => {
    try {
        const { sectionId } = req.params;

        if (!sectionId || isNaN(sectionId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid section ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Return only id, title, content_type for list view
            const [contents] = await connection.query(
                `SELECT id, title, content_type 
                 FROM cms_contents 
                 WHERE section_id = ? AND status = 'active'
                 ORDER BY sort_order ASC, id ASC`,
                [sectionId]
            );

            res.json({
                success: true,
                data: contents
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get contents by section error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

exports.getContentById = async (req, res) => {
    try {
        const { contentId } = req.params;

        if (!contentId || isNaN(contentId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid content ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            const [rows] = await connection.query(
                `SELECT id, section_id, content_type, title, description, 
                        media_url, thumbnail_url, pdf_url, source_url, 
                        status, sort_order, created_at, updated_at
                 FROM cms_contents 
                 WHERE id = ? AND status = 'active'`,
                [contentId]
            );

            if (rows.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Content not found or inactive'
                });
            }

            res.json({
                success: true,
                data: rows[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get content by ID error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
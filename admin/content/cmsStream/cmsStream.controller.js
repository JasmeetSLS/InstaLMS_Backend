const { pool } = require('../../../config/db');

// Get streams by category ID
exports.getStreamsByCategory = async (req, res) => {
    try {
        const { categoryId } = req.params;

        if (!categoryId || isNaN(categoryId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid category ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // First, verify the category exists and is active
            const [categoryCheck] = await connection.query(
                'SELECT id FROM cms_categories WHERE id = ? AND status = "active"',
                [categoryId]
            );

            if (categoryCheck.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found or inactive'
                });
            }

            // Fetch streams with counts of sections, contents, and assessments
            const [streams] = await connection.query(
                `SELECT 
                    s.id,
                    s.title,
                    s.language,
                    s.icon_url,
                    s.content,
                    s.status,
                    s.sort_order,
                    s.created_at,
                    s.updated_at,
                    (SELECT COUNT(*) FROM cms_sections WHERE stream_id = s.id AND status = 'active') AS sections_count,
                    (SELECT COUNT(*) FROM cms_contents WHERE section_id IN 
                        (SELECT id FROM cms_sections WHERE stream_id = s.id) AND status = 'active') AS contents_count,
                    (SELECT COUNT(*) FROM cms_assessments WHERE section_id IN 
                        (SELECT id FROM cms_sections WHERE stream_id = s.id) AND status = 'active') AS assessments_count
                FROM cms_streams s
                WHERE s.category_id = ? AND s.status = 'active'
                ORDER BY s.sort_order ASC, s.id ASC`,
                [categoryId]
            );

            res.json({
                success: true,
                data: streams
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get streams by category error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
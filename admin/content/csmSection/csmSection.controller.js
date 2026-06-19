const { pool } = require('../../../config/db');

exports.getSectionsByStream = async (req, res) => {
    try {
        const { streamId } = req.params;

        if (!streamId || isNaN(streamId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid stream ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Verify stream exists and is active
            const [streamCheck] = await connection.query(
                'SELECT id FROM cms_streams WHERE id = ? AND status = "active"',
                [streamId]
            );

            if (streamCheck.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Stream not found or inactive'
                });
            }

            // Fetch sections with counts of contents and assessments
            const [sections] = await connection.query(
                `SELECT 
                    s.id,
                    s.title,
                    s.description,
                    s.status,
                    s.sort_order,
                    s.created_at,
                    s.updated_at,
                    (SELECT COUNT(*) FROM cms_contents WHERE section_id = s.id AND status = 'active') AS contents_count,
                    (SELECT COUNT(*) FROM cms_assessments WHERE section_id = s.id AND status = 'active') AS assessments_count
                FROM cms_sections s
                WHERE s.stream_id = ? AND s.status = 'active'
                ORDER BY s.sort_order ASC, s.id ASC`,
                [streamId]
            );

            res.json({
                success: true,
                data: sections
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get sections by stream error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
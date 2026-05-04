const { pool } = require('../../config/db');

// Record media view - simple insert or duplicate message
exports.recordMediaView = async (req, res) => {
    try {
        const { post_id, media_id } = req.query;
        const userId = req.user.userId;

        if (!post_id || !media_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID and Media ID are required'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if post exists and is active
            const [postCheck] = await connection.query(
                'SELECT id FROM posts WHERE id = ? AND status = "active"',
                [post_id]
            );

            if (postCheck.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Post not found or inactive'
                });
            }

            // Check if media exists and belongs to the post
            const [mediaCheck] = await connection.query(
                'SELECT id FROM post_media WHERE id = ? AND post_id = ?',
                [media_id, post_id]
            );

            if (mediaCheck.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Media not found or does not belong to this post'
                });
            }

            // Check if already viewed
            const [existing] = await connection.query(
                'SELECT id FROM post_media_views WHERE post_id = ? AND media_id = ? AND user_id = ?',
                [post_id, media_id, userId]
            );

            if (existing.length > 0) {
                return res.status(200).json({
                    success: true,
                    message: 'Already viewed this media'
                });
            }

            // Insert new view
            await connection.query(
                'INSERT INTO post_media_views (post_id, media_id, user_id) VALUES (?, ?, ?)',
                [post_id, media_id, userId]
            );

            res.status(200).json({
                success: true,
                message: 'Media view recorded successfully'
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Record media view error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
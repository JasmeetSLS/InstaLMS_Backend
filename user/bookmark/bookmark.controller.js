const { pool } = require('../../config/db');

// Add bookmark to a post
exports.addBookmark = async (req, res) => {
    try {
        const { post_id } = req.params;
        const userId = req.user.userId; // From authentication token

        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if post exists and is active
            const [posts] = await connection.query(
                'SELECT id, status FROM posts WHERE id = ? AND status = "active"',
                [post_id]
            );

            if (posts.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Post not found or inactive'
                });
            }

            // Check if already bookmarked
            const [existingBookmark] = await connection.query(
                'SELECT id FROM post_bookmarks WHERE post_id = ? AND user_id = ?',
                [post_id, userId]
            );

            if (existingBookmark.length > 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Post already bookmarked'
                });
            }

            // Insert bookmark
            await connection.query(
                'INSERT INTO post_bookmarks (post_id, user_id) VALUES (?, ?)',
                [post_id, userId]
            );

            res.status(200).json({
                success: true,
                message: 'Post bookmarked successfully',
                data: {
                    post_id: parseInt(post_id),
                    user_id: userId,
                    bookmarked_at: new Date().toISOString()
                }
            });

        } catch (error) {
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Add bookmark error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};

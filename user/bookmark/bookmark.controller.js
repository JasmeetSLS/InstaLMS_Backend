const { pool } = require('../../config/db');

// Add or Remove bookmark from a post
exports.toggleBookmark = async (req, res) => {
    try {
        const { post_id } = req.query; 
        const { bookmark_status } = req.body; 
        const userId = req.user.userId; 

        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required'
            });
        }

        if (bookmark_status === undefined) {
            return res.status(400).json({
                success: false,
                error: 'bookmark_status is required (1 for add, 0 for remove)'
            });
        }

        if (bookmark_status !== 0 && bookmark_status !== 1) {
            return res.status(400).json({
                success: false,
                error: 'bookmark_status must be 0 or 1'
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

            if (bookmark_status === 1) {
                // ADD BOOKMARK operation
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

            } else if (bookmark_status === 0) {
                // REMOVE BOOKMARK operation
                if (existingBookmark.length === 0) {
                    return res.status(400).json({
                        success: false,
                        error: 'Post not bookmarked yet'
                    });
                }

                // Remove bookmark
                await connection.query(
                    'DELETE FROM post_bookmarks WHERE post_id = ? AND user_id = ?',
                    [post_id, userId]
                );
            }

            const message = bookmark_status === 1 ? 'Post bookmarked successfully' : 'Post bookmark removed successfully';
            
            res.status(200).json({
                success: true,
                message: message,
                data: {
                    post_id: parseInt(post_id),
                    user_id: userId,
                    bookmark_status: bookmark_status
                }
            });

        } catch (error) {
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Toggle bookmark error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
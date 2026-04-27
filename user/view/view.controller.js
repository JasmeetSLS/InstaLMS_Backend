const { pool } = require('../../config/db');

// Record a post view (when user opens/view a post)
exports.recordPostView = async (req, res) => {
    try {
        // Get post_id from query parameters
        const { post_id } = req.query;
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

            await connection.beginTransaction();

            // Check if user has already viewed this post
            const [existingView] = await connection.query(
                'SELECT id, viewed_at FROM post_views WHERE post_id = ? AND user_id = ?',
                [post_id, userId]
            );

            if (existingView.length === 0) {
                // First time view - insert new record
                await connection.query(
                    'INSERT INTO post_views (post_id, user_id) VALUES (?, ?)',
                    [post_id, userId]
                );
                
                // Increment views count
                await connection.query(
                    'UPDATE posts SET views_count = views_count + 1 WHERE id = ?',
                    [post_id]
                );
            } else {
                // Update existing view timestamp
                await connection.query(
                    'UPDATE post_views SET viewed_at = CURRENT_TIMESTAMP WHERE post_id = ? AND user_id = ?',
                    [post_id, userId]
                );
            }

            await connection.commit();

            // Get updated view count
            const [updatedPost] = await connection.query(
                'SELECT views_count FROM posts WHERE id = ?',
                [post_id]
            );

            res.status(200).json({
                success: true,
                message: 'Post view recorded',
                data: {
                    post_id: parseInt(post_id),
                    user_id: userId,
                    views_count: updatedPost[0].views_count,
                    viewed_at: new Date().toISOString()
                }
            });

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Record post view error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
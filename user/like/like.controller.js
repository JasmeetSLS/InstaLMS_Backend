const { pool } = require('../../config/db');

// Like a post
exports.likePost = async (req, res) => {
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

            // Check if already liked
            const [existingLike] = await connection.query(
                'SELECT id FROM post_likes WHERE post_id = ? AND user_id = ?',
                [post_id, userId]
            );

            if (existingLike.length > 0) {
                return res.status(400).json({
                    success: false,
                    error: 'You have already liked this post'
                });
            }

            await connection.beginTransaction();

            // Insert like record
            await connection.query(
                'INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)',
                [post_id, userId]
            );

            // Update likes count in posts table
            await connection.query(
                'UPDATE posts SET likes_count = likes_count + 1 WHERE id = ?',
                [post_id]
            );

            await connection.commit();

            // Get updated like count
            const [updatedPost] = await connection.query(
                'SELECT likes_count FROM posts WHERE id = ?',
                [post_id]
            );

            res.status(200).json({
                success: true,
                message: 'Post liked successfully',
                data: {
                    post_id: parseInt(post_id),
                    user_id: userId,
                    likes_count: updatedPost[0].likes_count
                }
            });

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Like post error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};

const { pool } = require('../../config/db');

// Like or Unlike a post
exports.likePost = async (req, res) => {
    try {
        const { post_id, like_status } = req.query; // Changed: both from query params
        const userId = req.user.userId; 

        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required'
            });
        }

        if (like_status === undefined) {
            return res.status(400).json({
                success: false,
                error: 'like_status is required (1 for like, 0 for unlike)'
            });
        }

        if (like_status !== '0' && like_status !== '1') {
            return res.status(400).json({
                success: false,
                error: 'like_status must be 0 or 1'
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

            await connection.beginTransaction();

            if (like_status === '1') {
                // LIKE operation
                if (existingLike.length > 0) {
                    await connection.rollback();
                    return res.status(400).json({
                        success: false,
                        error: 'You have already liked this post'
                    });
                }

                // Insert like record
                await connection.query(
                    'INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)',
                    [post_id, userId]
                );

                // Update likes count in posts table (increment)
                await connection.query(
                    'UPDATE posts SET likes_count = likes_count + 1 WHERE id = ?',
                    [post_id]
                );

            } else if (like_status === '0') {
                // UNLIKE operation
                if (existingLike.length === 0) {
                    await connection.rollback();
                    return res.status(400).json({
                        success: false,
                        error: 'You have not liked this post yet'
                    });
                }

                // Remove like record
                await connection.query(
                    'DELETE FROM post_likes WHERE post_id = ? AND user_id = ?',
                    [post_id, userId]
                );

                // Update likes count in posts table (decrement)
                await connection.query(
                    'UPDATE posts SET likes_count = likes_count - 1 WHERE id = ?',
                    [post_id]
                );
            }

            await connection.commit();

            // Get updated like count
            const [updatedPost] = await connection.query(
                'SELECT likes_count FROM posts WHERE id = ?',
                [post_id]
            );

            const message = like_status === '1' ? 'Post liked successfully' : 'Post unliked successfully';
            
            res.status(200).json({
                success: true,
                message: message,
                data: {
                    post_id: parseInt(post_id),
                    user_id: userId,
                    like_status: parseInt(like_status),
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
        console.error('Like/Unlike post error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
const { pool } = require('../../config/db');

// Share a post with another user (allow multiple shares)
exports.sharePost = async (req, res) => {
    try {
        const { post_id, share_id } = req.query;
        const user_id = req.user.userId;

        // Validation
        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required in query params'
            });
        }

        if (!share_id) {
            return res.status(400).json({
                success: false,
                error: 'Share ID (user ID to share with) is required in query params'
            });
        }

        // Check if trying to share with self
        if (parseInt(share_id) === user_id) {
            return res.status(400).json({
                success: false,
                error: 'You cannot share a post with yourself'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if post exists and is active
            const [posts] = await connection.query(
                'SELECT id FROM posts WHERE id = ? AND status = "active"',
                [post_id]
            );

            if (posts.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Post not found or inactive'
                });
            }

            // Check if user to share with exists and is active
            const [users] = await connection.query(
                'SELECT id FROM users WHERE id = ? AND status = "active"',
                [share_id]
            );

            if (users.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'User not found or inactive'
                });
            }

            await connection.beginTransaction();

            // Insert share record
            const [shareResult] = await connection.query(
                'INSERT INTO post_shares (post_id, user_id, share_id, status) VALUES (?, ?, ?, ?)',
                [post_id, user_id, share_id, 'active']
            );

            // Update shares count in posts table
            await connection.query(
                'UPDATE posts SET shares_count = shares_count + 1 WHERE id = ?',
                [post_id]
            );

            await connection.commit();

            res.status(201).json({
                success: true,
                message: 'Post shared successfully',
                data: {
                    post_id: parseInt(post_id),
                    user_id: user_id,
                    share_id: parseInt(share_id)
                }
            });

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Share post error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
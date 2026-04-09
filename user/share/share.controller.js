const { pool } = require('../../config/db');

// Share a post with another user (allow multiple shares)
exports.sharePost = async (req, res) => {
    try {
        const { post_id, share_id } = req.params;
        const user_id = req.user.userId;

        // Validation
        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required'
            });
        }

        if (!share_id) {
            return res.status(400).json({
                success: false,
                error: 'Share ID (user ID to share with) is required'
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
                'SELECT id, title, status FROM posts WHERE id = ? AND status = "active"',
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
                'SELECT id, name, email, status FROM users WHERE id = ? AND status = "active"',
                [share_id]
            );

            if (users.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'User not found or inactive'
                });
            }

            await connection.beginTransaction();

            // Insert share record (allow duplicate shares)
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

            // Get share details with user information
            const [shareDetails] = await connection.query(
                `SELECT ps.id, ps.post_id, ps.user_id, ps.share_id, ps.created_at,
                        p.title as post_title,
                        shared_by.id as shared_by_id, shared_by.name as shared_by_name, 
                        shared_by.email as shared_by_email, shared_by.profile_url as shared_by_profile,
                        shared_with.id as shared_with_id, shared_with.name as shared_with_name,
                        shared_with.email as shared_with_email, shared_with.profile_url as shared_with_profile
                 FROM post_shares ps
                 JOIN posts p ON ps.post_id = p.id
                 JOIN users shared_by ON ps.user_id = shared_by.id
                 JOIN users shared_with ON ps.share_id = shared_with.id
                 WHERE ps.id = ?`,
                [shareResult.insertId]
            );

            res.status(201).json({
                success: true,
                message: 'Post shared successfully',
                data: {
                    share: shareDetails[0],
                    post_id: parseInt(post_id),
                    shared_by_user_id: user_id,
                    shared_with_user_id: parseInt(share_id),
                    total_shares_count: shareDetails[0] ? 1 : 0 // You can query actual count
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

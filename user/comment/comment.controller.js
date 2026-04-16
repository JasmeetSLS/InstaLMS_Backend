const { pool } = require('../../config/db');

// Create a comment on a post
exports.createComment = async (req, res) => {
    try {
        const { post_id } = req.query; 
        const { comment_text } = req.body;
        const userId = req.user.userId; // From authentication token

        // Validation
        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required in query params'
            });
        }

        if (!comment_text || comment_text.trim() === '') {
            return res.status(400).json({
                success: false,
                error: 'Comment text is required'
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

            // Insert comment
            const [commentResult] = await connection.query(
                'INSERT INTO post_comments (post_id, user_id, comment_text, status) VALUES (?, ?, ?, ?)',
                [post_id, userId, comment_text.trim(), 'active']
            );

            // Update comments count in posts table
            await connection.query(
                'UPDATE posts SET comments_count = comments_count + 1 WHERE id = ?',
                [post_id]
            );

            await connection.commit();

            // Get the created comment with user details
            const [newComment] = await connection.query(
                `SELECT pc.id, pc.comment_text, pc.status, pc.created_at,
                        u.id as user_id, u.name, u.email, u.employee_id, u.profile_url
                 FROM post_comments pc
                 JOIN users u ON pc.user_id = u.id
                 WHERE pc.id = ?`,
                [commentResult.insertId]
            );

            res.status(201).json({
                success: true,
                message: 'Comment added successfully',
                data: {
                    comment: newComment[0],
                    post_id: parseInt(post_id),
                    user_id: userId
                }
            });

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create comment error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
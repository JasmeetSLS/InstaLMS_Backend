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
exports.getSharedPostsToUser = async (req, res) => {
    try {
        const userId = req.user.userId; 
        const connection = await pool.getConnection();

        try {
            // ✅ MAIN QUERY with quiz completion
            const [sharedPosts] = await connection.query(
                `SELECT 
                    p.*, 
                    c.name as category_name,
                    ps.created_at as shared_at,
                    ps.user_id as shared_by_user_id,
                    u.name as shared_by_name,
                    u.email as shared_by_email,
                    u.employee_id as shared_by_employee_id,
                    u.profile_url as shared_by_profile_url,
                    COALESCE(pl.id IS NOT NULL, 0) as is_liked,
                    COALESCE(pb.id IS NOT NULL, 0) as is_bookmarked,
                    COALESCE(pv.id IS NOT NULL, 0) as is_viewed,
                    COALESCE(qc.id IS NOT NULL, 0) as quiz_completed,
                    qc.score as quiz_score
                 FROM post_shares ps
                 INNER JOIN posts p ON ps.post_id = p.id
                 INNER JOIN categories c ON p.category_id = c.id
                 INNER JOIN users u ON ps.user_id = u.id
                 LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
                 LEFT JOIN post_bookmarks pb ON p.id = pb.post_id AND pb.user_id = ?
                 LEFT JOIN post_views pv ON p.id = pv.post_id AND pv.user_id = ?
                 LEFT JOIN user_quiz_completion qc ON p.id = qc.post_id AND qc.user_id = ?
                 WHERE ps.share_id = ? 
                 AND ps.status = 'active'
                 AND p.status = 'active'
                 ORDER BY ps.created_at DESC`,
                [userId, userId, userId, userId, userId]
            );

            const postIds = sharedPosts.map(p => p.id);

            let mediaMap = {};
            let commentMap = {};

            if (postIds.length > 0) {
                // ✅ MEDIA (1 query)
                const [allMedia] = await connection.query(
                    `SELECT id, post_id, media_type, media_url, thumbnail_url
                     FROM post_media
                     WHERE post_id IN (?)`,
                    [postIds]
                );

                allMedia.forEach(m => {
                    if (!mediaMap[m.post_id]) mediaMap[m.post_id] = [];
                    mediaMap[m.post_id].push(m);
                });

                // ✅ COMMENTS (1 query)
                const [allComments] = await connection.query(
                    `SELECT 
                        pc.id, pc.post_id, pc.comment_text, pc.created_at,
                        u.id as user_id, u.name, u.email, u.employee_id, u.profile_url,
                        CASE WHEN u.id = ? THEN 1 ELSE 0 END as is_login_user
                     FROM post_comments pc
                     JOIN users u ON pc.user_id = u.id
                     WHERE pc.post_id IN (?) 
                     AND pc.status = 'active'
                     ORDER BY pc.created_at DESC`,
                    [userId, postIds]
                );

                allComments.forEach(c => {
                    if (!commentMap[c.post_id]) commentMap[c.post_id] = [];
                    commentMap[c.post_id].push(c);
                });
            }

            // ✅ Attach media & comments
            sharedPosts.forEach(post => {
                post.media = mediaMap[post.id] || [];
                post.comments = commentMap[post.id] || [];
                post.comments_count = post.comments.length;
            });

            // ✅ GROUPING
            const usersMap = {};

            sharedPosts.forEach(post => {
                const uid = post.shared_by_user_id;

                if (!usersMap[uid]) {
                    usersMap[uid] = {
                        shared_by_user_id: uid,
                        shared_by_name: post.shared_by_name,
                        shared_by_email: post.shared_by_email,
                        shared_by_employee_id: post.shared_by_employee_id,
                        shared_by_profile_url: post.shared_by_profile_url,
                        posts: []
                    };
                }

                // Remove user fields from post
                const { 
                    shared_by_name, 
                    shared_by_email, 
                    shared_by_employee_id, 
                    shared_by_profile_url,
                    ...postData 
                } = post;

                usersMap[uid].posts.push(postData);
            });

            res.status(200).json({
                success: true,
                data: {
                    users: Object.values(usersMap)
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get shared posts error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
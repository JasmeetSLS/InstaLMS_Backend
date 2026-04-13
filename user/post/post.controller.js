const { pool } = require('../../config/db');

exports.getPostsByCategory = async (req, res) => {
    try {
        const { limit = 10, category_id } = req.query; // category_id from query params
        const userId = req.user.userId;

        if (!category_id) {
            return res.status(400).json({
                success: false,
                error: 'Category ID is required in query params'
            });
        }

        const connection = await pool.getConnection();

        try {
            let categoryFilter = '';
            let queryParams = [userId, userId, userId];
            let categoryInfo = null;

            // If category_id is 1, show all posts (no category filter)
            if (category_id === '1') {
                // Get category name from database
                const [categories] = await connection.query(
                    'SELECT id, name FROM categories WHERE id = ? AND status = "active"',
                    [category_id]
                );
                categoryInfo = categories[0];
                categoryFilter = ''; // No category filter
                // Don't add category_id to queryParams
            } else {
                // Check if category exists and is active
                const [categories] = await connection.query(
                    'SELECT id, name, status FROM categories WHERE id = ? AND status = "active"',
                    [category_id]
                );

                if (categories.length === 0) {
                    return res.status(404).json({
                        success: false,
                        error: 'Category not found or inactive'
                    });
                }
                categoryInfo = categories[0];
                categoryFilter = 'AND p.category_id = ?';
                queryParams.push(category_id);
            }

            queryParams.push(parseInt(limit));

            // Get posts ordered by id ASC with limit
            const [posts] = await connection.query(
                `SELECT p.*, 
                        c.name as category_name,
                        COALESCE(pl.id IS NOT NULL, 0) as is_liked,
                        COALESCE(pb.id IS NOT NULL, 0) as is_bookmarked,
                        COALESCE(pv.id IS NOT NULL, 0) as is_viewed
                 FROM posts p
                 LEFT JOIN categories c ON p.category_id = c.id
                 LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
                 LEFT JOIN post_bookmarks pb ON p.id = pb.post_id AND pb.user_id = ?
                 LEFT JOIN post_views pv ON p.id = pv.post_id AND pv.user_id = ?
                 WHERE p.status = 'active' ${categoryFilter}
                 ORDER BY p.id ASC
                 LIMIT ?`,
                queryParams
            );

            // Get media and comments for each post
            for (let post of posts) {
                // Get media
                const [media] = await connection.query(
                    `SELECT id, media_type, media_url, thumbnail_url 
                     FROM post_media 
                     WHERE post_id = ? 
                     ORDER BY id ASC`,
                    [post.id]
                );
                post.media = media;

                // Get comments with user details (including login user identification)
                const [comments] = await connection.query(
                    `SELECT pc.id, pc.comment_text, pc.created_at,
                            u.id as user_id, u.name, u.email, u.employee_id, u.profile_url,
                            CASE WHEN u.id = ? THEN 1 ELSE 0 END as is_login_user
                     FROM post_comments pc
                     JOIN users u ON pc.user_id = u.id
                     WHERE pc.post_id = ? AND pc.status = 'active'
                     ORDER BY pc.created_at DESC
                     LIMIT 10`,
                    [userId, post.id]
                );
                post.comments = comments;
                post.comments_count = comments.length;
            }

            res.status(200).json({
                success: true,
                data: {
                    category: {
                        id: categoryInfo.id,
                        name: categoryInfo.name
                    },
                    posts: posts,
                    count: posts.length
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get posts by category error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
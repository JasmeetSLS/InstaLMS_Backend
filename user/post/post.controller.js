const { pool } = require('../../config/db');

// Get posts by category ID (with user authentication)
exports.getPostsByCategory = async (req, res) => {
    try {
        const { category_id } = req.params;
        const userId = req.user.userId;
        const { limit = 10 } = req.query;

        if (!category_id) {
            return res.status(400).json({
                success: false,
                error: 'Category ID is required'
            });
        }

        const connection = await pool.getConnection();

        try {
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
                 WHERE p.category_id = ? AND p.status = 'active'
                 ORDER BY p.id ASC
                 LIMIT ?`,
                [userId, userId, userId, category_id, parseInt(limit)]
            );

            // Get media for each post
            for (let post of posts) {
                const [media] = await connection.query(
                    `SELECT id, media_type, media_url, thumbnail_url 
                     FROM post_media 
                     WHERE post_id = ? 
                     ORDER BY id ASC`,
                    [post.id]
                );
                post.media = media;
            }

            res.status(200).json({
                success: true,
                data: {
                    category: {
                        id: categories[0].id,
                        name: categories[0].name
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
const { pool } = require('../../config/db');

exports.getPostsByCategory = async (req, res) => {
    try {
        const { 
            limit = 10, 
            page = 1,
            category_id 
        } = req.query;
        
        const userId = req.user.userId;
        const userRoleId = req.user.role_id;
        
        // Calculate offset for pagination
        const parsedLimit = parseInt(limit);
        const parsedPage = parseInt(page);
        const offset = (parsedPage - 1) * parsedLimit;

        if (!category_id) {
            return res.status(400).json({
                success: false,
                error: 'Category ID is required in query params'
            });
        }

        const connection = await pool.getConnection();

        try {
            let categoryFilter = '';
            let queryParams = [userId, userId, userId, userId, userId, userRoleId];

            if (category_id === '1') {
                categoryFilter = '';
            } else {
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
                categoryFilter = 'AND p.category_id = ?';
                queryParams.push(category_id);
            }

            // Clone params for count query (without limit/offset)
            let countParams = [...queryParams];
            
            // Add limit and offset for pagination
            queryParams.push(parsedLimit, offset);

            // Get total count for pagination metadata
            const [countResult] = await connection.query(
                `SELECT COUNT(*) as total 
                 FROM posts p
                 WHERE p.status = 'active' 
                 AND p.role_id = ?  
                 AND p.my_course = 0
                 ${categoryFilter}`,
                countParams.slice(5) // Remove user-specific params for count
            );
            
            const totalItems = countResult[0].total;
            const totalPages = Math.ceil(totalItems / parsedLimit);

            // Get paginated posts
            const [posts] = await connection.query(
                `SELECT p.*, 
                        c.name as category_name,
                        p.thumbnail_type,  
                        COALESCE(pl.id IS NOT NULL, 0) as is_liked,
                        COALESCE(pb.id IS NOT NULL, 0) as is_bookmarked,
                        COALESCE(pv.id IS NOT NULL, 0) as is_viewed,
                        COALESCE(qc.id IS NOT NULL, 0) as quiz_completed,
                        qc.score as quiz_score,
                        COALESCE(ump.view_percentage, 0) as media_view_percentage
                 FROM posts p
                 LEFT JOIN categories c ON p.category_id = c.id
                 LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
                 LEFT JOIN post_bookmarks pb ON p.id = pb.post_id AND pb.user_id = ?
                 LEFT JOIN post_views pv ON p.id = pv.post_id AND pv.user_id = ?
                 LEFT JOIN user_quiz_completion qc ON p.id = qc.post_id AND qc.user_id = ?
                 LEFT JOIN user_media_progress ump ON p.id = ump.post_id AND ump.user_id = ?
                 WHERE p.status = 'active' 
                 AND p.role_id = ?  
                 AND p.my_course = 0
                 ${categoryFilter}
                 ORDER BY p.id ASC
                 LIMIT ? OFFSET ?`,
                queryParams
            );

            for (let post of posts) {
                const [media] = await connection.query(
                    `SELECT id, media_type, media_url, thumbnail_url 
                     FROM post_media 
                     WHERE post_id = ? 
                     ORDER BY id ASC`,
                    [post.id]
                );
                
                post.media = media;

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
                    posts: posts,
                    pagination: {
                        current_page: parsedPage,
                        per_page: parsedLimit,
                        total_items: totalItems,
                        total_pages: totalPages,
                        has_next_page: parsedPage < totalPages,
                        has_previous_page: parsedPage > 1
                    }
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
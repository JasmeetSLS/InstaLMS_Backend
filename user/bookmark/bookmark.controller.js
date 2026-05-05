const { pool } = require('../../config/db');

// Add or Remove bookmark from a post
exports.toggleBookmark = async (req, res) => {
    try {
        const { post_id, bookmark_status } = req.query; // Changed: both from query params
        const userId = req.user.userId; 

        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required'
            });
        }

        if (bookmark_status === undefined) {
            return res.status(400).json({
                success: false,
                error: 'bookmark_status is required (1 for add, 0 for remove)'
            });
        }

        if (bookmark_status !== '0' && bookmark_status !== '1') {
            return res.status(400).json({
                success: false,
                error: 'bookmark_status must be 0 or 1'
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

            // Check if already bookmarked
            const [existingBookmark] = await connection.query(
                'SELECT id FROM post_bookmarks WHERE post_id = ? AND user_id = ?',
                [post_id, userId]
            );

            if (bookmark_status === '1') {
                // ADD BOOKMARK operation
                if (existingBookmark.length > 0) {
                    return res.status(400).json({
                        success: false,
                        error: 'Post already bookmarked'
                    });
                }

                // Insert bookmark
                await connection.query(
                    'INSERT INTO post_bookmarks (post_id, user_id) VALUES (?, ?)',
                    [post_id, userId]
                );

            } else if (bookmark_status === '0') {
                // REMOVE BOOKMARK operation
                if (existingBookmark.length === 0) {
                    return res.status(400).json({
                        success: false,
                        error: 'Post not bookmarked yet'
                    });
                }

                // Remove bookmark
                await connection.query(
                    'DELETE FROM post_bookmarks WHERE post_id = ? AND user_id = ?',
                    [post_id, userId]
                );
            }

            const message = bookmark_status === '1' ? 'Post bookmarked successfully' : 'Post bookmark removed successfully';
            
            res.status(200).json({
                success: true,
                message: message,
                data: {
                    post_id: parseInt(post_id),
                    user_id: userId,
                    bookmark_status: parseInt(bookmark_status)
                }
            });

        } catch (error) {
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Toggle bookmark error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
exports.getUserBookmarks = async (req, res) => {
    try {
        const userId = req.user.userId;
        
        const connection = await pool.getConnection();
        
        try {
            // Get bookmarked posts with all details including quiz completion
            const [bookmarkedPosts] = await connection.query(
                `SELECT 
                    p.*, 
                    c.name as category_name,
                    pb.created_at as bookmarked_at,
                    COALESCE(pl.id IS NOT NULL, 0) as is_liked,
                    COALESCE(pb2.id IS NOT NULL, 0) as is_bookmarked,
                    COALESCE(pv.id IS NOT NULL, 0) as is_viewed,
                    COALESCE(qc.id IS NOT NULL, 0) as quiz_completed,
                    qc.score as quiz_score
                 FROM post_bookmarks pb
                 INNER JOIN posts p ON pb.post_id = p.id
                 INNER JOIN categories c ON p.category_id = c.id
                 LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
                 LEFT JOIN post_bookmarks pb2 ON p.id = pb2.post_id AND pb2.user_id = ?
                 LEFT JOIN post_views pv ON p.id = pv.post_id AND pv.user_id = ?
                 LEFT JOIN user_quiz_completion qc ON p.id = qc.post_id AND qc.user_id = ?
                 WHERE pb.user_id = ? AND p.status = 'active'
                 ORDER BY pb.created_at DESC`,
                [userId, userId, userId, userId, userId]
            );
            
            // Get media and comments for each post
            for (let post of bookmarkedPosts) {
                // Get media
                const [media] = await connection.query(
                    `SELECT id, media_type, media_url, thumbnail_url 
                     FROM post_media 
                     WHERE post_id = ? 
                     ORDER BY id ASC`,
                    [post.id]
                );
                
                // Calculate media viewed percentage
                const [viewedCount] = await connection.query(
                    `SELECT COUNT(*) as viewed FROM post_media_views 
                     WHERE post_id = ? AND user_id = ?`,
                    [post.id, userId]
                );
                post.media_viewed_percentage = media.length > 0 
                    ? Math.round((viewedCount[0].viewed / media.length) * 100) 
                    : 100;
                
                post.media = media;
                
                // Get comments with user details (limit to recent 10)
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
            }
            
            res.status(200).json({
                success: true,
                data: {
                    posts: bookmarkedPosts,
                    count: bookmarkedPosts.length
                }
            });
            
        } finally {
            connection.release();
        }
        
    } catch (error) {
        console.error('Get user bookmarks error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
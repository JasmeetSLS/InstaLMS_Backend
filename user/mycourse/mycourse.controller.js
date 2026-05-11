const { pool } = require('../../config/db');

exports.getMyCourses = async (req, res) => {
    try {
        const userId = req.user.userId;
        const userRoleId = req.user.role_id;

        const connection = await pool.getConnection();

        try {
            // Get all posts for live_tasks (my_course = 1)
            const [liveTasks] = await connection.query(
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
                 AND p.my_course = 1
                 ORDER BY p.id ASC`,
                [userId, userId, userId, userId, userId, userRoleId]
            );

            // Get pending tasks (my_course = 1 AND media_percentage between 0.00 and 100.00)
            const [pendingTasks] = await connection.query(
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
                 AND p.my_course = 1
                 AND COALESCE(ump.view_percentage, 0) > 0.00
                 AND COALESCE(ump.view_percentage, 0) < 100.00
                 ORDER BY p.id ASC`,
                [userId, userId, userId, userId, userId, userRoleId]
            );

            // Add media and comments to live tasks
            for (let post of liveTasks) {
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

            // Add media and comments to pending tasks
            for (let post of pendingTasks) {
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
                live_tasks: liveTasks,
                pending_tasks: pendingTasks
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get my courses error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
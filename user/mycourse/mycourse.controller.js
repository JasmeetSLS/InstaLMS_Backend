const { pool } = require('../../config/db');

exports.getMyCourses = async (req, res) => {
    try {
        const userId = req.user.userId;
        
        const connection = await pool.getConnection();
        
        try {
            // Get all courses (posts with quiz_active = 1) with all details
            const [courses] = await connection.query(
                `SELECT 
                    p.*, 
                    c.name as category_name,
                    COALESCE(pl.id IS NOT NULL, 0) as is_liked,
                    COALESCE(pb.id IS NOT NULL, 0) as is_bookmarked,
                    COALESCE(pv.id IS NOT NULL, 0) as is_viewed,
                    COALESCE(qc.id IS NOT NULL, 0) as quiz_completed,
                    qc.score as quiz_score
                 FROM posts p
                 INNER JOIN categories c ON p.category_id = c.id
                 LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
                 LEFT JOIN post_bookmarks pb ON p.id = pb.post_id AND pb.user_id = ?
                 LEFT JOIN post_views pv ON p.id = pv.post_id AND pv.user_id = ?
                 LEFT JOIN user_quiz_completion qc ON p.id = qc.post_id AND qc.user_id = ?
                 WHERE p.status = 'active' AND p.quiz_active = 1
                 ORDER BY p.created_at DESC`,
                [userId, userId, userId, userId]
            );
            
            // Get media and comments for each course
            for (let course of courses) {
                // Get media
                const [media] = await connection.query(
                    `SELECT id, media_type, media_url, thumbnail_url 
                     FROM post_media 
                     WHERE post_id = ? 
                     ORDER BY id ASC`,
                    [course.id]
                );
                
                // Calculate media viewed percentage
                const totalMedia = media.length;
                const [viewedCount] = await connection.query(
                    `SELECT COUNT(*) as viewed FROM post_media_views 
                     WHERE post_id = ? AND user_id = ?`,
                    [course.id, userId]
                );
                course.media_viewed_percentage = totalMedia > 0 
                    ? Math.round((viewedCount[0].viewed / totalMedia) * 100) 
                    : 0;
                
                // Add media array after percentage calculation
                course.media = media;
                
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
                    [userId, course.id]
                );
                course.comments = comments;
                course.comments_count = comments.length;
            }
            
            res.status(200).json({
                success: true,
                data: {
                    courses: courses,
                    count: courses.length
                }
            });
            
        } finally {
            connection.release();
        }
        
    } catch (error) {
        console.error('Get user courses error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
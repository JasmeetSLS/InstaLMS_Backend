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
                // Get media with ALL data from user_media_tracking
                const [media] = await connection.query(
                    `SELECT pm.id, pm.media_type, pm.media_url, pm.thumbnail_url,
                            COALESCE(umt.id, 0) as tracking_id,
                            umt.user_id as tracking_user_id,
                            umt.viewed_at,
                            umt.total_minutes,
                            umt.viewed_minutes,
                            umt.total_slides,
                            umt.viewed_slides,
                            umt.wbt_json,
                            COALESCE(umt.percentage, 0) as user_percentage,
                            COALESCE(umt.completed, 0) as user_completed,
                            umt.created_at as tracking_created_at,
                            umt.updated_at as tracking_updated_at
                     FROM post_media pm
                     LEFT JOIN user_media_tracking umt ON pm.id = umt.media_id AND umt.user_id = ?
                     WHERE pm.post_id = ? 
                     ORDER BY pm.id ASC`,
                    [userId, post.id]
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
exports.getCurriculumById = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.userId;

        if (!id) {
            return res.status(400).json({ success: false, error: 'Curriculum ID is required' });
        }

        const connection = await pool.getConnection();

        try {
            // 1. Fetch curriculum details
            const [curriculum] = await connection.query(
                `SELECT c.*, r.name as role_name
                 FROM curriculums c
                 JOIN roles r ON c.role_id = r.id
                 WHERE c.id = ? AND c.status = 'active'`,
                [id]
            );

            if (curriculum.length === 0) {
                return res.status(404).json({ success: false, error: 'Curriculum not found or inactive' });
            }

            const curriculumData = curriculum[0];

            // 2. Fetch all posts for this curriculum (with view status)
            const [posts] = await connection.query(
                `SELECT p.*, 
                        cp.level,
                        cp.sort_order,
                        c.name as category_name,
                        COALESCE(pl.id IS NOT NULL, 0) as is_liked,
                        COALESCE(pb.id IS NOT NULL, 0) as is_bookmarked,
                        COALESCE(pv.id IS NOT NULL, 0) as is_viewed,
                        COALESCE(qc.id IS NOT NULL, 0) as quiz_completed,
                        qc.score as quiz_score,
                        COALESCE(ump.view_percentage, 0) as media_view_percentage
                 FROM curriculum_posts cp
                 JOIN posts p ON cp.post_id = p.id
                 LEFT JOIN categories c ON p.category_id = c.id
                 LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
                 LEFT JOIN post_bookmarks pb ON p.id = pb.post_id AND pb.user_id = ?
                 LEFT JOIN post_views pv ON p.id = pv.post_id AND pv.user_id = ?
                 LEFT JOIN user_quiz_completion qc ON p.id = qc.post_id AND qc.user_id = ?
                 LEFT JOIN user_media_progress ump ON p.id = ump.post_id AND ump.user_id = ?
                 WHERE cp.curriculum_id = ?
                   AND p.status = 'active'
                 ORDER BY cp.level ASC, cp.sort_order ASC, p.id ASC`,
                [userId, userId, userId, userId, userId, id]
            );

            // 3. For each post, fetch media and comments (unchanged)
            for (let post of posts) {
                const [media] = await connection.query(
                    `SELECT pm.id, pm.media_type, pm.media_url, pm.thumbnail_url,
                            COALESCE(umt.id, 0) as tracking_id,
                            umt.user_id as tracking_user_id,
                            umt.viewed_at,
                            umt.total_minutes,
                            umt.viewed_minutes,
                            umt.total_slides,
                            umt.viewed_slides,
                            umt.wbt_json,
                            COALESCE(umt.percentage, 0) as user_percentage,
                            COALESCE(umt.completed, 0) as user_completed,
                            umt.created_at as tracking_created_at,
                            umt.updated_at as tracking_updated_at
                     FROM post_media pm
                     LEFT JOIN user_media_tracking umt ON pm.id = umt.media_id AND umt.user_id = ?
                     WHERE pm.post_id = ? 
                     ORDER BY pm.id ASC`,
                    [userId, post.id]
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

            // 4. Group posts by level and compute stats
            const levels = {
                '1': { posts: [] },
                '2': { posts: [] },
                '3': { posts: [] }
            };

            posts.forEach(post => {
                const levelKey = String(post.level);
                if (levels[levelKey]) {
                    levels[levelKey].posts.push(post);
                }
            });

            // Compute total & viewed counts for each level
            const levelStats = {};
            for (const [levelKey, data] of Object.entries(levels)) {
                const total = data.posts.length;
                const viewed = data.posts.filter(p => p.is_viewed === 1).length;
                levelStats[levelKey] = { total, viewed };
            }

            // Determine unlocked status for each level
            const level1FullyViewed = levelStats['1'].total === 0 || levelStats['1'].viewed === levelStats['1'].total;
            const level2FullyViewed = levelStats['2'].total === 0 || levelStats['2'].viewed === levelStats['2'].total;

            // Level 1: always unlocked
            const level1Unlocked = true;
            // Level 2: unlocked if level 1 fully viewed
            const level2Unlocked = level1FullyViewed;
            // Level 3: unlocked if level 1 and level 2 both fully viewed
            const level3Unlocked = level1FullyViewed && level2FullyViewed;

const responseLevels = {
    '1': {
        unlocked: level1Unlocked,
        total_posts: levelStats['1'].total,
        viewed_posts: levelStats['1'].viewed,
        posts: level1Unlocked ? levels['1'].posts : []
    },
    '2': {
        unlocked: level2Unlocked,
        total_posts: levelStats['2'].total,
        viewed_posts: levelStats['2'].viewed,
        posts: level2Unlocked ? levels['2'].posts : []
    },
    '3': {
        unlocked: level3Unlocked,
        total_posts: levelStats['3'].total,
        viewed_posts: levelStats['3'].viewed,
        posts: level3Unlocked ? levels['3'].posts : []
    }
};

            // 5. Send response
            res.json({
                success: true,
                data: {
                    curriculum: curriculumData,
                    levels: responseLevels
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get curriculum error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

exports.getUserCurriculums = async (req, res) => {
    try {
        const userId = req.user.userId;
        const userRoleId = req.user.role_id;

        const connection = await pool.getConnection();
        try {
            const [curriculums] = await connection.query(
                `SELECT c.id, c.title, c.description, c.role_id, r.name as role_name, c.status
                 FROM curriculums c
                 JOIN roles r ON c.role_id = r.id
                 WHERE c.status = 'active' AND c.role_id = ?
                 ORDER BY c.id ASC`,
                [userRoleId]
            );

            res.json({ success: true, data: curriculums });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Get user curriculums error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};
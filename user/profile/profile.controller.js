const { pool } = require('../../config/db');

exports.getMyProfile = async (req, res) => {
    try {
        const userId = req.user.userId;
        
        const connection = await pool.getConnection();
        
        try {
            // Fetch user profile with dealer information
            const [users] = await connection.query(
                `SELECT 
                    u.id,
                    u.email,
                    u.employee_id,
                    u.name,
                    u.phone,
                    u.gender,
                    u.role_id,
                    r.name as role_name,
                    u.dealer_id,
                    u.profile_url,
                    u.status,
                    u.created_at,
                    u.updated_at,
                    d.dealer_code,
                    d.dealer_name,
                    d.dealer_location,
                    d.zone as dealer_zone,
                    d.status as dealer_status
                 FROM users u
                 LEFT JOIN roles r ON u.role_id = r.id
                 LEFT JOIN dealers d ON u.dealer_id = d.id
                 WHERE u.id = ? AND u.status = 'active'`,
                [userId]
            );
            
            if (users.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'User not found'
                });
            }
            
            const user = users[0];
            
            // Get category-wise posts with all details (matching bookmark API structure)
            const [categoryPosts] = await connection.query(
                `SELECT 
                    c.id as category_id,
                    c.name as category_name,
                    c.icon_url,
                    p.*,
                    pb.created_at as bookmarked_at,
                    COALESCE(pl.id IS NOT NULL, 0) as is_liked,
                    COALESCE(pb2.id IS NOT NULL, 0) as is_bookmarked,
                    COALESCE(pv.id IS NOT NULL, 0) as is_viewed,
                    COALESCE(qc.id IS NOT NULL, 0) as quiz_completed,
                    qc.score as quiz_score,
                    COALESCE(ump.view_percentage, 0) as media_view_percentage
                 FROM categories c
                 INNER JOIN posts p ON c.id = p.category_id 
                    AND p.status = 'active'
                    AND p.role_id = ?
                    AND p.my_course = 1
                 LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
                 LEFT JOIN post_bookmarks pb ON p.id = pb.post_id AND pb.user_id = ?
                 LEFT JOIN post_bookmarks pb2 ON p.id = pb2.post_id AND pb2.user_id = ?
                 LEFT JOIN post_views pv ON p.id = pv.post_id AND pv.user_id = ?
                 LEFT JOIN user_quiz_completion qc ON p.id = qc.post_id AND qc.user_id = ?
                 LEFT JOIN user_media_progress ump ON p.id = ump.post_id AND ump.user_id = ?
                 WHERE c.status = 'active' 
                 AND c.id BETWEEN 2 AND 5
                 ORDER BY c.id, p.created_at DESC`,
                [user.role_id, userId, userId, userId, userId, userId, userId]
            );
            
            // Group posts by category
            const categoriesMap = new Map();
            
            for (const post of categoryPosts) {
                if (!categoriesMap.has(post.category_id)) {
                    categoriesMap.set(post.category_id, {
                        category_id: post.category_id,
                        category_name: post.category_name,
                        icon_url: post.icon_url,
                        total_posts: 0,
                        completed_posts: 0,
                        completion_percentage: 0,
                        posts: []
                    });
                }
                
                const category = categoriesMap.get(post.category_id);
                
                // Calculate completion for this post
                const isCompleted = parseFloat(post.media_view_percentage) === 100;
                if (isCompleted) {
                    category.completed_posts++;
                }
                category.total_posts++;
                
                // Get media for this post (similar to bookmark API)
                const [media] = await connection.query(
                    `SELECT id, media_type, media_url, thumbnail_url 
                     FROM post_media 
                     WHERE post_id = ? 
                     ORDER BY id ASC`,
                    [post.id]
                );
                
                // Get comments for this post (similar to bookmark API)
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
                
                // Add post to category with complete details (matching bookmark structure)
                category.posts.push({
                    id: post.id,
                    category_id: post.category_id,
                    category_name: post.category_name,
                    title: post.title,
                    content: post.content,
                    hashtags: post.hashtags,
                    thumbnail_type: post.thumbnail_type,
                    quiz_active: post.quiz_active === 1,
                    my_course: post.my_course === 1,
                    likes_count: post.likes_count,
                    comments_count: post.comments_count,
                    views_count: post.views_count,
                    shares_count: post.shares_count,
                    status: post.status,
                    created_at: post.created_at,
                    updated_at: post.updated_at,
                    bookmarked_at: post.bookmarked_at,
                    is_liked: post.is_liked === 1,
                    is_bookmarked: post.is_bookmarked === 1,
                    is_viewed: post.is_viewed === 1,
                    quiz_completed: post.quiz_completed === 1,
                    quiz_score: post.quiz_score,
                    media_view_percentage: parseFloat(post.media_view_percentage) || 0,
                    media: media,
                    comments: comments
                });
            }
            
            // Calculate completion percentages and convert to array
            const categories = Array.from(categoriesMap.values()).map(cat => {
                cat.completion_percentage = cat.total_posts > 0 
                    ? parseFloat(((cat.completed_posts / cat.total_posts) * 100).toFixed(2))
                    : 0;
                return cat;
            });
            
            // Prepare response
            const responseData = {
                user: {
                    id: user.id,
                    email: user.email,
                    employee_id: user.employee_id,
                    name: user.name,
                    phone: user.phone,
                    gender: user.gender,
                    role_id: user.role_id,
                    role_name: user.role_name,
                    dealer_id: user.dealer_id,
                    profile_url: user.profile_url,
                    status: user.status,
                    created_at: user.created_at,
                    updated_at: user.updated_at,
                    dealer: user.dealer_id ? {
                        dealer_code: user.dealer_code,
                        dealer_name: user.dealer_name,
                        dealer_location: user.dealer_location,
                        zone: user.dealer_zone,
                        status: user.dealer_status
                    } : null
                },
                categories: categories
            };
            
            res.status(200).json({
                success: true,
                data: responseData
            });
            
        } finally {
            connection.release();
        }
        
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};


exports.getLeaderboard = async (req, res) => {
    try {
        const userId = req.user.userId;
        const connection = await pool.getConnection();

        try {
            // Get all users with IDs 1-12
            const [allUsers] = await connection.query(
                `SELECT 
                    u.id,
                    u.name,
                    u.profile_url,
                    u.employee_id,
                    u.email,
                    d.dealer_name as dealership,
                    d.dealer_location as city,
                    r.name as role
                FROM users u
                LEFT JOIN dealers d ON u.dealer_id = d.id
                LEFT JOIN roles r ON u.role_id = r.id
                WHERE u.id BETWEEN 1 AND 12 AND u.status = 'active'
                ORDER BY u.id ASC`,
                []
            );

            if (allUsers.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'No users found'
                });
            }

            // Helper function to shuffle array
            function shuffleArray(array) {
                for (let i = array.length - 1; i > 0; i--) {
                    const j = Math.floor(Math.random() * (i + 1));
                    [array[i], array[j]] = [array[j], array[i]];
                }
                return array;
            }

            // Helper function to get random completion time
            function getRandomCompletionTime() {
                const days = Math.floor(Math.random() * (12 - 2 + 1) + 2); // Random between 2-12 days
                return `${days} days`;
            }

            // Helper function to get random points
            function getRandomPoints() {
                return Math.floor(Math.random() * (100 - 70 + 1) + 70); // Random between 70-100
            }

            // Helper function to get random score
            function getRandomScore() {
                return Math.floor(Math.random() * (100 - 75 + 1) + 75); // Random between 75-100
            }

            // Helper function to get random quizzes taken
            function getRandomQuizzesTaken() {
                return Math.floor(Math.random() * (30 - 10 + 1) + 10); // Random between 10-30
            }

            // Helper function to get random certificates
            function getRandomCertificates() {
                return Math.floor(Math.random() * (20 - 5 + 1) + 5); // Random between 5-20
            }

            // Helper function to get random completion rate
            function getRandomCompletionRate() {
                const rate = Math.floor(Math.random() * (100 - 70 + 1) + 70); // Random between 70-100
                return `${rate}%`;
            }

            // Helper function to get random engagement score
            function getRandomEngagementScore() {
                return Math.floor(Math.random() * (100 - 70 + 1) + 70); // Random between 70-100
            }

            // Helper function to get random hours spent
            function getRandomHoursSpent() {
                return Math.floor(Math.random() * (150 - 60 + 1) + 60); // Random between 60-150
            }

            // Helper function to get random posts completed
            function getRandomPostsCompleted() {
                return Math.floor(Math.random() * (50 - 20 + 1) + 20); // Random between 20-50
            }

            // Prepare fastest completion leaderboard (all 12 users shuffled)
            let fastestCompletionUsers = [...allUsers];
            fastestCompletionUsers = shuffleArray(fastestCompletionUsers);
            const fastestCompletion = fastestCompletionUsers.map((user, index) => ({
                rank: index + 1,
                user_id: user.id,
                name: user.name,
                profile_url: user.profile_url || null,
                city: user.city || 'Not specified',
                dealership: user.dealership || 'Not assigned',
                role: user.role || 'Employee',
                completion_time: getRandomCompletionTime(),
                points: getRandomPoints()
            }));

            // Prepare highest scores leaderboard (all 12 users shuffled)
            let highestScoresUsers = [...allUsers];
            highestScoresUsers = shuffleArray(highestScoresUsers);
            const highestScores = highestScoresUsers.map((user, index) => ({
                rank: index + 1,
                user_id: user.id,
                name: user.name,
                profile_url: user.profile_url || null,
                city: user.city || 'Not specified',
                dealership: user.dealership || 'Not assigned',
                role: user.role || 'Employee',
                score: getRandomScore(),
                quizzes_taken: getRandomQuizzesTaken()
            }));

            // Prepare max certificates leaderboard (all 12 users shuffled)
            let maxCertificatesUsers = [...allUsers];
            maxCertificatesUsers = shuffleArray(maxCertificatesUsers);
            const maxCertificates = maxCertificatesUsers.map((user, index) => ({
                rank: index + 1,
                user_id: user.id,
                name: user.name,
                profile_url: user.profile_url || null,
                city: user.city || 'Not specified',
                dealership: user.dealership || 'Not assigned',
                role: user.role || 'Employee',
                certificates: getRandomCertificates(),
                completion_rate: getRandomCompletionRate()
            }));

            // Prepare highest engagement leaderboard (all 12 users shuffled)
            let highestEngagementUsers = [...allUsers];
            highestEngagementUsers = shuffleArray(highestEngagementUsers);
            const highestEngagement = highestEngagementUsers.map((user, index) => ({
                rank: index + 1,
                user_id: user.id,
                name: user.name,
                profile_url: user.profile_url || null,
                city: user.city || 'Not specified',
                dealership: user.dealership || 'Not assigned',
                role: user.role || 'Employee',
                engagement_score: getRandomEngagementScore(),
                hours_spent: getRandomHoursSpent(),
                posts_completed: getRandomPostsCompleted()
            }));

            res.status(200).json({
                success: true,
                data: {
                    fastest_completion: fastestCompletion,
                    highest_scores: highestScores,
                    max_certificates: maxCertificates,
                    highest_engagement: highestEngagement
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get leaderboard error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

exports.getScorecard = async (req, res) => {
    try {
        const userId = req.user.userId;
        const connection = await pool.getConnection();

        try {
            // Get user details
            const [users] = await connection.query(
                `SELECT id, name, email, employee_id, profile_url 
                 FROM users 
                 WHERE id = ? AND status = 'active'`,
                [userId]
            );

            const user = users[0] || {};

            // Static scorecard data
            const scorecardData = {
                learning_path_program: {
                    percentage: 68,
                    completed_courses: 13,
                    total_courses: 20,
                    status: "In Progress"
                },
                certificates: {
                    count: 2,
                    label: "Certificates Received",
                    recent_certificates: [
                        { name: "Sales Excellence Program", date: "2024-03-15" },
                        { name: "Product Knowledge Mastery", date: "2024-02-28" }
                    ]
                },
                assessment_attempted: {
                    percentage: 48,
                    completed_assessments: 9,
                    total_assessments: 20,
                    status: "Pending"
                },
                score: {
                    percentage: 52,
                    average_score: 52,
                    total_score: 520,
                    max_score: 1000,
                    grade: "C"
                },
                categories: [
                    {
                        name: "Brand",
                        assessments: [
                            { name: "Core Knowledge Assessment", score: 65 },
                            { name: "Practical Application Test", score: 58 },
                            { name: "Industry Standards Quiz", score: 72 }
                        ],
                        average_score: 65
                    },
                    {
                        name: "BAT",
                        assessments: [
                            { name: "Core Knowledge Assessment", score: 45 },
                            { name: "Practical Application Test", score: 52 },
                            { name: "Industry Standards Quiz", score: 48 }
                        ],
                        average_score: 48
                    },
                    {
                        name: "SOP",
                        assessments: [
                            { name: "Core Knowledge Assessment", score: 78 },
                            { name: "Practical Application Test", score: 82 },
                            { name: "Industry Standards Quiz", score: 75 }
                        ],
                        average_score: 78
                    },
                    {
                        name: "Product Knowledge",
                        assessments: [
                            { name: "Core Knowledge Assessment", score: 55 },
                            { name: "Practical Application Test", score: 60 },
                            { name: "Industry Standards Quiz", score: 58 }
                        ],
                        average_score: 58
                    }
                ],
                strengths: [
                    "High Aptitude",
                    "Foundational Knowledge",
                    "Practical Application"
                ],
                focus_area: [
                    "New Skills",
                    "Concept Mastery",
                    "Performance Gaps"
                ],
                recommendations: [
                    "Modules from digital library",
                    "Re-Attempted Courses",
                    "Re-Attempted Assessments"
                ]
            };

            res.status(200).json({
                success: true,
                data: {
                    user: {
                        id: user.id,
                        name: user.name,
                        email: user.email,
                        employee_id: user.employee_id,
                        profile_url: user.profile_url
                    },
                    scorecard: scorecardData
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get scorecard error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
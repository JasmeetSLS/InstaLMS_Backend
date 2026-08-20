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
        // Token already verified; userId is available (but we ignore it)
        const userId = req.user.userId;

        // === STATIC DATA (exact copy from your staticLeaderboardData) ===
        const staticData = {
            fastest_course_completion: [
                { rank: 1, user_id: 4, name: "Subhojit", photo: "/uploads/users/4/profile-1776246467383.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "5 days", points: 73, is_selected: false },
                { rank: 2, user_id: 2, name: "Neeraj Jain", photo: "/uploads/users/2/profile-1775713867244.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "5 days", points: 92, is_selected: false },
                { rank: 3, user_id: 7, name: "Dheeraj", photo: "/uploads/users/7/profile-1776246864430.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "3 days", points: 81, is_selected: false },
                { rank: 4, user_id: 5, name: "Pradeep Kumar", photo: "/uploads/users/5/profile-1776246576012.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "9 days", points: 99, is_selected: false },
                { rank: 5, user_id: 11, name: "Sudha Pawar", photo: "/uploads/users/11/profile-1778653157019.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "7 days", points: 92, is_selected: false },
                { rank: 6, user_id: 12, name: "Nagnath Pise", photo: "/uploads/users/12/profile-1778653233079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "11 days", points: 81, is_selected: false },
                { rank: 7, user_id: 3, name: "Ravi Pandey", photo: "/uploads/users/3/profile-1775713939921.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "11 days", points: 100, is_selected: false },
                { rank: 8, user_id: 1, name: "Keshav_Goyal", photo: "/uploads/users/1/profile-1775713806692.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "11 days", points: 90, is_selected: false },
                { rank: 9, user_id: 10, name: "Vinaya Prasad", photo: "/uploads/users/10/profile-1778653116674.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "11 days", points: 73, is_selected: false },
                { rank: 10, user_id: 6, name: "Anil Kumawat", photo: "/uploads/users/6/profile-1776246747079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "7 days", points: 92, is_selected: false },
                { rank: 11, user_id: 8, name: "Karthick", photo: "/uploads/users/8/profile-1778652931250.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "3 days", points: 70, is_selected: false },
                { rank: 12, user_id: 9, name: "SOHAIL KHAN", photo: "/uploads/users/9/profile-1778653072931.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", completion_time: "2 days", points: 98, is_selected: false }
            ],
            highest_quiz_scores: [
                { rank: 1, user_id: 9, name: "SOHAIL KHAN", photo: "/uploads/users/9/profile-1778653072931.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 83, quizzes_taken: 14, is_selected: false },
                { rank: 2, user_id: 3, name: "Ravi Pandey", photo: "/uploads/users/3/profile-1775713939921.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 77, quizzes_taken: 30, is_selected: false },
                { rank: 3, user_id: 7, name: "Dheeraj", photo: "/uploads/users/7/profile-1776246864430.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 78, quizzes_taken: 12, is_selected: false },
                { rank: 4, user_id: 4, name: "Subhojit", photo: "/uploads/users/4/profile-1776246467383.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 98, quizzes_taken: 14, is_selected: false },
                { rank: 5, user_id: 1, name: "Keshav_Goyal", photo: "/uploads/users/1/profile-1775713806692.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 84, quizzes_taken: 13, is_selected: false },
                { rank: 6, user_id: 11, name: "Sudha Pawar", photo: "/uploads/users/11/profile-1778653157019.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 77, quizzes_taken: 23, is_selected: false },
                { rank: 7, user_id: 8, name: "Karthick", photo: "/uploads/users/8/profile-1778652931250.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 77, quizzes_taken: 30, is_selected: false },
                { rank: 8, user_id: 5, name: "Pradeep Kumar", photo: "/uploads/users/5/profile-1776246576012.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 87, quizzes_taken: 23, is_selected: false },
                { rank: 9, user_id: 12, name: "Nagnath Pise", photo: "/uploads/users/12/profile-1778653233079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 96, quizzes_taken: 28, is_selected: false },
                { rank: 10, user_id: 10, name: "Vinaya Prasad", photo: "/uploads/users/10/profile-1778653116674.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 88, quizzes_taken: 22, is_selected: false },
                { rank: 11, user_id: 2, name: "Neeraj Jain", photo: "/uploads/users/2/profile-1775713867244.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 79, quizzes_taken: 23, is_selected: false },
                { rank: 12, user_id: 6, name: "Anil Kumawat", photo: "/uploads/users/6/profile-1776246747079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", score: 95, quizzes_taken: 29, is_selected: false }
            ],
            most_quizzes_completed: [
                { rank: 1, user_id: 10, name: "Vinaya Prasad", photo: "/uploads/users/10/profile-1778653116674.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 16, completion_rate: "94%", is_selected: false },
                { rank: 2, user_id: 9, name: "SOHAIL KHAN", photo: "/uploads/users/9/profile-1778653072931.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 18, completion_rate: "95%", is_selected: false },
                { rank: 3, user_id: 6, name: "Anil Kumawat", photo: "/uploads/users/6/profile-1776246747079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 15, completion_rate: "84%", is_selected: false },
                { rank: 4, user_id: 11, name: "Sudha Pawar", photo: "/uploads/users/11/profile-1778653157019.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 8, completion_rate: "97%", is_selected: false },
                { rank: 5, user_id: 12, name: "Nagnath Pise", photo: "/uploads/users/12/profile-1778653233079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 20, completion_rate: "73%", is_selected: false },
                { rank: 6, user_id: 4, name: "Subhojit", photo: "/uploads/users/4/profile-1776246467383.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 15, completion_rate: "73%", is_selected: false },
                { rank: 7, user_id: 2, name: "Neeraj Jain", photo: "/uploads/users/2/profile-1775713867244.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 12, completion_rate: "72%", is_selected: false },
                { rank: 8, user_id: 3, name: "Ravi Pandey", photo: "/uploads/users/3/profile-1775713939921.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 7, completion_rate: "75%", is_selected: false },
                { rank: 9, user_id: 5, name: "Pradeep Kumar", photo: "/uploads/users/5/profile-1776246576012.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 7, completion_rate: "86%", is_selected: false },
                { rank: 10, user_id: 8, name: "Karthick", photo: "/uploads/users/8/profile-1778652931250.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 8, completion_rate: "99%", is_selected: false },
                { rank: 11, user_id: 7, name: "Dheeraj", photo: "/uploads/users/7/profile-1776246864430.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 9, completion_rate: "77%", is_selected: false },
                { rank: 12, user_id: 1, name: "Keshav_Goyal", photo: "/uploads/users/1/profile-1775713806692.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", certificates: 17, completion_rate: "100%", is_selected: false }
            ],
            highest_engagement: [
                { rank: 1, user_id: 2, name: "Neeraj Jain", photo: "/uploads/users/2/profile-1775713867244.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 97, hours_spent: 110, posts_completed: 42, is_selected: false },
                { rank: 2, user_id: 9, name: "SOHAIL KHAN", photo: "/uploads/users/9/profile-1778653072931.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 73, hours_spent: 97, posts_completed: 34, is_selected: false },
                { rank: 3, user_id: 6, name: "Anil Kumawat", photo: "/uploads/users/6/profile-1776246747079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 78, hours_spent: 62, posts_completed: 37, is_selected: false },
                { rank: 4, user_id: 12, name: "Nagnath Pise", photo: "/uploads/users/12/profile-1778653233079.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 75, hours_spent: 119, posts_completed: 47, is_selected: false },
                { rank: 5, user_id: 1, name: "Keshav_Goyal", photo: "/uploads/users/1/profile-1775713806692.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 88, hours_spent: 103, posts_completed: 25, is_selected: false },
                { rank: 6, user_id: 3, name: "Ravi Pandey", photo: "/uploads/users/3/profile-1775713939921.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 99, hours_spent: 96, posts_completed: 26, is_selected: false },
                { rank: 7, user_id: 7, name: "Dheeraj", photo: "/uploads/users/7/profile-1776246864430.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 83, hours_spent: 98, posts_completed: 47, is_selected: false },
                { rank: 8, user_id: 4, name: "Subhojit", photo: "/uploads/users/4/profile-1776246467383.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 95, hours_spent: 119, posts_completed: 43, is_selected: false },
                { rank: 9, user_id: 11, name: "Sudha Pawar", photo: "/uploads/users/11/profile-1778653157019.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 84, hours_spent: 99, posts_completed: 46, is_selected: false },
                { rank: 10, user_id: 8, name: "Karthick", photo: "/uploads/users/8/profile-1778652931250.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 75, hours_spent: 65, posts_completed: 41, is_selected: false },
                { rank: 11, user_id: 10, name: "Vinaya Prasad", photo: "/uploads/users/10/profile-1778653116674.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 93, hours_spent: 116, posts_completed: 30, is_selected: false },
                { rank: 12, user_id: 5, name: "Pradeep Kumar", photo: "/uploads/users/5/profile-1776246576012.jpg", city: "Mumbai, Maharashtra", dealership: "ABC Motors", role: "DSE", engagement_score: 80, hours_spent: 100, posts_completed: 47, is_selected: false }
            ]
        };

        // Respond with static data (format matches frontend expectation)
        res.status(200).json({
            success: true,
            data: staticData
        });

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
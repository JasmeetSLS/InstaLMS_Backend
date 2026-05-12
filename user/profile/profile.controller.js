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
            
            // Get category-wise post completion data for categories 2 to 5 only
            const [categoryProgress] = await connection.query(
                `SELECT 
                    c.id as category_id,
                    c.name as category_name,
                    c.icon_url,
                    COUNT(DISTINCT p.id) as total_posts,
                    COUNT(DISTINCT CASE 
                        WHEN ump.view_percentage = 100.00 
                        THEN p.id 
                        ELSE NULL 
                    END) as completed_posts,
                    ROUND(
                        (COUNT(DISTINCT CASE WHEN ump.view_percentage = 100.00 THEN p.id ELSE NULL END) * 100.0) / 
                        NULLIF(COUNT(DISTINCT p.id), 0), 
                        2
                    ) as completion_percentage
                 FROM categories c
                 LEFT JOIN posts p ON c.id = p.category_id 
                    AND p.status = 'active'
                    AND p.role_id = ?
                 LEFT JOIN user_media_progress ump ON p.id = ump.post_id AND ump.user_id = ?
                 WHERE c.status = 'active' 
                 AND c.id BETWEEN 2 AND 5
                 GROUP BY c.id, c.name, c.icon_url
                 HAVING total_posts > 0
                 ORDER BY c.id`,
                [user.role_id, userId]
            );
            
            // Prepare response with only user data and category completion data
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
                category_completion: categoryProgress.map(cat => ({
                    category_id: cat.category_id,
                    category_name: cat.category_name,
                    icon_url: cat.icon_url,
                    total_posts: parseInt(cat.total_posts),
                    completed_posts: parseInt(cat.completed_posts),
                    completion_percentage: parseFloat(cat.completion_percentage) || 0
                }))
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
            // Get all 3 users with their ranks (ID 1, 2, 3)
            const [allUsers] = await connection.query(
                `SELECT 
                    id,
                    name,
                    profile_url,
                    employee_id,
                    email,
                    @row_num := @row_num + 1 as user_rank
                 FROM users, (SELECT @row_num := 0) r
                 WHERE id IN (1, 2, 3)
                 ORDER BY id ASC`,
                []
            );

            // Static leaderboard data with common role "Sales Manager"
            const fastestCompletion = [
                { rank: 1, user_id: 2, name: "Ravi Kumar", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", completion_time: "2 days", points: 98 },
                { rank: 2, user_id: 3, name: "Amit Singh", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", completion_time: "3 days", points: 95 },
                { rank: 3, user_id: 1, name: "Sourabh Kumar", city: "Gurugram", dealership: "PQR Cars", role: "Sales Manager", completion_time: "4 days", points: 92 },
                { rank: 4, user_id: 4, name: "Ankit Singh", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", completion_time: "5 days", points: 88 },
                { rank: 5, user_id: 2, name: "Karan Kumar", city: "Chandigarh", dealership: "LMN Automotives", role: "Sales Manager", completion_time: "6 days", points: 85 },
                { rank: 6, user_id: 3, name: "Akash Sharma", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", completion_time: "7 days", points: 82 },
                { rank: 7, user_id: 1, name: "Vikash Singh", city: "Kerala", dealership: "RST Motors", role: "Sales Manager", completion_time: "8 days", points: 80 },
                { rank: 8, user_id: 4, name: "Priya Patel", city: "Ahmedabad", dealership: "DEF Cars", role: "Sales Manager", completion_time: "9 days", points: 78 },
                { rank: 9, user_id: 2, name: "Rajesh Kumar", city: "Jaipur", dealership: "GHI Autos", role: "Sales Manager", completion_time: "10 days", points: 75 },
                { rank: 10, user_id: 3, name: "Neha Sharma", city: "Pune", dealership: "JKL Motors", role: "Sales Manager", completion_time: "11 days", points: 72 }
            ];

            const highestScores = [
                { rank: 1, user_id: 1, name: "Sourabh Kumar", city: "Gurugram", dealership: "PQR Cars", role: "Sales Manager", score: 98, quizzes_taken: 25 },
                { rank: 2, user_id: 2, name: "Ravi Kumar", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", score: 96, quizzes_taken: 22 },
                { rank: 3, user_id: 3, name: "Amit Singh", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", score: 94, quizzes_taken: 20 },
                { rank: 4, user_id: 4, name: "Ankit Singh", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", score: 92, quizzes_taken: 19 },
                { rank: 5, user_id: 1, name: "Vikash Singh", city: "Kerala", dealership: "RST Motors", role: "Sales Manager", score: 90, quizzes_taken: 18 },
                { rank: 6, user_id: 2, name: "Karan Kumar", city: "Chandigarh", dealership: "LMN Automotives", role: "Sales Manager", score: 88, quizzes_taken: 17 },
                { rank: 7, user_id: 3, name: "Akash Sharma", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", score: 86, quizzes_taken: 16 },
                { rank: 8, user_id: 4, name: "Priya Patel", city: "Ahmedabad", dealership: "DEF Cars", role: "Sales Manager", score: 85, quizzes_taken: 15 },
                { rank: 9, user_id: 2, name: "Rajesh Kumar", city: "Jaipur", dealership: "GHI Autos", role: "Sales Manager", score: 84, quizzes_taken: 14 },
                { rank: 10, user_id: 3, name: "Neha Sharma", city: "Pune", dealership: "JKL Motors", role: "Sales Manager", score: 83, quizzes_taken: 13 }
            ];

            const maxCertificates = [
                { rank: 1, user_id: 3, name: "Amit Singh", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", certificates: 15, completion_rate: "100%" },
                { rank: 2, user_id: 1, name: "Sourabh Kumar", city: "Gurugram", dealership: "PQR Cars", role: "Sales Manager", certificates: 14, completion_rate: "98%" },
                { rank: 3, user_id: 2, name: "Ravi Kumar", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", certificates: 13, completion_rate: "95%" },
                { rank: 4, user_id: 4, name: "Ankit Singh", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", certificates: 12, completion_rate: "92%" },
                { rank: 5, user_id: 1, name: "Vikash Singh", city: "Kerala", dealership: "RST Motors", role: "Sales Manager", certificates: 11, completion_rate: "90%" },
                { rank: 6, user_id: 2, name: "Karan Kumar", city: "Chandigarh", dealership: "LMN Automotives", role: "Sales Manager", certificates: 10, completion_rate: "88%" },
                { rank: 7, user_id: 3, name: "Akash Sharma", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", certificates: 9, completion_rate: "85%" },
                { rank: 8, user_id: 4, name: "Priya Patel", city: "Ahmedabad", dealership: "DEF Cars", role: "Sales Manager", certificates: 8, completion_rate: "82%" },
                { rank: 9, user_id: 2, name: "Rajesh Kumar", city: "Jaipur", dealership: "GHI Autos", role: "Sales Manager", certificates: 7, completion_rate: "80%" },
                { rank: 10, user_id: 3, name: "Neha Sharma", city: "Pune", dealership: "JKL Motors", role: "Sales Manager", certificates: 6, completion_rate: "78%" }
            ];

            const highestEngagement = [
                { rank: 1, user_id: 2, name: "Ravi Kumar", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", engagement_score: 98, hours_spent: 120, posts_completed: 45 },
                { rank: 2, user_id: 1, name: "Sourabh Kumar", city: "Gurugram", dealership: "PQR Cars", role: "Sales Manager", engagement_score: 96, hours_spent: 115, posts_completed: 42 },
                { rank: 3, user_id: 3, name: "Amit Singh", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", engagement_score: 94, hours_spent: 110, posts_completed: 40 },
                { rank: 4, user_id: 4, name: "Ankit Singh", city: "Delhi", dealership: "ABC Motors", role: "Sales Manager", engagement_score: 92, hours_spent: 105, posts_completed: 38 },
                { rank: 5, user_id: 2, name: "Karan Kumar", city: "Chandigarh", dealership: "LMN Automotives", role: "Sales Manager", engagement_score: 90, hours_spent: 100, posts_completed: 36 },
                { rank: 6, user_id: 3, name: "Akash Sharma", city: "Mumbai", dealership: "XYZ Auto", role: "Sales Manager", engagement_score: 88, hours_spent: 95, posts_completed: 34 },
                { rank: 7, user_id: 1, name: "Vikash Singh", city: "Kerala", dealership: "RST Motors", role: "Sales Manager", engagement_score: 86, hours_spent: 90, posts_completed: 32 },
                { rank: 8, user_id: 4, name: "Priya Patel", city: "Ahmedabad", dealership: "DEF Cars", role: "Sales Manager", engagement_score: 84, hours_spent: 85, posts_completed: 30 },
                { rank: 9, user_id: 2, name: "Rajesh Kumar", city: "Jaipur", dealership: "GHI Autos", role: "Sales Manager", engagement_score: 82, hours_spent: 80, posts_completed: 28 },
                { rank: 10, user_id: 3, name: "Neha Sharma", city: "Pune", dealership: "JKL Motors", role: "Sales Manager", engagement_score: 80, hours_spent: 75, posts_completed: 26 }
            ];

            res.status(200).json({
                success: true,
                data: {
                    users_rank: allUsers,
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
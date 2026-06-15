const { pool } = require('../../config/db');

exports.getDropdowns = async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();

        const { zone } = req.query;

        // Always return all zones
        const [zones] = await connection.query(
            `SELECT DISTINCT zone FROM dealers WHERE status = 'active' AND zone IS NOT NULL ORDER BY zone`
        );

        // Roles always all
        const [roles] = await connection.query(
            `SELECT DISTINCT name AS role FROM roles WHERE status = 'active' ORDER BY name`
        );

        // Dealerships: filter by zone if provided
        let dealershipQuery = `SELECT DISTINCT dealer_name FROM dealers WHERE status = 'active'`;
        const params = [];
        if (zone) {
            dealershipQuery += ` AND zone = ?`;
            params.push(zone);
        }
        dealershipQuery += ` ORDER BY dealer_name`;

        const [dealerships] = await connection.query(dealershipQuery, params);

        res.json({
            success: true,
            dropdowns: {
                zones: zones.map(z => z.zone),
                dealership: dealerships.map(d => d.dealer_name),
                roles: roles.map(r => r.role)
            }
        });

    } catch (error) {
        console.error('Get dropdowns error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        if (connection) connection.release();
    }
};

exports.getFilteredDashboardStats = async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();

        const { zone, dealer, role } = req.query;

        // Resolve name to ID
        let dealerId = null;
        if (dealer) {
            const [rows] = await connection.query(
                'SELECT id FROM dealers WHERE dealer_name = ? AND status = "active"',
                [dealer]
            );
            if (rows.length) dealerId = rows[0].id;
        }

        let roleId = null;
        if (role) {
            const [rows] = await connection.query(
                'SELECT id FROM roles WHERE name = ? AND status = "active"',
                [role]
            );
            if (rows.length) roleId = rows[0].id;
        }

        // Build filter conditions
        const filters = [];
        const params = [];

        if (zone) {
            filters.push('d.zone = ?');
            params.push(zone);
        }
        if (roleId) {
            filters.push('u.role_id = ?');
            params.push(roleId);
        }
        if (dealerId) {
            filters.push('u.dealer_id = ?');
            params.push(dealerId);
        }

        const whereClause = filters.length ? 'WHERE ' + filters.join(' AND ') : 'WHERE 1=1';

        // ========== USERS ==========
        const [[{ totalUsers }]] = await connection.query(`
            SELECT COUNT(*) AS totalUsers FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${whereClause} AND u.status = 'active'
        `, params);

        const [[{ activeUsers }]] = await connection.query(`
            SELECT COUNT(*) AS activeUsers FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${whereClause} AND u.status = 'active'
        `, params);

        const [[{ inactiveUsers }]] = await connection.query(`
            SELECT COUNT(*) AS inactiveUsers FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${whereClause} AND u.status = 'inactive'
        `, params);

        const [[{ newUsers }]] = await connection.query(`
            SELECT COUNT(*) AS newUsers FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${whereClause} AND u.status = 'active' AND u.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        `, params);

        // Users by role - ensure numeric values
        const [usersByRoleRaw] = await connection.query(`
            SELECT 
                r.id AS role_id,
                r.name AS role,
                COUNT(u.id) AS total,
                SUM(CASE WHEN u.status = 'active' THEN 1 ELSE 0 END) AS active,
                SUM(CASE WHEN u.status = 'inactive' THEN 1 ELSE 0 END) AS inactive,
                SUM(CASE WHEN u.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) AND u.status = 'active' THEN 1 ELSE 0 END) AS new_users
            FROM users u
            RIGHT JOIN roles r ON u.role_id = r.id
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${whereClause}
            GROUP BY r.id, r.name
            ORDER BY r.id
        `, params);

        // Convert string numbers to actual numbers
        const usersByRole = usersByRoleRaw.map(role => ({
            role_id: role.role_id,
            role: role.role,
            total: Number(role.total),
            active: Number(role.active),
            inactive: Number(role.inactive),
            new_users: Number(role.new_users)
        }));

        // ========== COURSES ==========
        const [[{ filteredActiveUsers }]] = await connection.query(`
            SELECT COUNT(*) AS filteredActiveUsers FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${whereClause} AND u.status = 'active'
        `, params);

        const courseFilters = filters.length ? filters.join(' AND ') : '1';
        const [courseStats] = await connection.query(`
            SELECT 
                p.id,
                p.category_id,
                COUNT(DISTINCT pv.user_id) AS viewers_count
            FROM posts p
            LEFT JOIN post_views pv ON p.id = pv.post_id
            LEFT JOIN users u ON pv.user_id = u.id AND u.status = 'active'
            LEFT JOIN dealers d ON u.dealer_id = d.id
            WHERE p.my_course = 1 AND p.status = 'active'
              AND (${courseFilters})
            GROUP BY p.id, p.category_id
        `, params);

        let totalCourses = courseStats.length;
        let completedCourses = 0;
        let pendingCourses = 0;
        const categoryMap = new Map();

        for (const course of courseStats) {
            const isCompleted = (course.viewers_count === filteredActiveUsers && filteredActiveUsers > 0);
            if (isCompleted) completedCourses++;
            else pendingCourses++;

            if (!categoryMap.has(course.category_id)) {
                categoryMap.set(course.category_id, { total: 0, completed: 0 });
            }
            const cat = categoryMap.get(course.category_id);
            cat.total++;
            if (isCompleted) cat.completed++;
        }

        const [categories] = await connection.query(`SELECT id, name FROM categories WHERE status = 'active'`);
        const categoryNames = new Map(categories.map(c => [c.id, c.name]));

        const byCategory = Array.from(categoryMap.entries()).map(([catId, data]) => ({
            category_id: catId,
            category_name: categoryNames.get(catId) || 'Unknown',
            total: data.total,
            completed: data.completed,
            pending: data.total - data.completed
        }));

        // ========== MEDIA ==========
        let mediaWhere = '';
        const mediaParams = [...params];
        if (roleId) {
            mediaWhere = 'WHERE role_id = ?';
            mediaParams.push(roleId);
        } else if (filters.length) {
            mediaWhere = '';
        }

        const [[{ totalMedia }]] = await connection.query(
            `SELECT COUNT(*) AS totalMedia FROM post_media ${mediaWhere}`,
            mediaParams
        );

        const [mediaByType] = await connection.query(
            `SELECT media_type, COUNT(*) AS count FROM post_media ${mediaWhere} GROUP BY media_type ORDER BY count DESC`,
            mediaParams
        );

        // Ensure totals are also numbers
        res.json({
            success: true,
            data: {
                users: {
                    totals: { 
                        total: Number(totalUsers), 
                        active: Number(activeUsers), 
                        inactive: Number(inactiveUsers), 
                        new_users: Number(newUsers) 
                    },
                    by_role: usersByRole
                },
                courses: {
                    totals: { 
                        total_courses: totalCourses, 
                        completed_courses: completedCourses, 
                        pending_courses: pendingCourses 
                    },
                    by_category: byCategory
                },
                media: {
                    total_media: totalMedia,
                    by_type: mediaByType
                }
            }
        });

    } catch (error) {
        console.error('Filtered dashboard error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        if (connection) connection.release();
    }
};


exports.getLeaderboard = async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();

        const { zone, dealer, role } = req.query;

        // Resolve dealer & role names to IDs
        let dealerId = null;
        if (dealer) {
            const [rows] = await connection.query(
                'SELECT id FROM dealers WHERE dealer_name = ? AND status = "active"',
                [dealer]
            );
            if (rows.length) dealerId = rows[0].id;
        }

        let roleId = null;
        if (role) {
            const [rows] = await connection.query(
                'SELECT id FROM roles WHERE name = ? AND status = "active"',
                [role]
            );
            if (rows.length) roleId = rows[0].id;
        }

        // Build user filters
        const userFilters = [];
        const userParams = [];

        if (zone) {
            userFilters.push('d.zone = ?');
            userParams.push(zone);
        }
        if (roleId) {
            userFilters.push('u.role_id = ?');
            userParams.push(roleId);
        }
        if (dealerId) {
            userFilters.push('u.dealer_id = ?');
            userParams.push(dealerId);
        }

        const userWhere = userFilters.length ? 'AND ' + userFilters.join(' AND ') : '';

        // 1. Fastest Completion (all MyCourses, shortest days span)
        const [fastestComplete] = await connection.query(`
            SELECT 
                u.id AS user_id,
                u.name,
                u.email,
                u.profile_url AS photo,
                r.name AS role,
                d.dealer_name AS dealership,
                COUNT(*) AS completed_courses,
                DATEDIFF(MAX(pv.viewed_at), MIN(pv.viewed_at)) AS days_taken,
                MIN(pv.viewed_at) AS first_completed_at,
                MAX(pv.viewed_at) AS last_completed_at
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            LEFT JOIN roles r ON u.role_id = r.id
            JOIN post_views pv ON u.id = pv.user_id
            JOIN posts p ON pv.post_id = p.id
            WHERE p.my_course = 1 
              AND p.status = 'active'
              AND u.status = 'active'
              ${userWhere}
            GROUP BY u.id
            HAVING completed_courses = (SELECT COUNT(*) FROM posts WHERE my_course = 1 AND status = 'active')
            ORDER BY days_taken ASC, completed_courses DESC
            LIMIT 10
        `, userParams);

        const formatDays = (days) => {
            if (days === 0) return '< 1 day';
            return `${days} day${days > 1 ? 's' : ''}`;
        };

        const fastestCompleteFormatted = fastestComplete.map(c => ({
            user_id: c.user_id,
            name: c.name,
            email: c.email,
            photo: c.photo,
            role: c.role,
            dealership: c.dealership,
            completed_courses: c.completed_courses,
            days_taken: c.days_taken,
            days_taken_formatted: formatDays(c.days_taken),
            first_completed_at: c.first_completed_at,
            last_completed_at: c.last_completed_at
        }));

        // 2. Highest Quiz Scores (MyCourse quizzes)
        const [highestScores] = await connection.query(`
            SELECT 
                u.id AS user_id,
                u.name,
                u.email,
                u.profile_url AS photo,
                r.name AS role,
                d.dealer_name AS dealership,
                SUM(qc.score) AS total_score
            FROM user_quiz_completion qc
            JOIN users u ON qc.user_id = u.id
            LEFT JOIN dealers d ON u.dealer_id = d.id
            LEFT JOIN roles r ON u.role_id = r.id
            JOIN posts p ON qc.post_id = p.id
            WHERE p.my_course = 1 
              AND p.quiz_active = 1 
              AND p.status = 'active'
              AND u.status = 'active'
              ${userWhere}
            GROUP BY u.id
            ORDER BY total_score DESC
            LIMIT 10
        `, userParams);

        // 3. Most Quizzes Completed (distinct posts)
        const [maxQuizComplete] = await connection.query(`
            SELECT 
                u.id AS user_id,
                u.name,
                u.email,
                u.profile_url AS photo,
                r.name AS role,
                d.dealer_name AS dealership,
                COUNT(DISTINCT qc.post_id) AS quizzes_completed
            FROM user_quiz_completion qc
            JOIN users u ON qc.user_id = u.id
            LEFT JOIN dealers d ON u.dealer_id = d.id
            LEFT JOIN roles r ON u.role_id = r.id
            JOIN posts p ON qc.post_id = p.id
            WHERE p.quiz_active = 1 
              AND p.status = 'active'
              AND u.status = 'active'
              ${userWhere}
            GROUP BY u.id
            ORDER BY quizzes_completed DESC
            LIMIT 10
        `, userParams);

        // 4. Highest Engagement = Most Post Views (all posts)
        const [engagement] = await connection.query(`
            SELECT 
                u.id AS user_id,
                u.name,
                u.email,
                u.profile_url AS photo,
                r.name AS role,
                d.dealer_name AS dealership,
                COUNT(pv.id) AS total_views
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            LEFT JOIN roles r ON u.role_id = r.id
            JOIN post_views pv ON u.id = pv.user_id
            WHERE u.status = 'active'
              ${userWhere}
            GROUP BY u.id
            ORDER BY total_views DESC
            LIMIT 10
        `, userParams);

        res.json({
            success: true,
            data: {
                fastest_course_completion: fastestCompleteFormatted,
                highest_quiz_scores: highestScores,
                most_quizzes_completed: maxQuizComplete,
                highest_engagement: engagement
            }
        });

    } catch (error) {
        console.error('Leaderboard error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        if (connection) connection.release();
    }
};

exports.getLearningProgress = async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();

        const { zone, dealer, role } = req.query;

        // Resolve dealer/role IDs
        let dealerId = null;
        if (dealer) {
            const [rows] = await connection.query(
                'SELECT id FROM dealers WHERE dealer_name = ? AND status = "active"',
                [dealer]
            );
            if (rows.length) dealerId = rows[0].id;
        }
        let roleId = null;
        if (role) {
            const [rows] = await connection.query(
                'SELECT id FROM roles WHERE name = ? AND status = "active"',
                [role]
            );
            if (rows.length) roleId = rows[0].id;
        }

        // Build user filters
        const userFilters = [];
        const filterParams = [];
        if (zone) { userFilters.push('d.zone = ?'); filterParams.push(zone); }
        if (roleId) { userFilters.push('u.role_id = ?'); filterParams.push(roleId); }
        if (dealerId) { userFilters.push('u.dealer_id = ?'); filterParams.push(dealerId); }
        const userWhere = userFilters.length ? 'WHERE ' + userFilters.join(' AND ') : '';

        // --- MyCourse stats ---
        const [[{ totalCourses }]] = await connection.query(`
            SELECT COUNT(*) AS totalCourses
            FROM posts
            WHERE my_course = 1 AND status = 'active'
        `);

        const [[{ filteredUserCount }]] = await connection.query(`
            SELECT COUNT(DISTINCT u.id) AS filteredUserCount
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${userWhere}
            AND u.status = 'active'
        `, filterParams);

        const [userCourseCompletion] = await connection.query(`
            SELECT u.id, COUNT(DISTINCT pv.post_id) AS completed_count
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            LEFT JOIN post_views pv ON u.id = pv.user_id
            LEFT JOIN posts p ON pv.post_id = p.id AND p.my_course = 1 AND p.status = 'active'
            ${userWhere}
            AND u.status = 'active'
            GROUP BY u.id
        `, filterParams);

        let totalCompletedCoursesSum = 0, fullyCompletedUsers = 0;
        for (const uc of userCourseCompletion) {
            totalCompletedCoursesSum += uc.completed_count;
            if (uc.completed_count === totalCourses) fullyCompletedUsers++;
        }
        const avgCompletionPercent = filteredUserCount > 0 && totalCourses > 0
            ? ((totalCompletedCoursesSum / (filteredUserCount * totalCourses)) * 100).toFixed(2)
            : 0;

        // --- Quiz stats ---
        const [[{ totalQuizzes }]] = await connection.query(`
            SELECT COUNT(*) AS totalQuizzes
            FROM posts
            WHERE my_course = 1 AND quiz_active = 1 AND status = 'active'
        `);

        const [userQuizCompletion] = await connection.query(`
            SELECT u.id, COUNT(DISTINCT qc.post_id) AS quizzes_completed
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            LEFT JOIN user_quiz_completion qc ON u.id = qc.user_id
            LEFT JOIN posts p ON qc.post_id = p.id 
                AND p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
            ${userWhere}
            AND u.status = 'active'
            GROUP BY u.id
        `, filterParams);

        let totalCompletedQuizzesSum = 0, fullyQuizCompletedUsers = 0;
        for (const uq of userQuizCompletion) {
            totalCompletedQuizzesSum += uq.quizzes_completed;
            if (totalQuizzes > 0 && uq.quizzes_completed === totalQuizzes) fullyQuizCompletedUsers++;
        }
        const avgQuizCompletionPercent = filteredUserCount > 0 && totalQuizzes > 0
            ? ((totalCompletedQuizzesSum / (filteredUserCount * totalQuizzes)) * 100).toFixed(2)
            : 0;

        // --- Quiz score stats ---
        const [[{ numberOfQuizzes }]] = await connection.query(`
            SELECT COUNT(DISTINCT p.id) AS numberOfQuizzes
            FROM posts p
            WHERE p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
              AND EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.post_id = p.id AND qq.status = 'active')
        `);

        const [[{ totalPossibleScore }]] = await connection.query(`
            SELECT COALESCE(SUM(quiz_max.max_score), 0) AS totalPossibleScore
            FROM (
                SELECT post_id, SUM(marks) AS max_score
                FROM quiz_questions
                WHERE status = 'active'
                GROUP BY post_id
            ) AS quiz_max
            JOIN posts p ON quiz_max.post_id = p.id
            WHERE p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
        `);

        const avgMaxPerQuiz = numberOfQuizzes > 0 ? (totalPossibleScore / numberOfQuizzes) : 0;

        const [scoreStats] = await connection.query(`
            SELECT 
                COALESCE(SUM(qc.score), 0) AS total_obtained_score,
                COUNT(qc.id) AS total_completions
            FROM user_quiz_completion qc
            JOIN users u ON qc.user_id = u.id
            LEFT JOIN dealers d ON u.dealer_id = d.id
            JOIN posts p ON qc.post_id = p.id
            WHERE p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
              AND u.status = 'active'
              ${userFilters.length ? 'AND ' + userFilters.join(' AND ') : ''}
        `, filterParams);

        const totalObtained = scoreStats[0]?.total_obtained_score || 0;
        const totalCompletions = scoreStats[0]?.total_completions || 0;
        const averageScorePerCompletion = totalCompletions > 0 ? (totalObtained / totalCompletions) : 0;
        const avgScorePercent = avgMaxPerQuiz > 0 && totalCompletions > 0
            ? ((averageScorePerCompletion / avgMaxPerQuiz) * 100).toFixed(2)
            : 0;

        // ========== ASSESSMENT BREAKUP (MATRIX FORMAT) ==========
        // 1. Get all active quizzes ordered by id
        const [quizzesList] = await connection.query(`
            SELECT p.id AS quiz_id, p.title AS assessment_name
            FROM posts p
            WHERE p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
            ORDER BY p.id
        `);

        let assessmentBreakup = [];

        if (quizzesList.length > 0) {
            const quizIds = quizzesList.map(q => q.quiz_id);

            // 2. Total marks per quiz per category
            const [categoryQuestions] = await connection.query(`
                SELECT 
                    qq.post_id AS quiz_id,
                    qc.id AS category_id,
                    qc.name AS category_name,
                    SUM(qq.marks) AS total_marks_in_category
                FROM quiz_questions qq
                JOIN quiz_categories qc ON qq.category_id = qc.id
                WHERE qq.post_id IN (?) AND qq.status = 'active' AND qc.status = 'active'
                GROUP BY qq.post_id, qc.id, qc.name
                ORDER BY qq.post_id, qc.id
            `, [quizIds]);

            // Map quiz_id -> categories
            const quizCategoryMap = new Map();
            for (const row of categoryQuestions) {
                if (!quizCategoryMap.has(row.quiz_id)) quizCategoryMap.set(row.quiz_id, []);
                quizCategoryMap.get(row.quiz_id).push({
                    category_id: row.category_id,
                    category_name: row.category_name,
                    total_marks: row.total_marks_in_category
                });
            }

            // 3. Get filtered user IDs
            const [users] = await connection.query(`
                SELECT DISTINCT u.id
                FROM users u
                LEFT JOIN dealers d ON u.dealer_id = d.id
                WHERE u.status = 'active'
                ${userFilters.length ? 'AND ' + userFilters.join(' AND ') : ''}
            `, filterParams);
            const userIds = users.map(u => u.id);

            // 4. Average obtained marks per quiz per category
            const avgMap = new Map(); // key = "quiz_id|category_id"
            if (userIds.length > 0) {
                const [avgScores] = await connection.query(`
                    SELECT 
                        uqa.post_id AS quiz_id,
                        qq.category_id,
                        AVG(CASE WHEN uqa.is_correct = 1 THEN qq.marks ELSE 0 END) AS avg_obtained_marks
                    FROM user_quiz_answers uqa
                    JOIN quiz_questions qq ON uqa.question_id = qq.id
                    WHERE uqa.user_id IN (?) AND uqa.post_id IN (?) AND qq.status = 'active'
                    GROUP BY uqa.post_id, qq.category_id
                `, [userIds, quizIds]);

                for (const row of avgScores) {
                    const key = `${row.quiz_id}|${row.category_id}`;
                    avgMap.set(key, row.avg_obtained_marks);
                }
            }

            // 5. Collect all distinct categories across all quizzes
            const allCategories = new Map(); // category_id -> category_name
            for (const cats of quizCategoryMap.values()) {
                for (const cat of cats) {
                    if (!allCategories.has(cat.category_id)) {
                        allCategories.set(cat.category_id, cat.category_name);
                    }
                }
            }

            // 6. Build matrix: each row = one category, columns = assessments (by real name)
            for (const [catId, catName] of allCategories.entries()) {
                const row = { category_name: catName };
                let totalPercentage = 0;
                let count = 0;

                for (const quiz of quizzesList) {
                    const categoryData = quizCategoryMap.get(quiz.quiz_id)?.find(c => c.category_id === catId);
                    let percentage = 0;
                    if (categoryData && categoryData.total_marks > 0) {
                        const avgObtained = avgMap.get(`${quiz.quiz_id}|${catId}`) || 0;
                        percentage = (avgObtained / categoryData.total_marks) * 100;
                        percentage = parseFloat(percentage.toFixed(2));
                    }
                    // Use the actual assessment name as the key
                    row[quiz.assessment_name] = percentage;
                    totalPercentage += percentage;
                    if (categoryData) count++;
                }

                // Average across only those quizzes that actually contain this category
                row.average = count > 0 ? parseFloat((totalPercentage / count).toFixed(2)) : 0;
                assessmentBreakup.push(row);
            }
        }

        // Final response
        res.json({
            success: true,
            data: {
                mycourse: {
                    total_courses_available: totalCourses,
                    avg_completion_percentage: parseFloat(avgCompletionPercent),
                    users_fully_completed: fullyCompletedUsers
                },
                mycourse_certified: {
                    total_courses_available: totalCourses,
                    avg_completion_percentage: parseFloat(avgCompletionPercent),
                    users_fully_completed: fullyCompletedUsers
                },
                quiz: {
                    total_quizzes_available: totalQuizzes,
                    avg_completion_percentage: parseFloat(avgQuizCompletionPercent),
                    users_fully_completed_quizzes: fullyQuizCompletedUsers
                },
                quiz_score: {
                    quizzes_average_total_score: avgMaxPerQuiz.toFixed(2).toString(),
                    avg_score_percentage: parseFloat(avgScorePercent),
                    users_quiz_average__score: averageScorePerCompletion.toFixed(2).toString()
                },
                assessment_breakup: assessmentBreakup
            }
        });

    } catch (error) {
        console.error('Learning progress error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        if (connection) connection.release();
    }
};


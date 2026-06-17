const { pool } = require('../../config/db');

exports.getDropdowns = async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();

        const { zone, dealer, city, role } = req.query;

        // ---------- ZONES (always all active zones) ----------
        const [zones] = await connection.query(
            `SELECT DISTINCT zone FROM dealers WHERE status = 'active' AND zone IS NOT NULL ORDER BY zone`
        );

        // ---------- DEALERSHIPS (filter by zone if provided) ----------
        let dealershipQuery = `SELECT dealer_name FROM dealers WHERE status = 'active'`;
        const dealershipParams = [];
        if (zone) {
            dealershipQuery += ` AND zone = ?`;
            dealershipParams.push(zone);
        }
        dealershipQuery += ` ORDER BY dealer_name`;
        const [dealerships] = await connection.query(dealershipQuery, dealershipParams);

        // ---------- CITIES (filter by dealer if provided, otherwise all cities) ----------
        let cities = [];
        if (dealer) {
            // First get dealer_id from dealer_name
            const [dealerRows] = await connection.query(
                `SELECT id FROM dealers WHERE dealer_name = ? AND status = 'active'`,
                [dealer]
            );
            if (dealerRows.length) {
                const dealerId = dealerRows[0].id;
                const [cityRows] = await connection.query(
                    `SELECT city_name FROM cities WHERE dealer_id = ? AND status = 'active' ORDER BY city_name`,
                    [dealerId]
                );
                cities = cityRows.map(c => c.city_name);
            }
        } else {
            // If no dealer selected, return all cities from active dealers
            const [allCities] = await connection.query(`
                SELECT DISTINCT c.city_name 
                FROM cities c
                JOIN dealers d ON c.dealer_id = d.id
                WHERE c.status = 'active' AND d.status = 'active'
                ORDER BY c.city_name
            `);
            cities = allCities.map(c => c.city_name);
        }

        // ---------- ROLES (filter by city if provided, otherwise all roles) ----------
        let roles = [];
        if (city) {
            let roleQuery = `
                SELECT DISTINCT r.name 
                FROM users u
                JOIN roles r ON u.role_id = r.id
                JOIN cities c ON u.city_id = c.id
                JOIN dealers d ON u.dealer_id = d.id
                WHERE u.status = 'active' 
                  AND c.city_name = ?
                  AND r.status = 'active'
            `;
            const roleParams = [city];
            if (zone) {
                roleQuery += ` AND d.zone = ?`;
                roleParams.push(zone);
            }
            if (dealer) {
                roleQuery += ` AND d.dealer_name = ?`;
                roleParams.push(dealer);
            }
            roleQuery += ` ORDER BY r.name`;
            const [roleRows] = await connection.query(roleQuery, roleParams);
            roles = roleRows.map(r => r.name);
        } else {
            // If no city selected, return all active roles
            const [allRoles] = await connection.query(
                `SELECT name FROM roles WHERE status = 'active' ORDER BY name`
            );
            roles = allRoles.map(r => r.name);
        }

        // ---------- USERS (filter by zone, dealer, city, role) ----------
        let userQuery = `
            SELECT DISTINCT u.name 
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            LEFT JOIN cities c ON u.city_id = c.id
            LEFT JOIN roles r ON u.role_id = r.id
            WHERE u.status = 'active'
        `;
        const userParams = [];
        const filters = [];

        if (zone) {
            filters.push('d.zone = ?');
            userParams.push(zone);
        }
        if (dealer) {
            filters.push('d.dealer_name = ?');
            userParams.push(dealer);
        }
        if (city) {
            filters.push('c.city_name = ?');
            userParams.push(city);
        }
        if (role) {
            filters.push('r.name = ?');
            userParams.push(role);
        }

        if (filters.length) {
            userQuery += ' AND ' + filters.join(' AND ');
        }
        userQuery += ' ORDER BY u.name';

        const [users] = await connection.query(userQuery, userParams);

        res.json({
            success: true,
            dropdowns: {
                zones: zones.map(z => z.zone),
                dealership: dealerships.map(d => d.dealer_name),
                cities: cities,
                roles: roles,
                users: users.map(u => u.name)
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
        const { zone, dealer, city, role } = req.query;

        // Resolve names to IDs
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

        let cityId = null;
        if (city) {
            const [rows] = await connection.query(
                'SELECT id FROM cities WHERE city_name = ? AND status = "active"',
                [city]
            );
            if (rows.length) cityId = rows[0].id;
        }

        // Build filter conditions
        const filters = [];
        const params = [];

        if (zone) {
            filters.push('d.zone = ?');
            params.push(zone);
        }
        if (dealerId) {
            filters.push('u.dealer_id = ?');
            params.push(dealerId);
        }
        if (cityId) {
            filters.push('u.city_id = ?');
            params.push(cityId);
        }
        if (roleId) {
            filters.push('u.role_id = ?');
            params.push(roleId);
        }

        const whereClause = filters.length ? 'WHERE ' + filters.join(' AND ') : 'WHERE 1=1';

        // ---------- USERS ----------
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

        // Users by role
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

        const usersByRole = usersByRoleRaw.map(role => ({
            role_id: role.role_id,
            role: role.role,
            total: Number(role.total),
            active: Number(role.active),
            inactive: Number(role.inactive),
            new_users: Number(role.new_users)
        }));

        // ---------- COURSES ----------
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
let mediaParams = [];
if (roleId) {
    mediaWhere = 'WHERE role_id = ?';
    mediaParams = [roleId];
}
const [[{ totalMedia }]] = await connection.query(
    `SELECT COUNT(*) AS totalMedia FROM post_media ${mediaWhere}`,
    mediaParams
);
const [mediaByType] = await connection.query(
    `SELECT media_type, COUNT(*) AS count FROM post_media ${mediaWhere} GROUP BY media_type ORDER BY count DESC`,
    mediaParams
);

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
        const { zone, dealer, city, role, user } = req.query;

        // Resolve IDs
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

        let cityId = null;
        if (city) {
            const [rows] = await connection.query(
                'SELECT id FROM cities WHERE city_name = ? AND status = "active"',
                [city]
            );
            if (rows.length) cityId = rows[0].id;
        }

        let userId = null;
        let selectedUserName = null;
        if (user) {
            const [rows] = await connection.query(
                'SELECT id, name FROM users WHERE name = ? AND status = "active"',
                [user]
            );
            if (rows.length) {
                userId = rows[0].id;
                selectedUserName = rows[0].name;
            }
        }

        // Build user filters (common to all queries)
        const userFilters = [];
        const userParams = [];

        if (zone) {
            userFilters.push('d.zone = ?');
            userParams.push(zone);
        }
        if (dealerId) {
            userFilters.push('u.dealer_id = ?');
            userParams.push(dealerId);
        }
        if (cityId) {
            userFilters.push('u.city_id = ?');
            userParams.push(cityId);
        }
        if (roleId) {
            userFilters.push('u.role_id = ?');
            userParams.push(roleId);
        }
        // Do NOT filter by userId here – we want to see the full leaderboard, just mark the selected user

        const userWhere = userFilters.length ? 'AND ' + userFilters.join(' AND ') : '';

        // Helper to mark selected user
        const markSelected = (arr) => {
            if (!userId) return arr;
            return arr.map(item => ({
                ...item,
                is_selected: item.user_id === userId
            }));
        };

        // 1. Fastest Completion
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

        let fastestCompleteFormatted = fastestComplete.map(c => ({
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
        fastestCompleteFormatted = markSelected(fastestCompleteFormatted);

        // 2. Highest Quiz Scores
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

        let highestScoresFormatted = highestScores.map(c => ({
            user_id: c.user_id,
            name: c.name,
            email: c.email,
            photo: c.photo,
            role: c.role,
            dealership: c.dealership,
            total_score: c.total_score
        }));
        highestScoresFormatted = markSelected(highestScoresFormatted);

        // 3. Most Quizzes Completed
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

        let maxQuizCompleteFormatted = maxQuizComplete.map(c => ({
            user_id: c.user_id,
            name: c.name,
            email: c.email,
            photo: c.photo,
            role: c.role,
            dealership: c.dealership,
            quizzes_completed: c.quizzes_completed
        }));
        maxQuizCompleteFormatted = markSelected(maxQuizCompleteFormatted);

        // 4. Highest Engagement
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

        let engagementFormatted = engagement.map(c => ({
            user_id: c.user_id,
            name: c.name,
            email: c.email,
            photo: c.photo,
            role: c.role,
            dealership: c.dealership,
            total_views: c.total_views
        }));
        engagementFormatted = markSelected(engagementFormatted);

        res.json({
            success: true,
            data: {
                fastest_course_completion: fastestCompleteFormatted,
                highest_quiz_scores: highestScoresFormatted,
                most_quizzes_completed: maxQuizCompleteFormatted,
                highest_engagement: engagementFormatted,
                selected_user: selectedUserName || null   // optional, for convenience
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
        const { zone, dealer, city, role, user } = req.query;

        // ---------- Resolve names to IDs ----------
        let dealerId = null, roleId = null, cityId = null, userId = null;
        if (dealer) {
            const [rows] = await connection.query(
                'SELECT id FROM dealers WHERE dealer_name = ? AND status = "active"',
                [dealer]
            );
            if (rows.length) dealerId = rows[0].id;
        }
        if (role) {
            const [rows] = await connection.query(
                'SELECT id FROM roles WHERE name = ? AND status = "active"',
                [role]
            );
            if (rows.length) roleId = rows[0].id;
        }
        if (city) {
            const [rows] = await connection.query(
                'SELECT id FROM cities WHERE city_name = ? AND status = "active"',
                [city]
            );
            if (rows.length) cityId = rows[0].id;
        }
        if (user) {
            const [rows] = await connection.query(
                'SELECT id FROM users WHERE name = ? AND status = "active"',
                [user]
            );
            if (rows.length) userId = rows[0].id;
        }

        // ---------- Build filter conditions for users ----------
        const userFilters = [], filterParams = [];
        if (zone) { userFilters.push('d.zone = ?'); filterParams.push(zone); }
        if (dealerId) { userFilters.push('u.dealer_id = ?'); filterParams.push(dealerId); }
        if (cityId) { userFilters.push('u.city_id = ?'); filterParams.push(cityId); }
        if (roleId) { userFilters.push('u.role_id = ?'); filterParams.push(roleId); }
        const userWhere = userFilters.length ? 'AND ' + userFilters.join(' AND ') : '';

        // ---------- Get filtered users ----------
        const [filteredUsers] = await connection.query(`
            SELECT u.id, u.role_id, u.name
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            WHERE u.status = 'active'
            ${userWhere}
        `, filterParams);

        const userIds = filteredUsers.map(u => u.id);
        const userRoleMap = new Map(filteredUsers.map(u => [u.id, u.role_id]));

        // ============================================================
        // 1. MYCOURSE STATS (role‑aware per user)
        // ============================================================
        let mycoursePerUser = [];
        if (userIds.length > 0) {
            const [rows] = await connection.query(`
                SELECT 
                    u.id AS user_id,
                    COUNT(DISTINCT p.id) AS available_courses,
                    COUNT(DISTINCT pv.post_id) AS completed_courses
                FROM users u
                LEFT JOIN posts p ON p.my_course = 1 AND p.status = 'active' AND p.role_id = u.role_id
                LEFT JOIN post_views pv ON pv.user_id = u.id AND pv.post_id = p.id
                WHERE u.id IN (?)
                GROUP BY u.id
            `, [userIds]);
            mycoursePerUser = rows;
        }

        let totalAvailableCourses = 0, totalCompletedSum = 0;
        const userCoursePcts = [];
        for (const row of mycoursePerUser) {
            const avail = parseInt(row.available_courses) || 0;
            const comp = parseInt(row.completed_courses) || 0;
            totalAvailableCourses += avail;
            totalCompletedSum += comp;
            const pct = avail > 0 ? (comp / avail) * 100 : 0;
            userCoursePcts.push(pct);
        }
        const avgCoursePct = userCoursePcts.length > 0
            ? (userCoursePcts.reduce((a, b) => a + b, 0) / userCoursePcts.length)
            : 0;

        // Total courses for the filtered group (role‑aware)
        let totalCoursesForGroup = 0;
        if (roleId) {
            const [[{ count }]] = await connection.query(
                'SELECT COUNT(*) AS count FROM posts WHERE my_course = 1 AND status = "active" AND role_id = ?',
                [roleId]
            );
            totalCoursesForGroup = count;
        } else {
            const [[{ count }]] = await connection.query(
                'SELECT COUNT(*) AS count FROM posts WHERE my_course = 1 AND status = "active"'
            );
            totalCoursesForGroup = count;
        }

        // ============================================================
        // 2. QUIZ (ASSESSMENT) STATS (role‑aware per user)
        // ============================================================
        let quizPerUser = [];
        if (userIds.length > 0) {
            const [rows] = await connection.query(`
                SELECT 
                    u.id AS user_id,
                    COUNT(DISTINCT p.id) AS available_quizzes,
                    COUNT(DISTINCT qc.post_id) AS completed_quizzes
                FROM users u
                LEFT JOIN posts p ON p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active' AND p.role_id = u.role_id
                LEFT JOIN user_quiz_completion qc ON qc.user_id = u.id AND qc.post_id = p.id
                WHERE u.id IN (?)
                GROUP BY u.id
            `, [userIds]);
            quizPerUser = rows;
        }

        let totalAvailableQuizzes = 0, totalQuizCompletedSum = 0;
        const userQuizPcts = [];
        for (const row of quizPerUser) {
            const avail = parseInt(row.available_quizzes) || 0;
            const comp = parseInt(row.completed_quizzes) || 0;
            totalAvailableQuizzes += avail;
            totalQuizCompletedSum += comp;
            const pct = avail > 0 ? (comp / avail) * 100 : 0;
            userQuizPcts.push(pct);
        }
        const avgQuizPct = userQuizPcts.length > 0
            ? (userQuizPcts.reduce((a, b) => a + b, 0) / userQuizPcts.length)
            : 0;

        // Total quizzes for the filtered group
        let totalQuizzesForGroup = 0;
        if (roleId) {
            const [[{ count }]] = await connection.query(
                'SELECT COUNT(*) AS count FROM posts WHERE my_course = 1 AND quiz_active = 1 AND status = "active" AND role_id = ?',
                [roleId]
            );
            totalQuizzesForGroup = count;
        } else {
            const [[{ count }]] = await connection.query(
                'SELECT COUNT(*) AS count FROM posts WHERE my_course = 1 AND quiz_active = 1 AND status = "active"'
            );
            totalQuizzesForGroup = count;
        }

        // ============================================================
        // 3. QUIZ SCORE AGGREGATE STATS (filtered users)
        // ============================================================
        let avgMaxPerQuiz = 0, avgScorePct = 0, avgScorePerCompletion = 0;
        if (userIds.length > 0) {
            let possibleQuery = `
                SELECT COALESCE(SUM(qq.marks), 0) AS total_possible
                FROM quiz_questions qq
                JOIN posts p ON qq.post_id = p.id
                WHERE p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
            `;
            const possibleParams = [];
            if (roleId) {
                possibleQuery += ' AND p.role_id = ?';
                possibleParams.push(roleId);
            }
            const [[{ total_possible }]] = await connection.query(possibleQuery, possibleParams);

            const [[{ quiz_count }]] = await connection.query(`
                SELECT COUNT(DISTINCT p.id) AS quiz_count
                FROM posts p
                WHERE p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
                ${roleId ? 'AND p.role_id = ?' : ''}
            `, roleId ? [roleId] : []);
            const numQuizzes = quiz_count || 1;
            avgMaxPerQuiz = total_possible / numQuizzes;

            const [scoreRows] = await connection.query(`
                SELECT 
                    COALESCE(SUM(qc.score), 0) AS total_obtained,
                    COUNT(qc.id) AS completions
                FROM user_quiz_completion qc
                JOIN users u ON qc.user_id = u.id
                JOIN posts p ON qc.post_id = p.id
                WHERE u.id IN (?)
                  AND p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
                  ${roleId ? 'AND p.role_id = ?' : ''}
            `, roleId ? [userIds, roleId] : [userIds]);

            const totalObtained = scoreRows[0]?.total_obtained || 0;
            const completions = scoreRows[0]?.completions || 0;
            avgScorePerCompletion = completions > 0 ? totalObtained / completions : 0;
            avgScorePct = avgMaxPerQuiz > 0 && completions > 0
                ? (avgScorePerCompletion / avgMaxPerQuiz) * 100
                : 0;
        }

        // ============================================================
        // 4. ASSESSMENT BREAKUP (category‑wise, filtered users)
        // ============================================================
        let assessmentBreakup = [];

        let quizListQuery = `
            SELECT p.id AS quiz_id, p.title AS assessment_name
            FROM posts p
            WHERE p.my_course = 1 AND p.quiz_active = 1 AND p.status = 'active'
        `;
        const quizListParams = [];
        if (roleId) {
            quizListQuery += ' AND p.role_id = ?';
            quizListParams.push(roleId);
        }
        quizListQuery += ' ORDER BY p.id';
        const [quizzesList] = await connection.query(quizListQuery, quizListParams);

        if (quizzesList.length > 0 && userIds.length > 0) {
            const quizIds = quizzesList.map(q => q.quiz_id);

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

            const quizCategoryMap = new Map();
            for (const row of categoryQuestions) {
                if (!quizCategoryMap.has(row.quiz_id)) quizCategoryMap.set(row.quiz_id, []);
                quizCategoryMap.get(row.quiz_id).push({
                    category_id: row.category_id,
                    category_name: row.category_name,
                    total_marks: row.total_marks_in_category
                });
            }

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

            const avgMap = new Map();
            for (const row of avgScores) {
                const key = `${row.quiz_id}|${row.category_id}`;
                avgMap.set(key, row.avg_obtained_marks);
            }

            const allCategories = new Map();
            for (const cats of quizCategoryMap.values()) {
                for (const cat of cats) {
                    if (!allCategories.has(cat.category_id)) {
                        allCategories.set(cat.category_id, cat.category_name);
                    }
                }
            }

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
                        count++;
                    }
                    row[quiz.assessment_name] = percentage;
                    totalPercentage += percentage;
                }
                row.average = count > 0 ? parseFloat((totalPercentage / count).toFixed(2)) : 0;
                assessmentBreakup.push(row);
            }
        }

        // ============================================================
        // 5. USER‑SPECIFIC DETAILS (if userId given)
        // ============================================================
        let userCompletedCourses = 0, userCompletedQuizzes = 0;
        let userDetails = null;

        if (userId) {
            const myData = mycoursePerUser.find(row => row.user_id === userId);
            if (myData) {
                userCompletedCourses = parseInt(myData.completed_courses) || 0;
            }
            const quizData = quizPerUser.find(row => row.user_id === userId);
            if (quizData) {
                userCompletedQuizzes = parseInt(quizData.completed_quizzes) || 0;
            }

            // ---- A) MyCourse progress ----
            const [myCoursePosts] = await connection.query(`
                SELECT id, title
                FROM posts
                WHERE my_course = 1 AND status = 'active'
                ${roleId ? 'AND role_id = ?' : ''}
                ORDER BY id
            `, roleId ? [roleId] : []);

            const [progressRows] = await connection.query(`
                SELECT post_id, view_percentage
                FROM user_media_progress
                WHERE user_id = ?
            `, [userId]);
            const progressMap = new Map();
            for (const row of progressRows) {
                progressMap.set(row.post_id, parseFloat(row.view_percentage));
            }

            const [viewRows] = await connection.query(`
                SELECT post_id
                FROM post_views
                WHERE user_id = ?
            `, [userId]);
            const viewedSet = new Set(viewRows.map(r => r.post_id));

            const mycourseDetails = myCoursePosts.map(post => {
                const viewed = viewedSet.has(post.id);
                const progress = progressMap.get(post.id) || 0;
                return {
                    post_id: post.id,
                    title: post.title,
                    viewed: viewed,
                    progress_percentage: progress,
                    completed: progress >= 100
                };
            });

            // ---- B) Certificates = MyCourse posts with 100% progress ----
            const certificates = mycourseDetails.filter(p => p.completed);

            // ---- C) Assessments (quizzes) ----
            const [quizPosts] = await connection.query(`
                SELECT id, title
                FROM posts
                WHERE my_course = 1 AND quiz_active = 1 AND status = 'active'
                ${roleId ? 'AND role_id = ?' : ''}
                ORDER BY id
            `, roleId ? [roleId] : []);

            const quizIdsDetail = quizPosts.map(q => q.id);
            let totalMarksMap = new Map();
            let completionMap = new Map();

            // Only run these queries if there are quizzes
            if (quizIdsDetail.length > 0) {
                const [marksRows] = await connection.query(`
                    SELECT post_id, SUM(marks) AS total_marks
                    FROM quiz_questions
                    WHERE post_id IN (?) AND status = 'active'
                    GROUP BY post_id
                `, [quizIdsDetail]);
                for (const row of marksRows) {
                    totalMarksMap.set(row.post_id, row.total_marks);
                }

                const [completionRows] = await connection.query(`
                    SELECT post_id, score
                    FROM user_quiz_completion
                    WHERE user_id = ? AND post_id IN (?)
                `, [userId, quizIdsDetail]);
                for (const row of completionRows) {
                    completionMap.set(row.post_id, row.score);
                }
            }

            const assessments = quizPosts.map(quiz => {
                const total = totalMarksMap.get(quiz.id) || 0;
                const score = completionMap.get(quiz.id) || 0;
                const percentage = total > 0 ? parseFloat(((score / total) * 100).toFixed(2)) : 0;
                return {
                    post_id: quiz.id,
                    title: quiz.title,
                    score: score,
                    total_marks: total,
                    percentage: percentage,
                    completed: completionMap.has(quiz.id)
                };
            });

            userDetails = {
                mycourse: mycourseDetails,
                certificates: certificates,
                assessments: assessments
            };
        }

        // ============================================================
        // 6. BUILD FINAL RESPONSE
        // ============================================================
        const responseData = {
            mycourse: {
                total_courses_available: totalCoursesForGroup,
                avg_completion_percentage: parseFloat(avgCoursePct.toFixed(2))
            },
            mycourse_certified: {
                total_courses_available: totalCoursesForGroup,
                avg_completion_percentage: parseFloat(avgCoursePct.toFixed(2))
            },
            Assessment: {
                total_Assessment_available: totalQuizzesForGroup,
                avg_completion_percentage: parseFloat(avgQuizPct.toFixed(2)),
                user_completed_assessment: userCompletedQuizzes
            },
            quiz_score: {
                quizzes_average_total_score: avgMaxPerQuiz.toFixed(2),
                avg_score_percentage: parseFloat(avgScorePct.toFixed(2)),
                users_quiz_average__score: avgScorePerCompletion.toFixed(2)
            },
            assessment_breakup: assessmentBreakup
        };

        if (userId) {
            responseData.mycourse.user_completed_courses = userCompletedCourses;
            responseData.mycourse_certified.user_completed_courses = userCompletedCourses;
            responseData.user_details = userDetails;
        }

        res.json({
            success: true,
            data: responseData
        });

    } catch (error) {
        console.error('Learning progress error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        if (connection) connection.release();
    }
};


exports.getUserContentPreferences = async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();
        const { zone, dealer, city, role, user } = req.query;

        // Resolve IDs
        let dealerId = null, roleId = null, cityId = null, userId = null;
        if (dealer) {
            const [rows] = await connection.query('SELECT id FROM dealers WHERE dealer_name = ? AND status = "active"', [dealer]);
            if (rows.length) dealerId = rows[0].id;
        }
        if (role) {
            const [rows] = await connection.query('SELECT id FROM roles WHERE name = ? AND status = "active"', [role]);
            if (rows.length) roleId = rows[0].id;
        }
        if (city) {
            const [rows] = await connection.query('SELECT id FROM cities WHERE city_name = ? AND status = "active"', [city]);
            if (rows.length) cityId = rows[0].id;
        }
        if (user) {
            const [rows] = await connection.query('SELECT id FROM users WHERE name = ? AND status = "active"', [user]);
            if (rows.length) userId = rows[0].id;
        }

        // Build user filter conditions
        const userFilters = [], filterParams = [];
        if (zone) { userFilters.push('d.zone = ?'); filterParams.push(zone); }
        if (dealerId) { userFilters.push('u.dealer_id = ?'); filterParams.push(dealerId); }
        if (cityId) { userFilters.push('u.city_id = ?'); filterParams.push(cityId); }
        if (roleId) { userFilters.push('u.role_id = ?'); filterParams.push(roleId); }
        if (userId) { userFilters.push('u.id = ?'); filterParams.push(userId); }
        const userWhere = userFilters.length ? 'AND ' + userFilters.join(' AND ') : '';

        // 1. Total users in filtered set
        const [[{ totalUsers }]] = await connection.query(`
            SELECT COUNT(DISTINCT u.id) AS totalUsers
            FROM users u
            LEFT JOIN dealers d ON u.dealer_id = d.id
            WHERE u.status = 'active' ${userWhere}
        `, filterParams);

        if (totalUsers === 0) {
            return res.json({
                success: true,
                data: { total_users: 0, preferences: [] }
            });
        }

        // 2. Get total items per media type (optionally role‑aware)
        let mediaFilter = '';
        const mediaParams = [];
        if (roleId) {
            mediaFilter = 'WHERE role_id = ?';
            mediaParams.push(roleId);
        }
        const [totalItems] = await connection.query(`
            SELECT media_type, COUNT(*) AS total
            FROM post_media
            ${mediaFilter}
            GROUP BY media_type
        `, mediaParams);

        // 3. For each media type, get the total number of views (user-item pairs) from the filtered users
        // Build inner conditions with user filter
        let viewWhere = 'u.status = "active"';
        const viewParams = [];
        if (zone) { viewWhere += ' AND d.zone = ?'; viewParams.push(zone); }
        if (dealerId) { viewWhere += ' AND u.dealer_id = ?'; viewParams.push(dealerId); }
        if (cityId) { viewWhere += ' AND u.city_id = ?'; viewParams.push(cityId); }
        if (roleId) { viewWhere += ' AND u.role_id = ?'; viewParams.push(roleId); }
        if (userId) { viewWhere += ' AND u.id = ?'; viewParams.push(userId); }
        // Also filter media by role if provided
        if (roleId) { viewWhere += ' AND pm.role_id = ?'; viewParams.push(roleId); }

        // Query: count views per media_type for the filtered users
        const viewSql = `
            SELECT pm.media_type, COUNT(pmv.id) AS total_views
            FROM post_media_views pmv
            INNER JOIN post_media pm ON pmv.media_id = pm.id
            INNER JOIN users u ON pmv.user_id = u.id
            LEFT JOIN dealers d ON u.dealer_id = d.id
            WHERE ${viewWhere}
            GROUP BY pm.media_type
        `;
        const [viewRows] = await connection.query(viewSql, viewParams);
        const viewsMap = {};
        viewRows.forEach(row => {
            viewsMap[row.media_type] = row.total_views;
        });

        // 4. Build preferences array
        const preferences = [];
        for (const item of totalItems) {
            const mediaType = item.media_type;
            const total = item.total;
            const totalViews = viewsMap[mediaType] || 0;
            const avgItemsViewed = totalViews / totalUsers;
            const avgPercentage = total > 0 ? (avgItemsViewed / total) * 100 : 0;
            preferences.push({
                media_type: mediaType,
                total_items: total,
                avg_items_viewed: parseFloat(avgItemsViewed.toFixed(2)),
                avg_percentage: parseFloat(avgPercentage.toFixed(2))
            });
        }

        preferences.sort((a, b) => b.avg_percentage - a.avg_percentage);

        res.json({
            success: true,
            data: {
                total_users: totalUsers,
                preferences: preferences
            }
        });

    } catch (error) {
        console.error('User content preferences error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        if (connection) connection.release();
    }
};


exports.getHourlyUsage = async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();
        const { zone, dealer, city, role } = req.query;  // <-- user removed

        // ---------- Resolve names to IDs ----------
        let dealerId = null, roleId = null, cityId = null;
        if (dealer) {
            const [rows] = await connection.query(
                'SELECT id FROM dealers WHERE dealer_name = ? AND status = "active"',
                [dealer]
            );
            if (rows.length) dealerId = rows[0].id;
        }
        if (role) {
            const [rows] = await connection.query(
                'SELECT id FROM roles WHERE name = ? AND status = "active"',
                [role]
            );
            if (rows.length) roleId = rows[0].id;
        }
        if (city) {
            const [rows] = await connection.query(
                'SELECT id FROM cities WHERE city_name = ? AND status = "active"',
                [city]
            );
            if (rows.length) cityId = rows[0].id;
        }

        // ---------- Build filter conditions (no user filter) ----------
        const filters = [];
        const filterParams = [];

        if (zone) {
            filters.push('d.zone = ?');
            filterParams.push(zone);
        }
        if (dealerId) {
            filters.push('u.dealer_id = ?');
            filterParams.push(dealerId);
        }
        if (cityId) {
            filters.push('u.city_id = ?');
            filterParams.push(cityId);
        }
        if (roleId) {
            filters.push('u.role_id = ?');
            filterParams.push(roleId);
        }

        const userWhere = filters.length ? 'WHERE ' + filters.join(' AND ') : 'WHERE 1=1';

        // ---------- Query user_daily_activity for the last 7 days ----------
        const query = `
            SELECT 
                u.id AS user_id,
                DATE(da.start_time) AS activity_date,
                HOUR(da.start_time) AS start_hour,
                HOUR(da.end_time) AS end_hour
            FROM user_daily_activity da
            JOIN users u ON da.user_id = u.id
            LEFT JOIN dealers d ON u.dealer_id = d.id
            ${userWhere}
            AND u.status = 'active'
            AND da.start_time >= CURDATE() - INTERVAL 6 DAY
            ORDER BY u.id, da.start_time
        `;

        const [rows] = await connection.query(query, filterParams);

        // ---------- Build 7x24 matrix ----------
        const matrix = Array.from({ length: 7 }, () => Array(24).fill(0));

        rows.forEach(row => {
            const dayOfWeek = new Date(row.activity_date).getDay(); // 0=Sun
            const startHour = row.start_hour;
            const endHour = row.end_hour;
            for (let h = startHour; h <= endHour; h++) {
                matrix[dayOfWeek][h] += 1;
            }
        });

        const maxValue = Math.max(...matrix.flat(), 0);
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const hours = Array.from({ length: 24 }, (_, i) => i);

        res.json({
            success: true,
            data: {
                matrix: matrix,
                max_value: maxValue,
                days: days,
                hours: hours
            }
        });

    } catch (error) {
        console.error('Hourly usage error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        if (connection) connection.release();
    }
};



// ================= GET STATE WISE USAGE =================
exports.getStateWiseUsage = async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const { zone, dealer, city, role } = req.query;

    // ---------- Resolve names to IDs ----------
    let dealerId = null, roleId = null, cityId = null;
    if (dealer) {
      const [rows] = await connection.query(
        'SELECT id FROM dealers WHERE dealer_name = ? AND status = "active"',
        [dealer]
      );
      if (rows.length) dealerId = rows[0].id;
    }
    if (role) {
      const [rows] = await connection.query(
        'SELECT id FROM roles WHERE name = ? AND status = "active"',
        [role]
      );
      if (rows.length) roleId = rows[0].id;
    }
    if (city) {
      const [rows] = await connection.query(
        'SELECT id FROM cities WHERE city_name = ? AND status = "active"',
        [city]
      );
      if (rows.length) cityId = rows[0].id;
    }

    // ---------- Build filter conditions ----------
    const filters = [];
    const filterParams = [];

    if (zone) {
      filters.push('d.zone = ?');
      filterParams.push(zone);
    }
    if (dealerId) {
      filters.push('u.dealer_id = ?');
      filterParams.push(dealerId);
    }
    if (cityId) {
      filters.push('u.city_id = ?');
      filterParams.push(cityId);
    }
    if (roleId) {
      filters.push('u.role_id = ?');
      filterParams.push(roleId);
    }

    const userWhere = filters.length ? 'WHERE ' + filters.join(' AND ') : 'WHERE 1=1';

    // ---------- 1. User counts per state ----------
    const [userCountsByState] = await connection.query(`
      SELECT 
        c.state,
        COUNT(DISTINCT u.id) AS user_count
      FROM users u
      JOIN cities c ON u.city_id = c.id
      LEFT JOIN dealers d ON u.dealer_id = d.id
      ${userWhere}
      AND u.status = 'active'
      GROUP BY c.state
      ORDER BY c.state
    `, filterParams);

    // ---------- 2. Usage counts per state (time periods) ----------
    const now = new Date();
    const yearStart = new Date(now.getFullYear(), 0, 1);
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - now.getDay()); // start of current week (Sunday)

    const [usageData] = await connection.query(`
  SELECT 
    c.state,
    COUNT(pv.id) AS total_usage,
    SUM(CASE WHEN pv.viewed_at >= ? THEN 1 ELSE 0 END) AS ytd_usage,
    SUM(CASE WHEN pv.viewed_at >= ? THEN 1 ELSE 0 END) AS mtd_usage,
    SUM(CASE WHEN pv.viewed_at >= ? THEN 1 ELSE 0 END) AS week_usage,
    GROUP_CONCAT(DISTINCT c.city_name) AS cities          -- 👈 ADD THIS
  FROM post_views pv
  JOIN users u ON pv.user_id = u.id
  JOIN cities c ON u.city_id = c.id
  LEFT JOIN dealers d ON u.dealer_id = d.id
  ${userWhere}
  AND u.status = 'active'
  GROUP BY c.state
  ORDER BY c.state
`, [yearStart, monthStart, weekStart, ...filterParams]);

    // ---------- 3. Build response with state codes ----------
const result = usageData.map(row => ({
  state: row.state,
  code: row.state,
  users: userCountsByState.find(u => u.state === row.state)?.user_count || 0,
  total: row.total_usage || 0,
  ytd: row.ytd_usage || 0,
  mtd: row.mtd_usage || 0,
  week: row.week_usage || 0,
  cities: row.cities || ''   // 👈 ADD THIS
}));

    res.json({
      success: true,
      data: {
        states: result,
        summary: {
          total_users: result.reduce((sum, s) => sum + s.users, 0),
          total_usage: result.reduce((sum, s) => sum + s.total, 0),
          total_ytd: result.reduce((sum, s) => sum + s.ytd, 0),
          total_mtd: result.reduce((sum, s) => sum + s.mtd, 0),
          total_week: result.reduce((sum, s) => sum + s.week, 0)
        }
      }
    });

  } catch (error) {
    console.error('State wise usage error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  } finally {
    if (connection) connection.release();
  }
};
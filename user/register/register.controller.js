const { pool } = require('../../config/db');

exports.register = async (req, res) => {
    try {
        const { email, employee_id, name, role } = req.body;

        // Validate required fields
        if (!email || !employee_id || !name) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email, employee_id, and name are required' 
            });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ 
                success: false, 
                error: 'Invalid email format' 
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if user already exists
            const [existingUsers] = await connection.query(
                'SELECT id, email, employee_id, status FROM users WHERE email = ? OR employee_id = ?',
                [email, employee_id]
            );

            if (existingUsers.length > 0) {
                const user = existingUsers[0];
                if (user.email === email) {
                    return res.status(409).json({ 
                        success: false, 
                        error: 'Email already registered' 
                    });
                }
                if (user.employee_id === employee_id) {
                    return res.status(409).json({ 
                        success: false, 
                        error: 'Employee ID already exists' 
                    });
                }
            }

            // Insert new user with default role 'user'
            const [result] = await connection.query(
                'INSERT INTO users (email, employee_id, name, status, role) VALUES (?, ?, ?, "active", ?)',
                [email, employee_id, name, role]
            );

            res.status(201).json({
                success: true,
                message: 'User registered successfully. You can now login.',
                data: {
                    user_id: result.insertId,
                    email: email,
                    employee_id: employee_id,
                    name: name,
                    role: role
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error' 
        });
    }
};
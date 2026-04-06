const { pool } = require('../../config/db');
const { hashPassword } = require('../../services/password.service');

exports.register = async (req, res) => {
    try {
        const { email, employee_id, name, role, password } = req.body;

        // Validate required fields
        if (!email || !employee_id || !name || !password) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email, employee_id, name, and password are required' 
            });
        }

        // Validate password strength
        if (password.length < 6) {
            return res.status(400).json({ 
                success: false, 
                error: 'Password must be at least 6 characters long' 
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

            // Hash password using service
            const hashedPassword = await hashPassword(password);

            // Insert new user
            const [result] = await connection.query(
                'INSERT INTO users (email, employee_id, name, password, status, role) VALUES (?, ?, ?, ?, "active", ?)',
                [email, employee_id, name, hashedPassword, role || 'user']
            );

            res.status(201).json({
                success: true,
                message: 'User registered successfully. You can now login.',
                data: {
                    user_id: result.insertId,
                    email: email,
                    employee_id: employee_id,
                    name: name,
                    role: role || 'user'
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
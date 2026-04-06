const bcrypt = require('bcrypt');
const { pool } = require('../../config/db');
const JWTUtils = require('../../utils/jwt.util');

// User Login with email and password
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                error: 'Email and password are required'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Get user by email (only regular users, not admins)
            const [users] = await connection.query(
                `SELECT id, email, employee_id, name, password, role, status 
                 FROM users 
                 WHERE email = ? AND role NOT IN ('admin', 'super_admin')`,
                [email]
            );

            if (users.length === 0) {
                return res.status(401).json({
                    success: false,
                    error: 'Invalid email or password'
                });
            }

            const user = users[0];

            // Check user status
            if (user.status === 'inactive') {
                return res.status(403).json({
                    success: false,
                    error: 'Your account is inactive. Please contact admin.'
                });
            }

            // Verify password
            const isPasswordValid = await bcrypt.compare(password, user.password);
            if (!isPasswordValid) {
                return res.status(401).json({
                    success: false,
                    error: 'Invalid email or password'
                });
            }

            // Remove password from user object
            delete user.password;

            // Generate token with isAdmin: false
            const tokenPayload = {
                userId: user.id,
                email: user.email,
                name: user.name,
                employee_id: user.employee_id,
                role: user.role,
                isAdmin: false  // Regular user, not admin
            };

            const token = JWTUtils.generateToken(tokenPayload);

            res.json({
                success: true,
                message: 'Login successful',
                token: token,
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('User login error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
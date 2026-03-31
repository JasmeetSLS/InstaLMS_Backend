const bcrypt = require('bcrypt');
const { pool } = require('../../config/db');
const JWTUtils = require('../../utils/jwt.util');

// Admin Login
exports.adminLogin = async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({
                success: false,
                error: 'Username and password are required'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Get admin by username
            const [admins] = await connection.query(
                'SELECT id, username, email, password, role, status FROM admins WHERE username = ?',
                [username]
            );

            if (admins.length === 0) {
                return res.status(401).json({
                    success: false,
                    error: 'Invalid username or password'
                });
            }

            const admin = admins[0];

            // Check admin status
            if (admin.status === 'inactive') {
                return res.status(403).json({
                    success: false,
                    error: 'Your admin account is inactive'
                });
            }

            // Verify password
            const isPasswordValid = await bcrypt.compare(password, admin.password);
            if (!isPasswordValid) {
                return res.status(401).json({
                    success: false,
                    error: 'Invalid username or password'
                });
            }

            // Generate token with admin flag
            const tokenPayload = {
                userId: admin.id,
                username: admin.username,
                email: admin.email,
                role: admin.role,
                isAdmin: true
            };

            const token = JWTUtils.generateToken(tokenPayload);

            res.json({
                success: true,
                message: 'Admin login successful',
                token: token
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Admin login error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
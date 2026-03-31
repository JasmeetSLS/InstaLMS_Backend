const { pool } = require('../../config/db');
const { sendOTPEmail } = require('../../utils/email.util');
const { generateOTP, saveOTP, verifyOTP } = require('../../services/otp.service');
const JWTUtils = require('../../utils/jwt.util');

// Send OTP for login
exports.sendLoginOTP = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email is required' 
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if user exists
            const [users] = await connection.query(
                'SELECT id, email, name, status FROM users WHERE email = ?',
                [email]
            );

            if (users.length === 0) {
                return res.status(404).json({ 
                    success: false, 
                    error: 'User not found. Please register first.' 
                });
            }

            const user = users[0];

            // Check user status (only active/inactive)
            if (user.status === 'inactive') {
                return res.status(403).json({ 
                    success: false, 
                    error: 'Your account is inactive. Please contact admin.' 
                });
            }

            // Generate and save OTP with user_id
            const otp = generateOTP();
            await saveOTP(user.id, otp);

            // Send OTP to email
            const emailSent = await sendOTPEmail(email, otp, user.name);

            if (!emailSent) {
                return res.status(500).json({ 
                    success: false, 
                    error: 'Failed to send OTP email' 
                });
            }

            res.json({
                success: true,
                message: 'OTP sent successfully to your email',
                data: {
                    email: email,
                    expires_in: '10 minutes'
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Send OTP error:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error' 
        });
    }
};

// Verify OTP and login
exports.verifyOTPLogin = async (req, res) => {
    try {
        const { email, otp } = req.body;

        if (!email || !otp) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email and OTP are required' 
            });
        }

        const connection = await pool.getConnection();

        try {
            // Get user details first
            const [users] = await connection.query(
                `SELECT 
                    u.id, 
                    u.email, 
                    u.employee_id, 
                    u.name, 
                    u.status 
                 FROM users u 
                 WHERE u.email = ?`,
                [email]
            );

            if (users.length === 0) {
                return res.status(404).json({ 
                    success: false, 
                    error: 'User not found' 
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

            // Verify OTP for this user
            const isValid = await verifyOTP(user.id, otp);

            if (!isValid) {
                return res.status(401).json({ 
                    success: false, 
                    error: 'Invalid or expired OTP' 
                });
            }

            // Generate JWT token with ONLY user ID
        const tokenPayload = {
    userId: user.id,
    email: user.email,
    name: user.name,
    employee_id: user.employee_id
};

            const token = JWTUtils.generateToken(tokenPayload);

           res.json({
    success: true,
    message: 'Login successful',
    token: token
});

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Verify OTP error:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error' 
        });
    }
};

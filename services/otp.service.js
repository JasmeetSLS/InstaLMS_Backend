const { pool } = require('../config/db');

// Generate random 6-digit OTP
 exports.generateOTP = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

// Save OTP to database with user_id
exports.saveOTP = async (userId, otp) => {
    const connection = await pool.getConnection();
    try {
        // Insert new OTP (all OTPs are stored)
        await connection.query(
            'INSERT INTO otps (user_id, otp_code, is_verified, expires_at) VALUES (?, ?, 0, DATE_ADD(NOW(), INTERVAL 10 MINUTE))',
            [userId, otp]
        );
        
        // Log OTP to console for testing
        console.log('=========================================');
        console.log(`📧 OTP for user ID ${userId}: ${otp}`);
        console.log('=========================================');
        
        return true;
    } catch (error) {
        console.error('Save OTP error:', error);
        return false;
    } finally {
        connection.release();
    }
};

// Verify OTP and mark as verified
exports.verifyOTP = async (userId, otp) => {
    const connection = await pool.getConnection();
    try {
        // Find valid OTP
        const [rows] = await connection.query(
            'SELECT id FROM otps WHERE user_id = ? AND otp_code = ? AND is_verified = 0 AND expires_at > NOW()',
            [userId, otp]
        );
        
        if (rows.length > 0) {
            // Mark this OTP as verified
            await connection.query(
                'UPDATE otps SET is_verified = 1 WHERE id = ?',
                [rows[0].id]
            );
            return true;
        }
        return false;
    } catch (error) {
        console.error('Verify OTP error:', error);
        return false;
    } finally {
        connection.release();
    }
};

const nodemailer = require('nodemailer');
require('dotenv').config();

// Create transporter for Rediffmail Pro
const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false, // false for 587
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    },
    // Rediffmail Pro specific settings
    name: 'mail.rediffmailpro.com', // Explicit HELO name (use the mail server domain)
    requireTLS: true,
    tls: {
        ciphers: 'SSLv3',
        rejectUnauthorized: false
    },
    connectionTimeout: 30000,
    greetingTimeout: 30000,
    socketTimeout: 30000,
    debug: true
});

exports.sendOTPEmail = async (email, otp, name) => {
    try {
        const mailOptions = {
            from: `"InstaStyle LMS" <${process.env.EMAIL_USER}>`,
            to: email,
            subject: 'Your OTP for Login - InstaStyle LMS',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <h2 style="color: #333;">Welcome ${name}!</h2>
                    <p>Your OTP for verification is:</p>
                    <div style="background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 32px; letter-spacing: 5px; font-weight: bold;">
                        ${otp}
                    </div>
                    <p>This OTP is valid for 10 minutes.</p>
                    <p>If you didn't request this, please ignore this email.</p>
                    <hr>
                    <p style="color: #666; font-size: 12px;">This is an automated message, please do not reply.</p>
                </div>
            `
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('Email sent:', info.messageId);
        return true;
    } catch (error) {
        console.error('Email send error:', error);
        return false;
    }
};

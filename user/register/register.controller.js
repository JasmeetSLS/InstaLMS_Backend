const { pool } = require('../../config/db');
const { hashPassword } = require('../../services/password.service');
const path = require('path');
const fs = require('fs');

// Updated register function with phone and gender
exports.register = async (req, res) => {
    try {
        const { email, employee_id, name, phone, gender, role_id, dealer_id, password } = req.body;
        const profileFile = req.file; // Get profile image if uploaded

        // Validate required fields
        if (!email || !employee_id || !name || !password || !role_id) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email, employee_id, name, password, and role_id are required' 
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

        // Validate phone if provided
        if (phone && !/^[0-9]{10}$/.test(phone)) {
            return res.status(400).json({ 
                success: false, 
                error: 'Invalid phone number. Must be 10 digits' 
            });
        }

        // Validate gender if provided
        if (gender && !['male', 'female'].includes(gender)) {
            return res.status(400).json({ 
                success: false, 
                error: 'Gender must be male or female' 
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

            // Insert new user with role_id and dealer_id
            const [result] = await connection.query(
                'INSERT INTO users (email, employee_id, name, phone, gender, password, role_id, dealer_id, status, profile_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, "active", ?)',
                [email, employee_id, name, phone || null, gender || null, hashedPassword, role_id, dealer_id || null, null]
            );

            const userId = result.insertId;
            let profileUrl = null;

            // Handle profile picture upload if provided
            if (profileFile) {
                // Create user profile folder
                const userDir = path.join('uploads', 'users', userId.toString());
                if (!fs.existsSync(userDir)) {
                    fs.mkdirSync(userDir, { recursive: true });
                }

                // Get file extension
                const ext = path.extname(profileFile.originalname);
                const filename = `profile-${Date.now()}${ext}`;
                const newPath = path.join(userDir, filename);

                // Move file from temp to user folder
                fs.renameSync(profileFile.path, newPath);
                profileUrl = `/uploads/users/${userId}/${filename}`;

                // Update user with profile URL
                await connection.query(
                    'UPDATE users SET profile_url = ? WHERE id = ?',
                    [profileUrl, userId]
                );
            }

            res.status(201).json({
                success: true,
                message: 'User registered successfully. You can now login.',
                data: {
                    user_id: userId,
                    email: email,
                    employee_id: employee_id,
                    name: name,
                    phone: phone || null,
                    gender: gender || null,
                    role_id: role_id,
                    dealer_id: dealer_id || null,
                    profile_url: profileUrl
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
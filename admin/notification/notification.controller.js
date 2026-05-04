const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');

// Create notification
exports.createNotification = async (req, res) => {
    try {
        const { title, message } = req.body;
        const image = req.file;

        if (!title || !message) {
            return res.status(400).json({
                success: false,
                error: 'Title and message are required'
            });
        }

        const connection = await pool.getConnection();

        // Insert notification
        const [result] = await connection.query(
            `INSERT INTO notifications (title, message, image_url) 
             VALUES (?, ?, ?)`,
            [title, message, null]
        );

        let imageUrl = null;
        
        // Upload image if exists
        if (image) {
            const dir = `uploads/notifications/${result.insertId}`;
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
            
            // Use original file name
            const originalName = image.originalname;
            const newPath = `${dir}/${originalName}`;
            fs.renameSync(image.path, newPath);
            
            imageUrl = `/uploads/notifications/${result.insertId}/${originalName}`;
            
            await connection.query(
                'UPDATE notifications SET image_url = ? WHERE id = ?',
                [imageUrl, result.insertId]
            );
        }

        connection.release();

        res.status(201).json({
            success: true,
            message: 'Notification created successfully',
            data: { 
                id: result.insertId, 
                title, 
                message, 
                image_url: imageUrl 
            }
        });

    } catch (error) {
        // Clean up uploaded file if error occurs
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        console.error('Create notification error:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
};

// Get all notifications
exports.getNotifications = async (req, res) => {
    try {
        const [notifications] = await pool.query(
            `SELECT id, title, message, image_url, created_at
             FROM notifications 
             ORDER BY created_at DESC
             LIMIT 50`
        );
        
        res.status(200).json({
            success: true,
            data: notifications
        });
    } catch (error) {
        console.error('Get notifications error:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
};

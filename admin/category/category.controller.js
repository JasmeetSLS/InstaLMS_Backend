const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');
const { sendNotificationToAllUsers } = require('../../services/notification.service');

exports.createCategory = async (req, res) => {
    try {
        const { name } = req.body;
        const icon = req.file;

        if (!name) {
            return res.status(400).json({
                success: false,
                error: 'Category name is required'
            });
        }

        const connection = await pool.getConnection();

        try {

            const [existing] = await connection.query(
                'SELECT id FROM categories WHERE name = ?',
                [name]
            );

            if (existing.length > 0) {
                return res.status(409).json({
                    success: false,
                    error: 'Category already exists'
                });
            }

            const [result] = await connection.query(
                'INSERT INTO categories (name, icon_url) VALUES (?, ?)',
                [name, null]
            );

            const categoryId = result.insertId;

            let iconUrl = null;

            if (icon) {

                const categoryDir = path.join(
                    'uploads',
                    'category',
                    categoryId.toString()
                );

                if (!fs.existsSync(categoryDir)) {
                    fs.mkdirSync(categoryDir, { recursive: true });
                }

                const filename = icon.filename;

                const newPath = path.join(
                    categoryDir,
                    filename
                );

                fs.renameSync(icon.path, newPath);

                iconUrl = `/uploads/category/${categoryId}/${filename}`;

                await connection.query(
                    'UPDATE categories SET icon_url=? WHERE id=?',
                    [iconUrl, categoryId]
                );

            }

            // Return response immediately
            res.status(201).json({
                success: true,
                message: 'Category created successfully',
                data: {
                    id: categoryId,
                    name,
                    icon_url: iconUrl
                }
            });

            // Send push notification in background
            sendNotificationToAllUsers(
                '📚 New Category',
                `${name} category has been added.`,
                {
                    type: 'category',
                    categoryId: categoryId.toString(),
                    categoryName: name
                }
            ).catch(err => {
                console.error('Push Notification Error:', err);
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error(error);

        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Get all categories
exports.getAllCategories = async (req, res) => {
    try {
        const connection = await pool.getConnection();

        try {
            const [categories] = await connection.query(
                'SELECT id, name, icon_url, status, created_at FROM categories ORDER BY id ASC'
            );

            res.json({
                success: true,
                data: categories
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get categories error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};


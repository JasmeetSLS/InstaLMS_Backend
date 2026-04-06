const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');

// Create a new category
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
            // Check if category exists
            const [existing] = await connection.query(
                'SELECT id FROM categories WHERE name = ?',
                [name]
            );

            if (existing.length > 0) {
                return res.status(409).json({
                    success: false,
                    error: 'Category name already exists'
                });
            }

            // Insert category first
            const [result] = await connection.query(
                'INSERT INTO categories (name, icon_url) VALUES (?, ?)',
                [name, null]
            );

            const categoryId = result.insertId;

            // Handle icon upload if provided
            let iconUrl = null;
            if (icon) {
                // Create category folder
                const categoryDir = path.join('uploads', 'category', categoryId.toString());
                if (!fs.existsSync(categoryDir)) {
                    fs.mkdirSync(categoryDir, { recursive: true });
                }

                // Get file extension
                const ext = path.extname(icon.originalname);
                const filename = icon.filename;
                const newPath = path.join(categoryDir, filename);

                // Move file to category folder
                fs.renameSync(icon.path, newPath);
                iconUrl = `/uploads/category/${categoryId}/${filename}`;

                // Update category with icon URL
                await connection.query(
                    'UPDATE categories SET icon_url = ? WHERE id = ?',
                    [iconUrl, categoryId]
                );
            }

            res.status(201).json({
                success: true,
                message: 'Category created successfully',
                data: {
                    id: categoryId,
                    name: name,
                    icon_url: iconUrl
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create category error:', error);
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
                'SELECT id, name, icon_url, status, created_at FROM categories ORDER BY created_at DESC'
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


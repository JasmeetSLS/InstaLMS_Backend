const { pool } = require('../../../config/db');
const fs = require('fs');
const path = require('path');

// Create a new CMS category
exports.createCmsCategory = async (req, res) => {
    try {
        const { title, content } = req.body;  // <-- status removed
        const icon = req.file;

        if (!title) {
            return res.status(400).json({
                success: false,
                error: 'Title is required'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check for duplicate title
            const [existing] = await connection.query(
                'SELECT id FROM cms_categories WHERE title = ?',
                [title]
            );

            if (existing.length > 0) {
                return res.status(409).json({
                    success: false,
                    error: 'CMS category with this title already exists'
                });
            }

            // Always set status to 'active'
            const [result] = await connection.query(
                `INSERT INTO cms_categories 
                 (title, content, status, icon_url) 
                 VALUES (?, ?, ?, ?)`,
                [title, content || null, 'active', null]  // <-- hardcoded 'active'
            );

            const categoryId = result.insertId;
            let iconUrl = null;

            // Handle icon upload if provided
            if (icon) {
                const categoryDir = path.join('uploads', 'cmscategory', categoryId.toString());
                if (!fs.existsSync(categoryDir)) {
                    fs.mkdirSync(categoryDir, { recursive: true });
                }

                const ext = path.extname(icon.originalname);
                const filename = icon.filename;
                const newPath = path.join(categoryDir, filename);

                fs.renameSync(icon.path, newPath);
                iconUrl = `/uploads/cmscategory/${categoryId}/${filename}`;

                await connection.query(
                    'UPDATE cms_categories SET icon_url = ? WHERE id = ?',
                    [iconUrl, categoryId]
                );
            }

            res.status(201).json({
                success: true,
                message: 'CMS category created successfully',
                data: {
                    id: categoryId,
                    title,
                    content,
                    status: 'active',  // always active
                    icon_url: iconUrl
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create CMS category error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Get all CMS categories
exports.getAllCmsCategories = async (req, res) => {
    try {
        const connection = await pool.getConnection();

        try {
            const [categories] = await connection.query(
                `SELECT id, title, icon_url, content, status, 
                        created_at, updated_at 
                 FROM cms_categories 
                 ORDER BY id ASC`
            );

            res.json({
                success: true,
                data: categories
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get CMS categories error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
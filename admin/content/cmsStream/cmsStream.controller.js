const path = require('path');
const fs = require('fs');
const { pool } = require('../../../config/db');

exports.createStream = async (req, res) => {
    try {
        // status and sort_order are NOT taken from req.body
        const { category_id, title, language, content } = req.body;
        const icon = req.file;

        // Validation
        if (!category_id || isNaN(category_id)) {
            return res.status(400).json({
                success: false,
                error: 'Valid category ID is required'
            });
        }

        if (!title || !title.trim()) {
            return res.status(400).json({
                success: false,
                error: 'Title is required'
            });
        }

        if (!language || !language.trim()) {
            return res.status(400).json({
                success: false,
                error: 'Language is required'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Verify category exists and is active
            const [category] = await connection.query(
                'SELECT id FROM cms_categories WHERE id = ? AND status = "active"',
                [category_id]
            );

            if (category.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found or inactive'
                });
            }

            // Check duplicate title
            const [existing] = await connection.query(
                'SELECT id FROM cms_streams WHERE category_id = ? AND title = ?',
                [category_id, title.trim()]
            );

            if (existing.length > 0) {
                return res.status(409).json({
                    success: false,
                    error: 'A stream with this title already exists in this category'
                });
            }

            // Insert with hardcoded active and 0
            const [result] = await connection.query(
                `INSERT INTO cms_streams 
                 (category_id, title, language, content, icon_url, status, sort_order) 
                 VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [category_id, title.trim(), language.trim(), content || null, null, 'active', 0]
            );

            const streamId = result.insertId;
            let iconUrl = null;

            // Handle icon upload if provided
            if (icon) {
                const streamDir = path.join('uploads', 'cmsstream', streamId.toString());
                if (!fs.existsSync(streamDir)) {
                    fs.mkdirSync(streamDir, { recursive: true });
                }

                const filename = `${Date.now()}_${icon.originalname.replace(/\s+/g, '_')}`;
                const newPath = path.join(streamDir, filename);

                fs.renameSync(icon.path, newPath);
                iconUrl = `/uploads/cmsstream/${streamId}/${filename}`;

                await connection.query(
                    'UPDATE cms_streams SET icon_url = ? WHERE id = ?',
                    [iconUrl, streamId]
                );
            }

            // Return basic data (no extra counts query)
            res.status(201).json({
                success: true,
                message: 'Stream created successfully',
                data: {
                    id: streamId,
                    category_id: parseInt(category_id),
                    title: title.trim(),
                    language: language.trim(),
                    content: content || null,
                    icon_url: iconUrl,
                    status: 'active',
                    sort_order: 0
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create stream error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Get streams by category ID
exports.getStreamsByCategory = async (req, res) => {
    try {
        const { categoryId } = req.params;

        if (!categoryId || isNaN(categoryId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid category ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Verify the category exists and is active
            const [categoryCheck] = await connection.query(
                'SELECT id FROM cms_categories WHERE id = ? AND status = "active"',
                [categoryId]
            );

            if (categoryCheck.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found or inactive'
                });
            }

            // Fetch streams with counts of sections, contents, and questions
            const [streams] = await connection.query(
                `SELECT 
                    s.id,
                    s.title,
                    s.language,
                    s.icon_url,
                    s.content,
                    s.status,
                    s.sort_order,
                    s.created_at,
                    s.updated_at,
                    (SELECT COUNT(*) FROM cms_sections WHERE stream_id = s.id AND status = 'active') AS sections_count,
                    (SELECT COUNT(*) FROM cms_contents WHERE section_id IN 
                        (SELECT id FROM cms_sections WHERE stream_id = s.id) AND status = 'active') AS contents_count,
                    (SELECT COUNT(*) FROM cms_questions WHERE section_id IN 
                        (SELECT id FROM cms_sections WHERE stream_id = s.id)) AS questions_count
                FROM cms_streams s
                WHERE s.category_id = ? AND s.status = 'active'
                ORDER BY s.sort_order ASC, s.id ASC`,
                [categoryId]
            );

            res.json({
                success: true,
                data: streams
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get streams by category error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
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
// Get streams by category ID with optional search
exports.getStreamsByCategory = async (req, res) => {
    try {
        const { categoryId } = req.params;
        const { search } = req.query; // e.g., ?search=design

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

            // Base query with counts
            let query = `
                SELECT 
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
            `;
            const params = [categoryId];

            // Add search condition if provided
            if (search && search.trim() !== '') {
                query += ` AND (s.title LIKE ? OR s.language LIKE ? OR s.content LIKE ?)`;
                const like = `%${search.trim()}%`;
                params.push(like, like, like);
            }

            query += ` ORDER BY s.sort_order ASC, s.id ASC`;

            const [streams] = await connection.query(query, params);

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

exports.getStreamById = async (req, res) => {
    try {
        const { streamId } = req.params;
        if (!streamId || isNaN(streamId)) {
            return res.status(400).json({ success: false, error: 'Valid stream ID required' });
        }

        const connection = await pool.getConnection();
        try {
            const [rows] = await connection.query(
                `SELECT id, title, language, content, icon_url
                 FROM cms_streams
                 WHERE id = ?`,
                [streamId]
            );
            if (rows.length === 0) {
                return res.status(404).json({ success: false, error: 'Stream not found' });
            }
            res.json({ success: true, data: rows[0] });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Get stream error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

exports.updateStream = async (req, res) => {
    try {
        const { streamId } = req.params;
        const { title, language, content } = req.body;
        const icon = req.file;

        if (!streamId || isNaN(streamId)) {
            return res.status(400).json({ success: false, error: 'Valid stream ID required' });
        }

        const connection = await pool.getConnection();
        try {
            // Check existence
            const [existing] = await connection.query('SELECT * FROM cms_streams WHERE id = ?', [streamId]);
            if (existing.length === 0) {
                return res.status(404).json({ success: false, error: 'Stream not found' });
            }

            const updates = [];
            const values = [];

            // Only add fields if provided
            if (title !== undefined && title.trim()) {
                // Check duplicate title in the same category (category stays unchanged)
                const catId = existing[0].category_id;
                const [dup] = await connection.query(
                    'SELECT id FROM cms_streams WHERE category_id = ? AND title = ? AND id != ?',
                    [catId, title.trim(), streamId]
                );
                if (dup.length > 0) {
                    return res.status(409).json({ success: false, error: 'A stream with this title already exists in this category' });
                }
                updates.push('title = ?');
                values.push(title.trim());
            }

            if (language !== undefined && language.trim()) {
                updates.push('language = ?');
                values.push(language.trim());
            }

            if (content !== undefined) {
                updates.push('content = ?');
                values.push(content || null); // allow clearing content
            }

            // Handle icon upload if file provided
            let iconUrl = existing[0].icon_url;
            if (icon) {
                const streamDir = path.join('uploads', 'cmsstream', streamId.toString());
                if (!fs.existsSync(streamDir)) fs.mkdirSync(streamDir, { recursive: true });
                // Remove old icon if exists
                if (iconUrl) {
                    const oldPath = path.join(__dirname, '../../../', iconUrl);
                    if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
                }
                const filename = `${Date.now()}_${icon.originalname.replace(/\s+/g, '_')}`;
                const newPath = path.join(streamDir, filename);
                fs.renameSync(icon.path, newPath);
                iconUrl = `/uploads/cmsstream/${streamId}/${filename}`;
                updates.push('icon_url = ?');
                values.push(iconUrl);
            }

            // If no fields to update
            if (updates.length === 0 && !icon) {
                return res.json({ success: true, message: 'No changes provided', data: existing[0] });
            }

            // Execute update
            const query = `UPDATE cms_streams SET ${updates.join(', ')} WHERE id = ?`;
            values.push(streamId);
            await connection.query(query, values);

            // Fetch updated record (only needed fields)
            const [updated] = await connection.query(
                `SELECT id, title, language, content, icon_url
                 FROM cms_streams WHERE id = ?`,
                [streamId]
            );
            res.json({ success: true, message: 'Stream updated successfully', data: updated[0] });

        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Update stream error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};
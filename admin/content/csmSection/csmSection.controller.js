const { pool } = require('../../../config/db');

// cmsSection.controller.js

exports.createSection = async (req, res) => {
    try {
        const { stream_id, title, description } = req.body;

        // Validation
        if (!stream_id || isNaN(stream_id)) {
            return res.status(400).json({
                success: false,
                error: 'Valid stream ID is required'
            });
        }

        if (!title || !title.trim()) {
            return res.status(400).json({
                success: false,
                error: 'Title is required'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Verify stream exists and is active
            const [streamCheck] = await connection.query(
                'SELECT id FROM cms_streams WHERE id = ? AND status = "active"',
                [stream_id]
            );

            if (streamCheck.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Stream not found or inactive'
                });
            }

            // Check for duplicate title within the same stream
            const [existing] = await connection.query(
                'SELECT id FROM cms_sections WHERE stream_id = ? AND title = ?',
                [stream_id, title.trim()]
            );

            if (existing.length > 0) {
                return res.status(409).json({
                    success: false,
                    error: 'A section with this title already exists in this stream'
                });
            }

            // Insert section – hardcode status and sort_order
            const [result] = await connection.query(
                `INSERT INTO cms_sections 
                 (stream_id, title, description, status, sort_order) 
                 VALUES (?, ?, ?, ?, ?)`,
                [stream_id, title.trim(), description || null, 'active', 0]
            );

            const sectionId = result.insertId;

            // Fetch the newly created section
            const [newSection] = await connection.query(
                `SELECT 
                    id, stream_id, title, description, status, sort_order,
                    created_at, updated_at
                FROM cms_sections
                WHERE id = ?`,
                [sectionId]
            );

            res.status(201).json({
                success: true,
                message: 'Section created successfully',
                data: newSection[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create section error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

exports.getSectionsByStream = async (req, res) => {
    try {
        const { streamId } = req.params;

        if (!streamId || isNaN(streamId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid stream ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Verify stream exists and is active
            const [streamCheck] = await connection.query(
                'SELECT id FROM cms_streams WHERE id = ? AND status = "active"',
                [streamId]
            );

            if (streamCheck.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Stream not found or inactive'
                });
            }

            // Fetch sections with counts of contents and questions (formerly assessments)
            const [sections] = await connection.query(
                `SELECT 
                    s.id,
                    s.title,
                    s.description,
                    s.status,
                    s.sort_order,
                    s.created_at,
                    s.updated_at,
                    (SELECT COUNT(*) FROM cms_contents WHERE section_id = s.id AND status = 'active') AS contents_count,
                    (SELECT COUNT(*) FROM cms_questions WHERE section_id = s.id) AS assessments_count
                FROM cms_sections s
                WHERE s.stream_id = ? AND s.status = 'active'
                ORDER BY s.sort_order ASC, s.id ASC`,
                [streamId]
            );

            res.json({
                success: true,
                data: sections
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get sections by stream error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');

// Create CMS page
exports.createCMSPage = async (req, res) => {
    try {
        const { title, slug, content } = req.body;
        const image = req.file;

        if (!title || !slug) {
            return res.status(400).json({
                success: false,
                error: 'Title and slug required'
            });
        }

        const connection = await pool.getConnection();

        // Insert page with status always active
        const [result] = await connection.query(
            `INSERT INTO cms_pages (title, slug, content, status) 
             VALUES (?, ?, ?, 'active')`,
            [title, slug, content || null]
        );

        let imageUrl = null;
        
        // Upload image if exists
        if (image) {
            const dir = `uploads/cms/${result.insertId}`;
            if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
            
            // Use original file name
            const originalName = image.originalname;
            const newPath = `${dir}/${originalName}`;
            fs.renameSync(image.path, newPath);
            
            imageUrl = `/uploads/cms/${result.insertId}/${originalName}`;
            
            await connection.query(
                'UPDATE cms_pages SET image_url = ? WHERE id = ?',
                [imageUrl, result.insertId]
            );
        }

        connection.release();

        res.status(201).json({
            success: true,
            message: 'CMS page created',
            data: { id: result.insertId, image_url: imageUrl }
        });

    } catch (error) {
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
};

// Get all CMS pages
exports.getAllCMSPages = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        
        const [pages] = await connection.query(
            `SELECT id, title, slug, content, image_url, status, created_at, updated_at 
             FROM cms_pages 
             WHERE status = 'active'
             ORDER BY id DESC`
        );
        
        connection.release();
        
        res.status(200).json({
            success: true,
            total: pages.length,
            data: pages
        });
        
    } catch (error) {
        console.error('Error fetching CMS pages:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
};
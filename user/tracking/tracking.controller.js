// controllers/media.controller.js
const { pool } = require('../../config/db');

// Track image view
exports.trackImageView = async (req, res) => {
    try {
        const { media_id, post_id } = req.body;
        const user_id = req.user.userId;

        await pool.query(
            `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, viewed_at, completed, percentage)
             VALUES (?, ?, ?, 'image', NOW(), 1, 100)
             ON DUPLICATE KEY UPDATE 
             viewed_at = NOW(), 
             completed = 1, 
             percentage = 100`,
            [user_id, media_id, post_id]
        );

        await pool.query(
            `INSERT IGNORE INTO post_media_views (post_id, media_id, user_id)
             VALUES (?, ?, ?)`,
            [post_id, media_id, user_id]
        );

        res.json({ success: true, message: 'Image view recorded' });
    } catch (error) {
        console.error('Track image error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

// Track video progress
exports.trackVideoProgress = async (req, res) => {
    try {
        const { media_id, post_id, total_minutes, viewed_minutes } = req.body;
        const user_id = req.user.userId;

        let percentage = (viewed_minutes / total_minutes) * 100;
        percentage = Math.min(percentage, 100);
        let completed = percentage >= 90 ? 1 : 0;

        await pool.query(
            `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, total_minutes, viewed_minutes, percentage, completed)
             VALUES (?, ?, ?, 'video', ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE 
             viewed_minutes = VALUES(viewed_minutes),
             percentage = VALUES(percentage),
             completed = VALUES(completed)`,
            [user_id, media_id, post_id, total_minutes, viewed_minutes, percentage, completed]
        );

        if (completed) {
            await pool.query(
                `INSERT IGNORE INTO post_media_views (post_id, media_id, user_id)
                 VALUES (?, ?, ?)`,
                [post_id, media_id, user_id]
            );
        }

        res.json({ success: true, message: 'Video progress updated', data: { percentage, completed } });
    } catch (error) {
        console.error('Track video error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

// Track PPT progress
exports.trackPptProgress = async (req, res) => {
    try {
        const { media_id, post_id, total_slides, viewed_slides } = req.body;
        const user_id = req.user.userId;

        let percentage = (viewed_slides / total_slides) * 100;
        percentage = Math.min(percentage, 100);
        let completed = viewed_slides >= total_slides ? 1 : 0;

        await pool.query(
            `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, total_slides, viewed_slides, percentage, completed)
             VALUES (?, ?, ?, 'ppt', ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE 
             viewed_slides = VALUES(viewed_slides),
             percentage = VALUES(percentage),
             completed = VALUES(completed)`,
            [user_id, media_id, post_id, total_slides, viewed_slides, percentage, completed]
        );

        if (completed) {
            await pool.query(
                `INSERT IGNORE INTO post_media_views (post_id, media_id, user_id)
                 VALUES (?, ?, ?)`,
                [post_id, media_id, user_id]
            );
        }

        res.json({ success: true, message: 'PPT progress updated', data: { percentage, completed } });
    } catch (error) {
        console.error('Track PPT error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

// Save/Load WBT JSON (only JSON, no slide tracking)
exports.saveWbtData = async (req, res) => {
    try {
        const { media_id, post_id, wbt_json } = req.body;
        const user_id = req.user.userId;

        // Calculate percentage based on completed slides
        let percentage = 100;
        let completed = 1;
        
        if (wbt_json && wbt_json.totalSlides && wbt_json.completedSlides !== undefined) {
            percentage = (wbt_json.completedSlides / wbt_json.totalSlides) * 100;
            percentage = Math.min(percentage, 100);
            completed = percentage >= 100 ? 1 : 0;
        }

        await pool.query(
            `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, wbt_json, completed, percentage)
             VALUES (?, ?, ?, 'wbt', ?, ?, ?)
             ON DUPLICATE KEY UPDATE 
             wbt_json = VALUES(wbt_json),
             completed = VALUES(completed),
             percentage = VALUES(percentage)`,
            [user_id, media_id, post_id, JSON.stringify(wbt_json), completed, percentage]
        );

        // Only mark as viewed if completed 100%
        if (completed === 1) {
            await pool.query(
                `INSERT IGNORE INTO post_media_views (post_id, media_id, user_id)
                 VALUES (?, ?, ?)`,
                [post_id, media_id, user_id]
            );
        }

        res.json({ 
            success: true, 
            message: 'WBT data saved',
            data: { percentage, completed }
        });
    } catch (error) {
        console.error('Save WBT error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};
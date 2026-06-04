// controllers/media.controller.js
const { pool } = require('../../config/db');

// Helper function to convert TIME/string to seconds
function timeToSeconds(time) {
    if (!time) return 0;
    if (typeof time === 'string') {
        const parts = time.split(':');
        if (parts.length === 2) {
            // MM:SS format
            return (parseInt(parts[0]) * 60) + parseInt(parts[1]);
        } else if (parts.length === 3) {
            // HH:MM:SS format
            return (parseInt(parts[0]) * 3600) + (parseInt(parts[1]) * 60) + parseInt(parts[2]);
        }
    }
    return 0;
}

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

// Track video progress (with VARCHAR)
exports.trackVideoProgress = async (req, res) => {
    try {
        const { media_id, post_id, total_minutes, viewed_minutes } = req.body;
        const user_id = req.user.userId;

        // Convert MM:SS to seconds for percentage calculation
        function timeToSeconds(timeStr) {
            if (!timeStr) return 0;
            const parts = timeStr.split(':');
            if (parts.length === 2) {
                return (parseInt(parts[0]) * 60) + parseInt(parts[1]);
            }
            return 0;
        }

        const totalSeconds = timeToSeconds(total_minutes);
        const viewedSeconds = timeToSeconds(viewed_minutes);
        
        let percentage = (viewedSeconds / totalSeconds) * 100;
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

// Track PDF progress
exports.trackPdfProgress = async (req, res) => {
    try {
        const { media_id, post_id, total_slides, viewed_slides } = req.body;
        const user_id = req.user.userId;

        let percentage = (viewed_slides / total_slides) * 100;
        percentage = Math.min(percentage, 100);
        let completed = viewed_slides >= total_slides ? 1 : 0;

        await pool.query(
            `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, total_slides, viewed_slides, percentage, completed)
             VALUES (?, ?, ?, 'pdf', ?, ?, ?, ?)
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

        res.json({ success: true, message: 'PDF progress updated', data: { percentage, completed } });
    } catch (error) {
        console.error('Track PDF error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

// Save/Load WBT JSON
exports.saveWbtData = async (req, res) => {
    try {
        const { media_id, post_id, wbt_json } = req.body;
        const user_id = req.user.userId;

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

// Track YouTube view
exports.trackYouTubeView = async (req, res) => {
    try {
        const { media_id, post_id } = req.body;
        const user_id = req.user.userId;

        await pool.query(
            `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, viewed_at, completed, percentage)
             VALUES (?, ?, ?, 'youtube', NOW(), 1, 100)
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

        res.json({ 
            success: true, 
            message: 'YouTube view recorded',
            data: { percentage: 100, completed: 1 }
        });
    } catch (error) {
        console.error('Track YouTube error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};
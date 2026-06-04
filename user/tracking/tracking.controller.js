// controllers/media.controller.js
const { pool } = require('../../config/db');

// Helper function to convert TIME/string to seconds
function timeToSeconds(time) {
    if (!time) return 0;
    if (typeof time === 'string') {
        const parts = time.split(':');
        if (parts.length === 2) {
            return (parseInt(parts[0]) * 60) + parseInt(parts[1]);
        } else if (parts.length === 3) {
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

        // Check if already completed
        const [check] = await pool.query(
            `SELECT completed FROM user_media_tracking WHERE user_id = ? AND media_id = ? AND completed = 1`,
            [user_id, media_id]
        );
        if (check.length > 0) {
            return res.json({ success: true, message: 'Already completed' });
        }

        // Check if record exists
        const [existing] = await pool.query(
            `SELECT id FROM user_media_tracking WHERE user_id = ? AND media_id = ?`,
            [user_id, media_id]
        );

        if (existing.length > 0) {
            await pool.query(
                `UPDATE user_media_tracking 
                 SET viewed_at = NOW(), completed = 1, percentage = 100, updated_at = NOW()
                 WHERE user_id = ? AND media_id = ?`,
                [user_id, media_id]
            );
        } else {
            await pool.query(
                `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, viewed_at, completed, percentage)
                 VALUES (?, ?, ?, 'image', NOW(), 1, 100)`,
                [user_id, media_id, post_id]
            );
        }

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

        // Check if already completed
        const [check] = await pool.query(
            `SELECT completed FROM user_media_tracking WHERE user_id = ? AND media_id = ? AND completed = 1`,
            [user_id, media_id]
        );
        if (check.length > 0) {
            return res.json({ success: true, message: 'Already completed' });
        }

        const totalSeconds = timeToSeconds(total_minutes);
        const viewedSeconds = timeToSeconds(viewed_minutes);
        
        let percentage = (viewedSeconds / totalSeconds) * 100;
        percentage = Math.min(percentage, 100);
        let completed = percentage >= 90 ? 1 : 0;

        const [existing] = await pool.query(
            `SELECT id FROM user_media_tracking WHERE user_id = ? AND media_id = ?`,
            [user_id, media_id]
        );

        if (existing.length > 0) {
            await pool.query(
                `UPDATE user_media_tracking 
                 SET viewed_minutes = ?, percentage = ?, completed = ?, updated_at = NOW()
                 WHERE user_id = ? AND media_id = ?`,
                [viewed_minutes, percentage, completed, user_id, media_id]
            );
        } else {
            await pool.query(
                `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, total_minutes, viewed_minutes, percentage, completed)
                 VALUES (?, ?, ?, 'video', ?, ?, ?, ?)`,
                [user_id, media_id, post_id, total_minutes, viewed_minutes, percentage, completed]
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

        // Check if already completed
        const [check] = await pool.query(
            `SELECT completed FROM user_media_tracking WHERE user_id = ? AND media_id = ? AND completed = 1`,
            [user_id, media_id]
        );
        if (check.length > 0) {
            return res.json({ success: true, message: 'Already completed' });
        }

        let percentage = (viewed_slides / total_slides) * 100;
        percentage = Math.min(percentage, 100);
        let completed = viewed_slides >= total_slides ? 1 : 0;

        const [existing] = await pool.query(
            `SELECT id FROM user_media_tracking WHERE user_id = ? AND media_id = ?`,
            [user_id, media_id]
        );

        if (existing.length > 0) {
            await pool.query(
                `UPDATE user_media_tracking 
                 SET viewed_slides = ?, percentage = ?, completed = ?, updated_at = NOW()
                 WHERE user_id = ? AND media_id = ?`,
                [viewed_slides, percentage, completed, user_id, media_id]
            );
        } else {
            await pool.query(
                `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, total_slides, viewed_slides, percentage, completed)
                 VALUES (?, ?, ?, 'pdf', ?, ?, ?, ?)`,
                [user_id, media_id, post_id, total_slides, viewed_slides, percentage, completed]
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

        // Check if already completed
        const [check] = await pool.query(
            `SELECT completed FROM user_media_tracking WHERE user_id = ? AND media_id = ? AND completed = 1`,
            [user_id, media_id]
        );
        if (check.length > 0) {
            return res.json({ success: true, message: 'Already completed' });
        }

        let percentage = 100;
        let completed = 1;
        
        if (wbt_json && wbt_json.totalSlides && wbt_json.completedSlides !== undefined) {
            percentage = (wbt_json.completedSlides / wbt_json.totalSlides) * 100;
            percentage = Math.min(percentage, 100);
            completed = percentage >= 100 ? 1 : 0;
        }

        const [existing] = await pool.query(
            `SELECT id FROM user_media_tracking WHERE user_id = ? AND media_id = ?`,
            [user_id, media_id]
        );

        if (existing.length > 0) {
            await pool.query(
                `UPDATE user_media_tracking 
                 SET wbt_json = ?, completed = ?, percentage = ?, updated_at = NOW()
                 WHERE user_id = ? AND media_id = ?`,
                [JSON.stringify(wbt_json), completed, percentage, user_id, media_id]
            );
        } else {
            await pool.query(
                `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, wbt_json, completed, percentage)
                 VALUES (?, ?, ?, 'wbt', ?, ?, ?)`,
                [user_id, media_id, post_id, JSON.stringify(wbt_json), completed, percentage]
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

        // Check if already completed
        const [check] = await pool.query(
            `SELECT completed FROM user_media_tracking WHERE user_id = ? AND media_id = ? AND completed = 1`,
            [user_id, media_id]
        );
        if (check.length > 0) {
            return res.json({ success: true, message: 'Already completed' });
        }

        const [existing] = await pool.query(
            `SELECT id FROM user_media_tracking WHERE user_id = ? AND media_id = ?`,
            [user_id, media_id]
        );

        if (existing.length > 0) {
            await pool.query(
                `UPDATE user_media_tracking 
                 SET viewed_at = NOW(), completed = 1, percentage = 100, updated_at = NOW()
                 WHERE user_id = ? AND media_id = ?`,
                [user_id, media_id]
            );
        } else {
            await pool.query(
                `INSERT INTO user_media_tracking (user_id, media_id, post_id, media_type, viewed_at, completed, percentage)
                 VALUES (?, ?, ?, 'youtube', NOW(), 1, 100)`,
                [user_id, media_id, post_id]
            );
        }

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
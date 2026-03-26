// server.js
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Create upload directory
if (!fs.existsSync('uploads')) fs.mkdirSync('uploads');

// Multer config
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

// MySQL connection pool
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'root',
    database: 'insta_style_lms',
    waitForConnections: true,
    connectionLimit: 10
});

// Create tables
const initDB = async () => {
    await pool.query(`
        CREATE TABLE IF NOT EXISTS categories (
            id INT PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(100) UNIQUE NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    `);
    
    await pool.query(`
        CREATE TABLE IF NOT EXISTS posts (
            id INT PRIMARY KEY AUTO_INCREMENT,
            category_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            content TEXT,
            hashtags TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
        )
    `);
    
    await pool.query(`
        CREATE TABLE IF NOT EXISTS post_media (
            id INT PRIMARY KEY AUTO_INCREMENT,
            post_id INT NOT NULL,
            media_type ENUM('image', 'video', 'gif') NOT NULL,
            media_url VARCHAR(500) NOT NULL,
            FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
        )
    `);
    
    console.log('✅ Database tables ready');
};
initDB();

// ============= CATEGORY APIs =============

// Add category
app.post('/api/categories', async (req, res) => {
    try {
        const { name } = req.body;
        if (!name) return res.status(400).json({ error: 'Category name required' });
        
        const [existing] = await pool.query('SELECT id FROM categories WHERE name = ?', [name]);
        if (existing.length > 0) return res.status(409).json({ error: 'Category exists' });
        
        const [result] = await pool.query('INSERT INTO categories (name) VALUES (?)', [name]);
        const [category] = await pool.query('SELECT * FROM categories WHERE id = ?', [result.insertId]);
        
        res.json({ success: true, data: category[0] });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get all categories
app.get('/api/categories', async (req, res) => {
    try {
        const [categories] = await pool.query('SELECT * FROM categories ORDER BY id');
        res.json(categories);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============= POST APIs =============

// Create post with multiple media files
app.post('/api/posts', upload.array('media', 10), async (req, res) => {
    try {
        const { category_id, title, content, hashtags } = req.body;
        
        if (!category_id || !title) {
            return res.status(400).json({ error: 'Category and title required' });
        }
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ error: 'At least one media file required' });
        }
        
        // Start transaction
        const connection = await pool.getConnection();
        await connection.beginTransaction();
        
        try {
            // Insert post
            const [postResult] = await connection.query(
                'INSERT INTO posts (category_id, title, content, hashtags) VALUES (?, ?, ?, ?)',
                [category_id, title, content, hashtags]
            );
            
            const postId = postResult.insertId;
            
            // Insert media files
            const mediaValues = [];
            req.files.forEach(file => {
                let mediaType = 'image';
                if (file.mimetype === 'image/gif') mediaType = 'gif';
                else if (file.mimetype.startsWith('video/')) mediaType = 'video';
                
                const mediaUrl = `/uploads/${file.filename}`;
                mediaValues.push([postId, mediaType, mediaUrl]);
            });
            
            await connection.query(
                'INSERT INTO post_media (post_id, media_type, media_url) VALUES ?',
                [mediaValues]
            );
            
            await connection.commit();
            connection.release();
            
            res.json({ 
                success: true, 
                postId, 
                mediaCount: req.files.length,
                message: 'Post created successfully'
            });
            
        } catch (err) {
            await connection.rollback();
            connection.release();
            throw err;
        }
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// server.js - Fixed get posts by category with media
app.get('/api/posts/category/:categoryId', async (req, res) => {
    try {
        // First query: Get posts for this category
        const [posts] = await pool.query(`
            SELECT p.*, c.name as category_name
            FROM posts p
            INNER JOIN categories c ON p.category_id = c.id
            WHERE p.category_id = ?
            ORDER BY p.created_at DESC
        `, [req.params.categoryId]);
        
        if (posts.length === 0) {
            return res.json([]);
        }
        
        // Second query: Get all media for these posts
        const postIds = posts.map(post => post.id);
        const [media] = await pool.query(`
            SELECT post_id, media_type, media_url
            FROM post_media
            WHERE post_id IN (?)
            ORDER BY post_id, id
        `, [postIds]);
        
        // Group media by post_id
        const mediaByPost = {};
        media.forEach(m => {
            if (!mediaByPost[m.post_id]) {
                mediaByPost[m.post_id] = [];
            }
            mediaByPost[m.post_id].push({
                type: m.media_type,
                url: m.media_url
            });
        });
        
        // Combine posts with their media
        const result = posts.map(post => ({
            id: post.id,
            category_id: post.category_id,
            category_name: post.category_name,
            title: post.title,
            content: post.content,
            hashtags: post.hashtags,
            created_at: post.created_at,
            updated_at: post.updated_at,
            media: mediaByPost[post.id] || []
        }));
        
        res.json(result);
    } catch (error) {
        console.error('Error fetching posts by category:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get single post with all media
app.get('/api/posts/:id', async (req, res) => {
    try {
        const [posts] = await pool.query(`
            SELECT p.*, 
                   JSON_ARRAYAGG(
                       JSON_OBJECT('type', pm.media_type, 'url', pm.media_url)
                   ) as media
            FROM posts p
            LEFT JOIN post_media pm ON p.id = pm.post_id
            WHERE p.id = ?
            GROUP BY p.id
        `, [req.params.id]);
        
        if (posts.length === 0) {
            return res.status(404).json({ error: 'Post not found' });
        }
        
        const post = {
            ...posts[0],
            media: posts[0].media ? JSON.parse(posts[0].media).filter(m => m.url) : []
        };
        
        res.json(post);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get all posts
// server.js - Fixed get all posts with media
app.get('/api/posts', async (req, res) => {
    try {
        // First query: Get all posts
        const [posts] = await pool.query(`
            SELECT p.*, c.name as category_name
            FROM posts p
            INNER JOIN categories c ON p.category_id = c.id
            ORDER BY p.created_at DESC
        `);
        
        if (posts.length === 0) {
            return res.json([]);
        }
        
        // Second query: Get all media for these posts
        const postIds = posts.map(post => post.id);
        const [media] = await pool.query(`
            SELECT post_id, media_type, media_url
            FROM post_media
            WHERE post_id IN (?)
            ORDER BY post_id, id
        `, [postIds]);
        
        console.log('Media found:', media); // Debug log
        
        // Group media by post_id
        const mediaByPost = {};
        media.forEach(m => {
            if (!mediaByPost[m.post_id]) {
                mediaByPost[m.post_id] = [];
            }
            mediaByPost[m.post_id].push({
                type: m.media_type,
                url: m.media_url
            });
        });
        
        // Combine posts with their media
        const result = posts.map(post => ({
            id: post.id,
            category_id: post.category_id,
            category_name: post.category_name,
            title: post.title,
            content: post.content,
            hashtags: post.hashtags,
            created_at: post.created_at,
            updated_at: post.updated_at,
            media: mediaByPost[post.id] || []
        }));
        
        console.log('Result posts with media:', result); // Debug log
        
        res.json(result);
    } catch (error) {
        console.error('Error fetching posts:', error);
        res.status(500).json({ error: error.message });
    }
});

// Update post
app.put('/api/posts/:id', upload.array('media', 10), async (req, res) => {
    try {
        const { title, content, hashtags } = req.body;
        const postId = req.params.id;
        
        const [result] = await pool.query(
            'UPDATE posts SET title = ?, content = ?, hashtags = ? WHERE id = ?',
            [title, content, hashtags, postId]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Post not found' });
        }
        
        // Add new media if any
        if (req.files && req.files.length > 0) {
            const mediaValues = [];
            req.files.forEach(file => {
                let mediaType = 'image';
                if (file.mimetype === 'image/gif') mediaType = 'gif';
                else if (file.mimetype.startsWith('video/')) mediaType = 'video';
                
                mediaValues.push([postId, mediaType, `/uploads/${file.filename}`]);
            });
            
            await pool.query('INSERT INTO post_media (post_id, media_type, media_url) VALUES ?', [mediaValues]);
        }
        
        res.json({ success: true, message: 'Post updated successfully' });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Delete post
app.delete('/api/posts/:id', async (req, res) => {
    try {
        // Get media URLs to delete files
        const [media] = await pool.query('SELECT media_url FROM post_media WHERE post_id = ?', [req.params.id]);
        
        // Delete files
        media.forEach(m => {
            const filePath = path.join(__dirname, m.media_url);
            fs.unlink(filePath, () => {});
        });
        
        // Delete post (cascade deletes media records)
        const [result] = await pool.query('DELETE FROM posts WHERE id = ?', [req.params.id]);
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Post not found' });
        }
        
        res.json({ success: true, message: 'Post deleted successfully' });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Delete specific media from post
app.delete('/api/posts/:postId/media/:mediaId', async (req, res) => {
    try {
        const [media] = await pool.query('SELECT media_url FROM post_media WHERE id = ? AND post_id = ?', 
            [req.params.mediaId, req.params.postId]);
        
        if (media.length === 0) {
            return res.status(404).json({ error: 'Media not found' });
        }
        
        // Delete file
        const filePath = path.join(__dirname, media[0].media_url);
        fs.unlink(filePath, () => {});
        
        // Delete from database
        await pool.query('DELETE FROM post_media WHERE id = ?', [req.params.mediaId]);
        
        res.json({ success: true, message: 'Media deleted successfully' });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});
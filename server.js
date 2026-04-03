// server.js
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';

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
const upload = multer({ storage, limits: { fileSize: 1024 * 1024 * 1024 } });

// Replace the MySQL connection pool section with:
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10
});

// Create tables
const initDB = async () => {
    await pool.query(`
        CREATE TABLE IF NOT EXISTS categories (
            id INT PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(100) UNIQUE NOT NULL,
            icon_url varchar(500) DEFAULT NULL,
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
    
    // Create users table with password
    await pool.query(`
        CREATE TABLE IF NOT EXISTS users (
            id INT PRIMARY KEY AUTO_INCREMENT,
            profile_image VARCHAR(500) DEFAULT NULL,
            name VARCHAR(255) NOT NULL,
            employeeid VARCHAR(100) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            role VARCHAR(100) NOT NULL,
            status ENUM('active', 'inactive') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    `);
    
    console.log('✅ Database tables ready');
};
initDB();

// ============= AUTH API =============

// Login API
app.post('/api/login', async (req, res) => {
    try {
        const { employeeid, password } = req.body;
        
        if (!employeeid || !password) {
            return res.status(400).json({ error: 'Employee ID and password required' });
        }
        
        // Check if user exists
        const [users] = await pool.query(
            'SELECT * FROM users WHERE employeeid = ?',
            [employeeid]
        );
        
        if (users.length === 0) {
            return res.status(401).json({ error: 'Invalid Employee ID or password' });
        }
        
        const user = users[0];
        
        // Check if user is active
        if (user.status !== 'active') {
            return res.status(401).json({ error: 'Account is inactive. Please contact administrator.' });
        }
        
        // Verify password
        const isValidPassword = await bcrypt.compare(password, user.password);
        
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Invalid Employee ID or password' });
        }
        
        // Generate JWT token
        const token = jwt.sign(
            { 
                id: user.id, 
                employeeid: user.employeeid, 
                name: user.name, 
                role: user.role 
            },
            JWT_SECRET,
            { expiresIn: '24h' }
        );
        
        
        res.json({
            success: true,
            message: 'Login successful',
            token,
        });
        
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Verify Token Middleware
const verifyToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ error: 'Access denied. No token provided.' });
    }
    
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(403).json({ error: 'Invalid or expired token.' });
    }
};

// ============= USER APIs =============

app.get('/api/me', verifyToken, async (req, res) => {
    try {
        const [users] = await pool.query(
            'SELECT id, profile_image, name, employeeid, role, status, created_at, updated_at FROM users WHERE id = ?',
            [req.user.id]
        );
        
        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        res.json(users[0]);
    } catch (error) {
        console.error('Error fetching user profile:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get all users
app.get('/api/users', verifyToken, async (req, res) => {
    try {
        const [users] = await pool.query('SELECT id, profile_image, name, employeeid, role, status, created_at, updated_at FROM users ORDER BY created_at DESC');
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get single user
app.get('/api/users/:id', verifyToken, async (req, res) => {
    try {
        const [users] = await pool.query('SELECT id, profile_image, name, employeeid, role, status, created_at, updated_at FROM users WHERE id = ?', [req.params.id]);
        
        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        res.json(users[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create user with profile image and password
app.post('/api/users', upload.single('profile_image'), async (req, res) => {
    try {
        const { name, employeeid, password, role, status } = req.body;
        
        if (!name || !employeeid || !password || !role) {
            return res.status(400).json({ error: 'Name, Employee ID, Password, and Role are required' });
        }
        
        // Check if employee ID already exists
        const [existing] = await pool.query('SELECT id FROM users WHERE employeeid = ?', [employeeid]);
        if (existing.length > 0) {
            return res.status(409).json({ error: 'Employee ID already exists' });
        }
        
        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);
        
        // Get profile image URL if uploaded
        let profileImage = null;
        if (req.file) {
            profileImage = `/uploads/${req.file.filename}`;
        }
        
        // Insert user
        const [result] = await pool.query(
            'INSERT INTO users (profile_image, name, employeeid, password, role, status) VALUES (?, ?, ?, ?, ?, ?)',
            [profileImage, name, employeeid, hashedPassword, role, status || 'active']
        );
        
        const [user] = await pool.query('SELECT id, profile_image, name, employeeid, role, status, created_at, updated_at FROM users WHERE id = ?', [result.insertId]);
        
        res.json({ success: true, data: user[0] });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});



// ============= CATEGORY APIs =============

app.post('/api/categories', verifyToken, upload.single('icon'), async (req, res) => {
    try {
        const { name } = req.body;
        if (!name) return res.status(400).json({ error: 'Category name required' });
        
        // Check if category exists
        const [existing] = await pool.query('SELECT id FROM categories WHERE name = ?', [name]);
        if (existing.length > 0) return res.status(409).json({ error: 'Category exists' });
        
        // Get icon URL if uploaded
        let iconUrl = null;
        if (req.file) {
            iconUrl = `/uploads/${req.file.filename}`;
        }
        
        // Insert category with icon
        const [result] = await pool.query(
            'INSERT INTO categories (name, icon_url) VALUES (?, ?)',
            [name, iconUrl]
        );
        
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
app.post('/api/posts', verifyToken, upload.array('media', 10), async (req, res) => {
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


// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});
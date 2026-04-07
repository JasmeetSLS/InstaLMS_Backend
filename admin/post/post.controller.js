const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');
const unzipper = require('unzipper');

// Helper function to extract YouTube ID
function extractYouTubeId(url) {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=|\/shorts\/)([^#&?]*).*/;
    const match = url.match(regExp);
    return (match && match[2].length === 11) ? match[2] : null;
}

// Helper function to get YouTube thumbnail
function getYouTubeThumbnail(url) {
    const videoId = extractYouTubeId(url);
    if (videoId) {
        return `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`;
    }
    return null;
}

// Helper function to check if file is WBT
function isWBTFile(filename, mimetype) {
    const wbtExtensions = ['.zip', '.wbt', '.scorm', '.html', '.htm'];
    const ext = path.extname(filename).toLowerCase();
    return wbtExtensions.includes(ext) || (mimetype && mimetype.includes('zip'));
}

// Helper function to find launch file in extracted WBT
function findLaunchFile(extractPath) {
    const possibleLaunches = [
        'index.html', 'index.htm', 'launch.html', 'launch.htm',
        'start.html', 'start.htm', 'scorm.html', 'course.html',
        'story.html', 'story.htm', 'player.html', 'player.htm'
    ];
    
    for (const launchFile of possibleLaunches) {
        const launchPath = path.join(extractPath, launchFile);
        if (fs.existsSync(launchPath)) {
            return launchFile;
        }
    }
    
    // Look for any HTML file in root
    try {
        const files = fs.readdirSync(extractPath);
        const htmlFile = files.find(f => f.endsWith('.html') || f.endsWith('.htm'));
        if (htmlFile) {
            return htmlFile;
        }
    } catch (err) {
        console.error('Error reading directory:', err);
    }
    
    return null;
}

// Extract ZIP using unzipper stream (no timeout issues)
async function extractZip(zipPath, extractPath) {
    return new Promise((resolve, reject) => {
        const stream = fs.createReadStream(zipPath)
            .pipe(unzipper.Extract({ path: extractPath }));
        
        stream.on('close', () => {
            console.log(`Extracted successfully: ${zipPath}`);
            resolve(true);
        });
        
        stream.on('error', (error) => {
            console.error(`Extraction error: ${error}`);
            reject(error);
        });
    });
}

// Create post with multiple media files and their thumbnails
exports.createPost = async (req, res) => {
    try {
        const { title, category_id, description, hashtags, youtube_links } = req.body;
        
        const mediaFiles = req.files['media'] || [];
        const thumbnailFiles = req.files['thumbnail'] || [];

        if (!title || !category_id) {
            if (mediaFiles.length) {
                mediaFiles.forEach(file => {
                    if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
                });
            }
            if (thumbnailFiles.length) {
                thumbnailFiles.forEach(file => {
                    if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
                });
            }
            
            return res.status(400).json({
                success: false,
                error: 'Title and category ID are required'
            });
        }

        const connection = await pool.getConnection();

        try {
            const [categories] = await connection.query(
                'SELECT id, name FROM categories WHERE id = ?',
                [category_id]
            );

            if (categories.length === 0) {
                if (mediaFiles.length) {
                    mediaFiles.forEach(file => {
                        if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
                    });
                }
                if (thumbnailFiles.length) {
                    thumbnailFiles.forEach(file => {
                        if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
                    });
                }
                
                return res.status(404).json({
                    success: false,
                    error: 'Category not found'
                });
            }

            await connection.beginTransaction();

            const [postResult] = await connection.query(
                'INSERT INTO posts (category_id, title, content, hashtags) VALUES (?, ?, ?, ?)',
                [category_id, title, description || null, hashtags || null]
            );

            const postId = postResult.insertId;

            const postDir = path.join('uploads', 'posts', postId.toString());
            const mediaDir = path.join(postDir, 'media');
            const thumbnailDir = path.join(postDir, 'thumbnails');
            const wbtDir = path.join(postDir, 'wbt');
            
            if (!fs.existsSync(mediaDir)) {
                fs.mkdirSync(mediaDir, { recursive: true });
            }
            if (!fs.existsSync(thumbnailDir)) {
                fs.mkdirSync(thumbnailDir, { recursive: true });
            }
            if (!fs.existsSync(wbtDir)) {
                fs.mkdirSync(wbtDir, { recursive: true });
            }

            const mediaItems = [];
            
            // Process uploaded media files
            for (let i = 0; i < mediaFiles.length; i++) {
                const mediaFile = mediaFiles[i];
                const fileExt = path.extname(mediaFile.originalname).toLowerCase();
                let mediaType = 'image';
                let mediaUrl = null;
                let thumbnailUrl = null;
                let finalMediaDir = mediaDir;

                const uniqueId = Date.now() + '-' + Math.round(Math.random() * 1E9);
                let mediaFilename = `media-${uniqueId}${fileExt}`;
                
                if (isWBTFile(mediaFile.originalname, mediaFile.mimetype)) {
                    mediaType = 'wbt';
                    finalMediaDir = wbtDir;
                    mediaFilename = `wbt-${uniqueId}${fileExt}`;
                    
                    if (thumbnailFiles[i]) {
                        const thumbExt = path.extname(thumbnailFiles[i].originalname);
                        const thumbFilename = `thumb-${uniqueId}${thumbExt}`;
                        const thumbPath = path.join(thumbnailDir, thumbFilename);
                        fs.renameSync(thumbnailFiles[i].path, thumbPath);
                        thumbnailUrl = `/uploads/posts/${postId}/thumbnails/${thumbFilename}`;
                    } else {
                        thumbnailUrl = '/uploads/default/wbt-thumbnail.jpg';
                    }
                    
                    const wbtPath = path.join(finalMediaDir, mediaFilename);
                    fs.renameSync(mediaFile.path, wbtPath);
                    
                    // Extract ZIP file using unzipper (stream-based, no timeout)
                    if (fileExt === '.zip') {
                        try {
                            console.log(`Extracting ZIP: ${mediaFilename}`);
                            const extractFolderName = `wbt-${uniqueId}`;
                            const extractPath = path.join(wbtDir, extractFolderName);
                            
                            if (!fs.existsSync(extractPath)) {
                                fs.mkdirSync(extractPath, { recursive: true });
                            }
                            
                            // Extract using unzipper stream
                            await extractZip(wbtPath, extractPath);
                            
                            console.log(`Extraction complete for: ${mediaFilename}`);
                            
                            // Find launch file
                            const launchFile = findLaunchFile(extractPath);
                            
                            if (launchFile) {
                                mediaUrl = `/uploads/posts/${postId}/wbt/${extractFolderName}/${launchFile}`;
                                console.log(`Launch file found: ${launchFile}`);
                            } else {
                                mediaUrl = `/uploads/posts/${postId}/wbt/${mediaFilename}`;
                                console.log(`No launch file found, using original ZIP`);
                            }
                        } catch (zipError) {
                            console.error('Error extracting zip:', zipError);
                            mediaUrl = `/uploads/posts/${postId}/wbt/${mediaFilename}`;
                        }
                    } else {
                        mediaUrl = `/uploads/posts/${postId}/wbt/${mediaFilename}`;
                    }
                    
                } else if (mediaFile.mimetype.startsWith('image/')) {
                    if (mediaFile.mimetype === 'image/gif') {
                        mediaType = 'gif';
                    } else {
                        mediaType = 'image';
                    }
                    
                    const mediaPath = path.join(finalMediaDir, mediaFilename);
                    fs.renameSync(mediaFile.path, mediaPath);
                    mediaUrl = `/uploads/posts/${postId}/media/${mediaFilename}`;
                    
                    if (thumbnailFiles[i]) {
                        const thumbExt = path.extname(thumbnailFiles[i].originalname);
                        const thumbFilename = `thumb-${uniqueId}${thumbExt}`;
                        const thumbPath = path.join(thumbnailDir, thumbFilename);
                        fs.renameSync(thumbnailFiles[i].path, thumbPath);
                        thumbnailUrl = `/uploads/posts/${postId}/thumbnails/${thumbFilename}`;
                    } else {
                        thumbnailUrl = mediaUrl;
                    }
                    
                } else if (mediaFile.mimetype.startsWith('video/')) {
                    mediaType = 'video';
                    
                    const videoPath = path.join(finalMediaDir, mediaFilename);
                    fs.renameSync(mediaFile.path, videoPath);
                    mediaUrl = `/uploads/posts/${postId}/media/${mediaFilename}`;
                    
                    if (thumbnailFiles[i]) {
                        const thumbExt = path.extname(thumbnailFiles[i].originalname);
                        const thumbFilename = `thumb-${uniqueId}${thumbExt}`;
                        const thumbPath = path.join(thumbnailDir, thumbFilename);
                        fs.renameSync(thumbnailFiles[i].path, thumbPath);
                        thumbnailUrl = `/uploads/posts/${postId}/thumbnails/${thumbFilename}`;
                    } else {
                        thumbnailUrl = null;
                    }
                }

                const [mediaResult] = await connection.query(
                    'INSERT INTO post_media (post_id, media_type, media_url, thumbnail_url) VALUES (?, ?, ?, ?)',
                    [postId, mediaType, mediaUrl, thumbnailUrl]
                );

                mediaItems.push({
                    id: mediaResult.insertId,
                    media_type: mediaType,
                    media_url: mediaUrl,
                    thumbnail_url: thumbnailUrl
                });
            }

            // Process YouTube links
            if (youtube_links) {
                let youtubeLinks = Array.isArray(youtube_links) ? youtube_links : [youtube_links];
                
                for (const youtubeUrl of youtubeLinks) {
                    if (youtubeUrl && youtubeUrl.trim()) {
                        const thumbnailUrl = getYouTubeThumbnail(youtubeUrl);
                        
                        const [mediaResult] = await connection.query(
                            'INSERT INTO post_media (post_id, media_type, media_url, thumbnail_url) VALUES (?, ?, ?, ?)',
                            [postId, 'youtube', youtubeUrl, thumbnailUrl]
                        );

                        mediaItems.push({
                            id: mediaResult.insertId,
                            media_type: 'youtube',
                            media_url: youtubeUrl,
                            thumbnail_url: thumbnailUrl
                        });
                    }
                }
            }

            await connection.commit();

            res.status(201).json({
                success: true,
                message: 'Post created successfully',
                data: {
                    post_id: postId,
                    title: title,
                    category_id: category_id,
                    category_name: categories[0].name,
                    description: description,
                    hashtags: hashtags,
                    media_count: mediaItems.length,
                    media: mediaItems
                }
            });

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create post error:', error);
        if (req.files) {
            if (req.files['media']) {
                req.files['media'].forEach(file => {
                    if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
                });
            }
            if (req.files['thumbnail']) {
                req.files['thumbnail'].forEach(file => {
                    if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
                });
            }
        }
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};

// Get all posts
exports.getAllPosts = async (req, res) => {
    try {
        const { category_id, status, page = 1, limit = 10 } = req.query;
        
        const connection = await pool.getConnection();
        
        try {
            let query = `
                SELECT p.*, c.name as category_name,
                       COUNT(pm.id) as media_count
                FROM posts p
                LEFT JOIN categories c ON p.category_id = c.id
                LEFT JOIN post_media pm ON p.id = pm.post_id
                WHERE 1=1
            `;
            let countQuery = 'SELECT COUNT(DISTINCT p.id) as total FROM posts p WHERE 1=1';
            const queryParams = [];
            const countParams = [];
            
            if (category_id) {
                query += ' AND p.category_id = ?';
                countQuery += ' AND category_id = ?';
                queryParams.push(category_id);
                countParams.push(category_id);
            }
            
            if (status) {
                query += ' AND p.status = ?';
                countQuery += ' AND status = ?';
                queryParams.push(status);
                countParams.push(status);
            }
            
            query += ' GROUP BY p.id ORDER BY p.created_at DESC';
            
            const offset = (parseInt(page) - 1) * parseInt(limit);
            query += ' LIMIT ? OFFSET ?';
            queryParams.push(parseInt(limit), offset);
            
            const [posts] = await connection.query(query, queryParams);
            const [totalResult] = await connection.query(countQuery, countParams);
            
            for (let post of posts) {
                const [media] = await connection.query(
                    'SELECT id, media_type, media_url, thumbnail_url FROM post_media WHERE post_id = ?',
                    [post.id]
                );
                post.media = media;
            }
            
            res.json({
                success: true,
                data: {
                    posts: posts,
                    pagination: {
                        current_page: parseInt(page),
                        per_page: parseInt(limit),
                        total: totalResult[0].total,
                        total_pages: Math.ceil(totalResult[0].total / parseInt(limit))
                    }
                }
            });
            
        } finally {
            connection.release();
        }
        
    } catch (error) {
        console.error('Get posts error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

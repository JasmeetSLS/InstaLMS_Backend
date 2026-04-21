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
    return videoId ? `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg` : null;
}

// Get clean filename - preserve original name
function getCleanFileName(originalname) {
    // Remove special characters but keep original name structure
    let cleanName = originalname
        .replace(/[^a-zA-Z0-9.-]/g, '_')  // Replace special chars with underscore
        .replace(/_+/g, '_');              // Replace multiple underscores with single
    
    // Limit length to 100 characters to avoid issues
    if (cleanName.length > 100) {
        const ext = path.extname(cleanName);
        const nameWithoutExt = cleanName.substring(0, 100 - ext.length);
        cleanName = nameWithoutExt + ext;
    }
    
    return cleanName;
}

// Check file types
const fileTypeCheckers = {
    isWBT: (filename, mimetype) => {
        const wbtExtensions = ['.zip', '.wbt', '.scorm', '.html', '.htm'];
        const ext = path.extname(filename).toLowerCase();
        return wbtExtensions.includes(ext) || (mimetype && mimetype.includes('zip'));
    },
    isPDF: (filename, mimetype) => {
        const ext = path.extname(filename).toLowerCase();
        return ext === '.pdf' || mimetype === 'application/pdf';
    },
    isPPT: (filename, mimetype) => {
        const ext = path.extname(filename).toLowerCase();
        return ext === '.ppt' || ext === '.pptx' || 
               mimetype === 'application/vnd.ms-powerpoint' || 
               mimetype === 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    },
    isImage: (mimetype) => mimetype.startsWith('image/'),
    isGif: (mimetype) => mimetype === 'image/gif',
    isVideo: (mimetype) => mimetype.startsWith('video/')
};

// Get media configuration
function getMediaConfig(file, mimetype) {
    if (fileTypeCheckers.isWBT(file, mimetype)) {
        return { type: 'wbt', defaultThumb: '/uploads/default/wbt-thumbnail.jpg' };
    }
    if (fileTypeCheckers.isPDF(file, mimetype)) {
        return { type: 'pdf', defaultThumb: '/uploads/default/pdf-thumbnail.jpg' };
    }
    if (fileTypeCheckers.isPPT(file, mimetype)) {
        return { type: 'ppt', defaultThumb: '/uploads/default/ppt-thumbnail.jpg' };
    }
    if (fileTypeCheckers.isGif(mimetype)) {
        return { type: 'gif', defaultThumb: null };
    }
    if (fileTypeCheckers.isImage(mimetype)) {
        return { type: 'image', defaultThumb: null };
    }
    if (fileTypeCheckers.isVideo(mimetype)) {
        return { type: 'video', defaultThumb: null };
    }
    return null;
}

// Ensure directory exists
function ensureDir(dirPath) {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
}

// Find launch file in extracted WBT
function findLaunchFile(extractPath) {
    const possibleLaunches = [
        'index.html', 'index.htm', 'launch.html', 'launch.htm',
        'start.html', 'start.htm', 'scorm.html', 'course.html',
        'story.html', 'story.htm', 'player.html', 'player.htm'
    ];
    
    for (const launchFile of possibleLaunches) {
        const launchPath = path.join(extractPath, launchFile);
        if (fs.existsSync(launchPath)) return launchFile;
    }
    
    try {
        const files = fs.readdirSync(extractPath);
        const htmlFile = files.find(f => f.endsWith('.html') || f.endsWith('.htm'));
        return htmlFile || null;
    } catch (err) {
        return null;
    }
}

// Extract ZIP file
async function extractZip(zipPath, extractPath) {
    return new Promise((resolve, reject) => {
        fs.createReadStream(zipPath)
            .pipe(unzipper.Extract({ path: extractPath }))
            .on('close', () => resolve(true))
            .on('error', reject);
    });
}

// Clean up temp files
function cleanupTempFiles(files) {
    if (!files) return;
    Object.values(files).flat().forEach(file => {
        if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
    });
}

// Create post with multiple media files
exports.createPost = async (req, res) => {
    try {
        const { title, category_id, description, hashtags, youtube_links, thumbnail_type } = req.body;
        const mediaFiles = req.files['media'] || [];
        const thumbnailFiles = req.files['thumbnail'] || [];

        // Validate thumbnail_type (user input once for all)
        const validThumbnailTypes = ['portrait', 'landscape'];
        const selectedThumbnailType = thumbnail_type && validThumbnailTypes.includes(thumbnail_type.toLowerCase()) 
            ? thumbnail_type.toLowerCase() 
            : 'landscape';

        if (!title || !category_id) {
            cleanupTempFiles(req.files);
            return res.status(400).json({ success: false, error: 'Title and category ID are required' });
        }

        const connection = await pool.getConnection();

        try {
            const [categories] = await connection.query(
                'SELECT id, name FROM categories WHERE id = ?',
                [category_id]
            );

            if (categories.length === 0) {
                cleanupTempFiles(req.files);
                return res.status(404).json({ success: false, error: 'Category not found' });
            }

            await connection.beginTransaction();

            // Insert post with thumbnail_type
            const [postResult] = await connection.query(
                'INSERT INTO posts (category_id, title, content, hashtags, thumbnail_type) VALUES (?, ?, ?, ?, ?)',
                [category_id, title, description || null, hashtags || null, selectedThumbnailType]
            );

            const postId = postResult.insertId;
            const mediaBaseDir = path.join('uploads', 'posts', postId.toString(), 'media');
            
            const mediaItems = [];
            
            // Process each media file
            for (let i = 0; i < mediaFiles.length; i++) {
                const mediaFile = mediaFiles[i];
                const config = getMediaConfig(mediaFile.originalname, mediaFile.mimetype);
                
                if (!config) continue;

                // Insert without thumbnail_type
                const [tempMediaResult] = await connection.query(
                    'INSERT INTO post_media (post_id, media_type, media_url, thumbnail_url) VALUES (?, ?, ?, ?)',
                    [postId, config.type, '', '']
                );
                
                const mediaId = tempMediaResult.insertId;
                
                const mediaFolder = path.join(mediaBaseDir, mediaId.toString());
                ensureDir(mediaFolder);
                
                const originalFilename = getCleanFileName(mediaFile.originalname);
                const mediaPath = path.join(mediaFolder, originalFilename);
                
                let mediaUrl = null;
                let thumbnailUrl = null;
                
                fs.renameSync(mediaFile.path, mediaPath);
                mediaUrl = `/uploads/posts/${postId}/media/${mediaId}/${originalFilename}`;
                
                if (config.type === 'wbt' && path.extname(mediaFile.originalname).toLowerCase() === '.zip') {
                    const extractPath = path.join(mediaFolder, 'extracted');
                    ensureDir(extractPath);
                    
                    try {
                        await extractZip(mediaPath, extractPath);
                        const launchFile = findLaunchFile(extractPath);
                        if (launchFile) {
                            mediaUrl = `/uploads/posts/${postId}/media/${mediaId}/extracted/${launchFile}`;
                        }
                    } catch (error) {
                        console.error('Extraction error:', error);
                    }
                }
                
                if (thumbnailFiles[i]) {
                    const thumbExt = path.extname(thumbnailFiles[i].originalname);
                    const baseName = path.basename(originalFilename, path.extname(originalFilename));
                    const thumbFilename = `thumb_${baseName}${thumbExt}`;
                    const thumbPath = path.join(mediaFolder, thumbFilename);
                    fs.renameSync(thumbnailFiles[i].path, thumbPath);
                    thumbnailUrl = `/uploads/posts/${postId}/media/${mediaId}/${thumbFilename}`;
                } else if (config.defaultThumb) {
                    thumbnailUrl = config.defaultThumb;
                } else if (config.type === 'image' || config.type === 'gif') {
                    thumbnailUrl = mediaUrl;
                }
                
                await connection.query(
                    'UPDATE post_media SET media_url = ?, thumbnail_url = ? WHERE id = ?',
                    [mediaUrl, thumbnailUrl, mediaId]
                );
                
                mediaItems.push({
                    id: mediaId,
                    media_type: config.type,
                    media_url: mediaUrl,
                    thumbnail_url: thumbnailUrl
                });
            }
            
            // Process YouTube links
            if (youtube_links) {
                const youtubeLinks = Array.isArray(youtube_links) ? youtube_links : [youtube_links];
                
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
                    thumbnail_type: selectedThumbnailType,
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
        cleanupTempFiles(req.files);
        res.status(500).json({ success: false, error: 'Internal server error: ' + error.message });
    }
};

// Get all posts with media files
exports.getAllPosts = async (req, res) => {
    try {
        const [posts] = await pool.query(
            `SELECT 
                p.id,
                p.category_id,
                c.name as category_name,
                c.icon_url as category_icon_url,
                p.title,
                p.content,
                p.hashtags,
                p.thumbnail_type,
                p.likes_count,
                p.comments_count,
                p.views_count,
                p.shares_count,
                p.status,
                p.created_at,
                p.updated_at
            FROM posts p
            INNER JOIN categories c ON p.category_id = c.id
            ORDER BY p.created_at ASC`
        );

        // Get media for all posts
        for (let post of posts) {
            const [media] = await pool.query(
                `SELECT 
                    id,
                    media_type,
                    media_url,
                    thumbnail_url,
                    created_at
                FROM post_media 
                WHERE post_id = ?
                ORDER BY created_at ASC`,
                [post.id]
            );
            post.media = media;
        }

        res.status(200).json({
            success: true,
            data: posts
        });
        
    } catch (error) {
        console.error('Get all posts error:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error: ' + error.message 
        });
    }
};
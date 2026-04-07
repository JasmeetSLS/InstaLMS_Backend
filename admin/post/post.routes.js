const express = require('express');
const router = express.Router();
const postController = require('./post.controller');
const upload = require('../../middleware/upload.middleware');

// POST /api/admin/posts - Create post with multiple media files and their thumbnails
router.post('/add-post', 
    upload.fields([
        { name: 'media', maxCount: 10 },      // Media files (images, videos, gifs)
        { name: 'thumbnail', maxCount: 10 }    // Thumbnail files for each media
    ]), 
    postController.createPost
);

// GET /api/admin/posts - Get all posts
router.get('/posts', postController.getAllPosts);



module.exports = router;
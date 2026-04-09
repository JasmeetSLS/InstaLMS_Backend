const express = require('express');
const router = express.Router();
const userPostController = require('./post.controller');

// Get posts by category ID
router.get('/categories/:category_id/posts', userPostController.getPostsByCategory);


module.exports = router;
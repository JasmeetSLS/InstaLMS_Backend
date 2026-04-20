const express = require('express');
const router = express.Router();
const userLikeController = require('./like.controller');

// POST with query parameter and body
router.post('/post/like', userLikeController.likePost);

module.exports = router;
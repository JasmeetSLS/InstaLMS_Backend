const express = require('express');
const router = express.Router();
const userLikeController = require('./like.controller');

router.post('/posts/:post_id/like', userLikeController.likePost);

module.exports = router;
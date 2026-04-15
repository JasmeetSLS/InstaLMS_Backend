const express = require('express');
const router = express.Router();
const userShareController = require('./share.controller');

// POST /api/user/posts/share?post_id=1&share_id=2
router.post('/posts/share', userShareController.sharePost);

module.exports = router;
const express = require('express');
const router = express.Router();
const userShareController = require('./share.controller');

router.post('/posts/share', userShareController.sharePost);

router.get('/posts/shared-to-me', userShareController.getSharedPostsToUser);

module.exports = router;
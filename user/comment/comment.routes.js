const express = require('express');
const router = express.Router();
const userCommentController = require('./comment.controller');

router.post('/posts/:post_id/comments', userCommentController.createComment);

module.exports = router;
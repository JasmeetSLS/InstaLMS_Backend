const express = require('express');
const router = express.Router();
const userBookmarkController = require('./bookmark.controller');

router.post('/posts/:post_id/bookmark', userBookmarkController.addBookmark);

module.exports = router;
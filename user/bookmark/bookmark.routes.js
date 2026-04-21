const express = require('express');
const router = express.Router();
const userBookmarkController = require('./bookmark.controller');

router.post('/posts/bookmark', userBookmarkController.toggleBookmark);
router.get('/user/bookmarks', userBookmarkController.getUserBookmarks); 

module.exports = router;
const express = require('express');
const router = express.Router();
const userPostController = require('./post.controller');

router.get('/posts/by-category', userPostController.getPostsByCategory);


module.exports = router;
const express = require('express');
const router = express.Router();
const userPostController = require('./post.controller');

router.get('/posts/by-category', userPostController.getPostsByCategory);
router.get('/curriculum/:id', userPostController.getCurriculumById);
router.get('/curriculums', userPostController.getUserCurriculums);

module.exports = router;
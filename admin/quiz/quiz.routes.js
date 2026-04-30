const express = require('express');
const router = express.Router();
const upload = require('../../middleware/upload.middleware');
const quizController = require('./quiz.controller');

router.post('/quiz/bulk-upload', upload.single('file'), quizController.bulkUploadQuiz);
router.get('/quiz/questions/:post_id', quizController.getQuizQuestionsByPost);
router.get('/posts/titles', quizController.getAllPostTitles);

module.exports = router;
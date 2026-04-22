const express = require('express');
const router = express.Router();
const quizController = require('./quiz.controller');

// Get quiz questions for a post
router.get('/post/quiz/:post_id', quizController.getQuizQuestions);

// Submit quiz answers
router.post('/post/quiz/submit', quizController.submitQuizAnswers);

module.exports = router;
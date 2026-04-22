const express = require('express');
const router = express.Router();
const quizController = require('./quiz.controller');

// Get quiz questions for a post (post_id in query params)
router.get('/post/quiz', quizController.getQuizQuestions);

// Submit quiz answers (post_id in query params, answers in body)
router.post('/post/quiz/submit', quizController.submitQuizAnswers);

module.exports = router;
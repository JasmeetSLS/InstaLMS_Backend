const express = require('express');
const router = express.Router();
const quizController = require('./quiz.controller');

router.get('/post/quiz', quizController.getQuizQuestions);

router.post('/post/quiz/submit', quizController.submitQuizAnswers);

module.exports = router;
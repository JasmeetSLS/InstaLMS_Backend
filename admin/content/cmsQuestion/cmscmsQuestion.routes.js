const express = require('express');
const router = express.Router();
const cmsQuestionController = require('./cmscmsQuestion.controller');

router.get('/questions/:sectionId', cmsQuestionController.getQuestionsBySection);
router.get('/question/:questionId', cmsQuestionController.getQuestionById);

module.exports = router;
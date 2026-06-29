const express = require('express');
const router = express.Router();
const cmsQuestionController = require('./cmscmsQuestion.controller');

// GET (existing)
router.get('/questions/:sectionId', cmsQuestionController.getQuestionsBySection);
router.get('/question/:questionId', cmsQuestionController.getQuestionById);

// POST – create question
router.post('/add-question', cmsQuestionController.addQuestion);

// PUT – update question (partial)
router.put('/question/:questionId', cmsQuestionController.updateQuestion);

// DELETE – delete question
router.delete('/question/:questionId', cmsQuestionController.deleteQuestion);

module.exports = router;
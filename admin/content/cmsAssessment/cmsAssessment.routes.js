const express = require('express');
const router = express.Router();
const cmsAssessmentController = require('./cmsAssessment.controller');

router.get('/assessments/:sectionId', cmsAssessmentController.getAssessmentsBySection);
router.get('/assessment/:assessmentId/questions', cmsAssessmentController.getAssessmentQuestions);

module.exports = router;
const express = require('express');
const router = express.Router();
const videoAnalysisController = require('./videoAnalysis.controller');

router.get('/video-analysis/users-only', videoAnalysisController.getUsersWithVideoAnalysis);
router.get('/video-analysis/report/:userId', videoAnalysisController.getUserReport);

module.exports = router;
const express = require('express');
const router = express.Router();
const videoAnalysisController = require('./videoAnalysis.controller');

router.get('/video-analysis/users-only', videoAnalysisController.getUsersWithVideoAnalysis);

module.exports = router;
const express = require('express');
const router = express.Router();
const upload = require('../../middleware/upload.middleware');
const videoAssessmentController = require('./userVideoAnalysis.controller');

// Existing single-file upload (keep as is)
router.post('/video-analysis/upload', upload.single('video'), videoAssessmentController.uploadVideo);

// NEW: chunked upload endpoint
router.post('/video-analysis/upload-chunk', upload.single('chunk'), videoAssessmentController.uploadVideoChunk);

router.get('/assessments', videoAssessmentController.getAssessments);


module.exports = router;
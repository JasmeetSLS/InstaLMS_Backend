const express = require('express');
const router = express.Router();
const upload = require('../../middleware/upload.middleware');  // reuse multer config
const videoAssessmentController = require('./userVideoAnalysis.controller');

router.post('/video-analysis/upload', upload.single('video'), videoAssessmentController.uploadVideo);

module.exports = router;
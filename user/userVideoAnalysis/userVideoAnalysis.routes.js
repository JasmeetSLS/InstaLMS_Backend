const express = require('express');
const router = express.Router();
const upload = require('../../middleware/upload.middleware');  // reuse multer config
const videoAssessmentController = require('./userVideoAnalysis.controller');

router.post(
  '/video-assessment/upload',
  upload.single('video'),
  videoAssessmentController.uploadVideo
);

module.exports = router;
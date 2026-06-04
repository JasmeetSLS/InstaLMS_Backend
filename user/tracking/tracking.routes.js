// routes/media.routes.js
const express = require('express');
const router = express.Router();
const userTrackingController = require('./tracking.controller');

// Image
router.post('/media/image/view', userTrackingController.trackImageView);

// Video
router.post('/media/video/progress', userTrackingController.trackVideoProgress);

// PPT
router.post('/media/pdf/progress', userTrackingController.trackPdfProgress);

// WBT (JSON only)
router.post('/media/wbt/save', userTrackingController.saveWbtData);

router.post('/media/youtube/progress', userTrackingController.trackYouTubeView);

module.exports = router;
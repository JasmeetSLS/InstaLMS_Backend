// cmsContent.routes.js
const express = require('express');
const router = express.Router();
const cmsContentController = require('./cmsContent.controller');
const upload = require('../../../middleware/upload.middleware');

router.get('/contents/:sectionId', cmsContentController.getContentsBySection);
router.get('/content/:contentId', cmsContentController.getContentById);

// Use upload.any() to accept all file fields
router.post('/add-content', upload.any(), cmsContentController.addContent);

module.exports = router;
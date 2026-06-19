const express = require('express');
const router = express.Router();
const cmsContentController = require('./cmsContent.controller');

router.get('/contents/:sectionId', cmsContentController.getContentsBySection);
router.get('/content/:contentId', cmsContentController.getContentById);

module.exports = router;
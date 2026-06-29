const express = require('express');
const router = express.Router();
const cmsContentController = require('./cmsContent.controller');
const upload = require('../../../middleware/upload.middleware');

router.get('/contents/:sectionId', cmsContentController.getContentsBySection);
router.get('/content/:contentId', cmsContentController.getContentById);
router.post('/add-content', upload.any(), cmsContentController.addContent);
router.put('/content/:contentId', upload.any(), cmsContentController.updateContent);
router.delete('/content/:contentId', cmsContentController.deleteContent);

module.exports = router;
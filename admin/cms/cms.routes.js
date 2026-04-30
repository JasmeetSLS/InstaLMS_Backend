const express = require('express');
const router = express.Router();
const cmsController = require('./cms.controller');
const upload = require('../../middleware/upload.middleware');

router.post('/cms/page', upload.single('image'), cmsController.createCMSPage);

module.exports = router;
const express = require('express');
const router = express.Router();
const cmsController = require('./cms.controller');

// Protected routes using query parameters
router.get('/cms/page',cmsController.getCMSPageById);

module.exports = router;
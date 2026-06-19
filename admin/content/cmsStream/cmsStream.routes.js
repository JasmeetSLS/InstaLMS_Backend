const express = require('express');
const router = express.Router();
const cmsStreamController = require('./cmsStream.controller');

// GET /api/user/cms/streams/:categoryId - Get all streams for a category
router.get('/streams/:categoryId', cmsStreamController.getStreamsByCategory);

module.exports = router;
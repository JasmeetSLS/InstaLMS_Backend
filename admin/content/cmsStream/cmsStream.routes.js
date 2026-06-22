const express = require('express');
const router = express.Router();
const cmsStreamController = require('./cmsStream.controller');
const upload = require('../../../middleware/upload.middleware');

// GET /api/user/cms/streams/:categoryId - Get all streams for a category
router.get('/streams/:categoryId', cmsStreamController.getStreamsByCategory);

router.post('/add-stream', upload.single('icon'), cmsStreamController.createStream);


module.exports = router;
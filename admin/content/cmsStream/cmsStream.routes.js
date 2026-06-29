const express = require('express');
const router = express.Router();
const cmsStreamController = require('./cmsStream.controller');
const upload = require('../../../middleware/upload.middleware');

// GET /api/user/cms/streams/:categoryId - Get all streams for a category
router.get('/streams/:categoryId', cmsStreamController.getStreamsByCategory);

router.post('/add-stream', upload.single('icon'), cmsStreamController.createStream);
// GET a single stream by ID
router.get('/stream/:streamId', cmsStreamController.getStreamById);

// PUT update a stream (only title, language, content, icon)
router.put('/stream/:streamId', upload.single('icon'), cmsStreamController.updateStream);

module.exports = router;
const express = require('express');
const router = express.Router();
const cmsSectionController = require('./csmSection.controller');

router.get('/sections/:streamId', cmsSectionController.getSectionsByStream);

module.exports = router;
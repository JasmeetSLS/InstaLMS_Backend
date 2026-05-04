const express = require('express');
const router = express.Router();
const userViewController = require('./view.controller');

router.post('/posts/view', userViewController.recordMediaView);

module.exports = router;
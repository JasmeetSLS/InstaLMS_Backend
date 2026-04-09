const express = require('express');
const router = express.Router();
const userViewController = require('./view.controller');

router.post('/posts/:post_id/view', userViewController.recordPostView);

module.exports = router;
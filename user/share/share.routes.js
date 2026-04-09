const express = require('express');
const router = express.Router();
const userShareController = require('./share.controller');

router.post('/posts/:post_id/share/:share_id', userShareController.sharePost);


module.exports = router;
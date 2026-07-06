const express = require('express');
const router = express.Router();
const notificationController = require('./notification.controller');

router.post('/notifications/:id/read', notificationController.markAsRead);
router.post('/notifications/read-bulk', notificationController.markAsReadBulk);


module.exports = router;
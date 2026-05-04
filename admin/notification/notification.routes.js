const express = require('express');
const router = express.Router();
const notificationController = require('./notification.controller');
const upload = require('../../middleware/upload.middleware');

// Routes
router.post('/create-notification', upload.single('image'), notificationController.createNotification);
router.get('/notifications', notificationController.getNotifications);

module.exports = router;
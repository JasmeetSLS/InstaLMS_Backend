const express = require('express');
const router = express.Router();
const userController = require('./user.controller');
const upload = require('../../middleware/upload.middleware');


// User management routes
router.get('/users', userController.getAllUsers);
router.get('/users/:id', userController.getUserById);
router.put('/users/:id/status', userController.updateUserStatus);
router.delete('/users/:id', userController.deleteUser);

// Alternative approach - use different base paths
router.post('/users/bulk/import', upload.single('file'), userController.bulkUploadUsers);
router.get('/users/bulk/export', userController.exportUsers);

module.exports = router;
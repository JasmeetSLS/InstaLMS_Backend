const express = require('express');
const router = express.Router();
const loginController = require('./login.controller');
const { authenticateToken, requireAdmin } = require('../../middleware/auth.middleware');

// Public routes (no authentication)
router.post('/login', loginController.adminLogin);


module.exports = router;
const express = require('express');
const router = express.Router();
const loginController = require('./login.controller');

// Public routes (no authentication)
router.post('/login', loginController.adminLogin);


module.exports = router;
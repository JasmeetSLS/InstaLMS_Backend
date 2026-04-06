const express = require('express');
const router = express.Router();
const loginController = require('../login/login.controller');

// POST /api/user/login/send-otp
router.post('/user', loginController.login);


module.exports = router;
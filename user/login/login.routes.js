const express = require('express');
const router = express.Router();
const loginController = require('../login/login.controller');

// POST /api/user/login/send-otp
router.post('/send-otp', loginController.sendLoginOTP);

// POST /api/user/login/verify-otp
router.post('/verify-otp', loginController.verifyOTPLogin);


module.exports = router;
const express = require('express');
const router = express.Router();
const registerController = require('../register/register.controller');

// POST /api/user/register
router.post('/', registerController.register);

module.exports = router;
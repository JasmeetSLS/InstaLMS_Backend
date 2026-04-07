const express = require('express');
const router = express.Router();
const registerController = require('../register/register.controller');
const upload = require('../../middleware/upload.middleware');

// POST /api/user/register
router.post('/', upload.single('profile'), registerController.register);


module.exports = router;
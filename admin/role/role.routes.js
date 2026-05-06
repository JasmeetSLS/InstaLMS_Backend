const express = require('express');
const router = express.Router();
const userRoleController = require('./role.controller');

router.get('/roles', userRoleController.getAllRoles);

module.exports = router;
const express = require('express');
const router = express.Router();
const userCategoryController = require('./category.controller');

// GET /api/user/categories - Get all active categories for users
router.get('/active-user-categories', userCategoryController.ActiveUserCategories);

module.exports = router;
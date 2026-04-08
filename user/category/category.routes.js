const express = require('express');
const router = express.Router();
const userCategoryController = require('./category.controller');

// GET /api/user/categories - Get all active categories for users
router.get('/categories', userCategoryController.getActiveCategories);

// GET /api/user/categories/:id - Get single category by ID
router.get('/categories/:id', userCategoryController.getCategoryById);

module.exports = router;
const express = require('express');
const router = express.Router();
const categoryController = require('./category.controller');

// Category routes - specific routes MUST come before parameterized routes
router.get('/categories', categoryController.getAllCategories);
router.post('/categories', categoryController.createCategory);
router.get('/categories/:id', categoryController.getCategoryById);
router.put('/categories/:id', categoryController.updateCategory);
router.put('/categories/:id/status', categoryController.updateCategoryStatus);
router.delete('/categories/:id', categoryController.deleteCategory);

module.exports = router;
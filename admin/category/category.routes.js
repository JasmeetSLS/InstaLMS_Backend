const express = require('express');
const router = express.Router();
const categoryController = require('./category.controller');
const upload = require('../../middleware/upload.middleware');

// POST /api/admin/categories - Create category with image
router.post('/add-category', upload.single('icon'), categoryController.createCategory);

// GET /api/admin/categories - Get all categories
router.get('/categories', categoryController.getAllCategories);

module.exports = router;
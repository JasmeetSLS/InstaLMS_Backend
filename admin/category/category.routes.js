const express = require('express');
const router = express.Router();
const categoryController = require('./category.controller');
const upload = require('../../middleware/upload.middleware');

router.get('/categories', categoryController.getAllCategories);
router.get('/categories/:id', categoryController.getCategoryById);
router.post('/categories', upload.single('icon'), categoryController.createCategory);
router.put('/categories/:id', upload.single('icon'), categoryController.updateCategory);
router.put('/categories/:id/status', categoryController.updateCategoryStatus);
router.delete('/categories/:id', categoryController.deleteCategory);

module.exports = router;
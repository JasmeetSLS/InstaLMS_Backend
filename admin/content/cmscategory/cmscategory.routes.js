const express = require('express');
const router = express.Router();
const cmsCategoryController = require('./cmscategory.controller');
const upload = require('../../../middleware/upload.middleware');

// POST /api/admin/cms-categories/add - Create CMS category with icon
router.post('/add-cms-category', upload.single('icon'), cmsCategoryController.createCmsCategory);

// GET /api/admin/cms-categories - Get all CMS categories
router.get('/cms-categories', cmsCategoryController.getAllCmsCategories);

module.exports = router;
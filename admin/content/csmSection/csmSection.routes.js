const express = require('express');
const router = express.Router();
const cmsSectionController = require('./csmSection.controller');

// Create
router.post('/add-section', cmsSectionController.createSection);

// Get all sections for a stream (list view)
router.get('/sections/:streamId', cmsSectionController.getSectionsByStream);

// Get single section by ID (new)
router.get('/section/:sectionId', cmsSectionController.getSectionById);

// Update section (new)
router.put('/section/:sectionId', cmsSectionController.updateSection);

// Delete section (new)
router.delete('/section/:sectionId', cmsSectionController.deleteSection);

module.exports = router;
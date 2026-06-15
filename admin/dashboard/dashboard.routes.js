const express = require('express');
const router = express.Router();
const dashboardController = require('./dashboard.controller');

router.get('/dashboard/dropdowns', dashboardController.getDropdowns);
router.get('/dashboard/stats', dashboardController.getFilteredDashboardStats);
router.get('/dashboard/leaderboard', dashboardController.getLeaderboard);
router.get('/dashboard/learning-progress', dashboardController.getLearningProgress);

module.exports = router;
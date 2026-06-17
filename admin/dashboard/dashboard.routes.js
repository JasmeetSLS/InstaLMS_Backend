const express = require('express');
const router = express.Router();
const dashboardController = require('./dashboard.controller');

router.get('/dashboard/dropdowns', dashboardController.getDropdowns);
router.get('/dashboard/stats', dashboardController.getFilteredDashboardStats);
router.get('/dashboard/leaderboard', dashboardController.getLeaderboard);
router.get('/dashboard/learning-progress', dashboardController.getLearningProgress);
router.get('/dashboard/user-content-preferences', dashboardController.getUserContentPreferences);
router.get('/dashboard/hourly-usage', dashboardController.getHourlyUsage);
router.get('/dashboard/state-wise-usage', dashboardController.getStateWiseUsage)

module.exports = router;
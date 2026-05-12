const express = require('express');
const router = express.Router();
const profileController = require('./profile.controller');

// Get my profile (user + dealer data)
router.get('/my-profile', profileController.getMyProfile);
router.get('/leaderboard',profileController.getLeaderboard);
router.get('/scorecard', profileController.getScorecard);

module.exports = router;
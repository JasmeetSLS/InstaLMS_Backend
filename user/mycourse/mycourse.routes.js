const express = require('express');
const router = express.Router();
const myCourseController = require('./mycourse.controller');

router.get('/my-courses', myCourseController.getMyCourses);

module.exports = router;
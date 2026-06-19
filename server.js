const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const { pool } = require('./config/db');

// Import routes
const registerRoutes = require('./user/register/register.routes');
const userLoginRoutes = require('./user/login/login.routes');
const adminLoginRoutes = require('./admin/login/login.routes'); // Add this
const adminUserRoutes = require('./admin/user/user.routes');
const adminCategoryRoutes = require('./admin/category/category.routes');
//Admin CMS Routes Start
const adminCmsCategoryRoutes = require('./admin/content/cmscategory/cmscategory.routes');
const adminCmsStreamRoutes = require('./admin/content/cmsStream/cmsStream.routes');
const adminCmsSectionRoutes = require('./admin/content/csmSection/csmSection.routes');
const adminCmsContentRoutes = require('./admin/content/cmsContent/cmsContent.routes');
const adminCmsAssessmentRoutes = require('./admin/content/cmsAssessment/cmsAssessment.routes');
// Admin CMS Routes End
const userCategoryRoutes = require('./user/category/category.routes'); // Add user category routes
const adminCmsRoutes = require('./admin/cms/cms.routes');
const adminPostRoutes = require('./admin/post/post.routes');
const adminRoleRoutes = require('./admin/role/role.routes');
const adminQuizRoutes = require('./admin/quiz/quiz.routes');
const adminNotificationRoutes = require('./admin/notification/notification.routes');
const adminDashboardRoutes = require('./admin/dashboard/dashboard.routes');
const userLikeRoutes = require('./user/like/like.routes');
const userCommentRoutes = require('./user/comment/comment.routes');
const userViewRoutes = require('./user/view/view.routes');
const userBookmarkRoutes = require('./user/bookmark/bookmark.routes');
const userShareRoutes = require('./user/share/share.routes');
const userPostRoutes = require('./user/post/post.routes');
const userQuizRoutes = require('./user/quiz/quiz.routes');
const userCMSRoutes = require('./user/cms/cms.routes');
const userMyCourseRoutes = require('./user/mycourse/mycourse.routes');
const userProfileRoutes = require('./user/profile/profile.routes');
const userTrackingRoutes = require('./user/tracking/tracking.routes');

const { authenticateToken, requireAdmin, requireUser } = require('./middleware/auth.middleware');



// Load environment variables
dotenv.config();

// Initialize express app
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// User Routes
app.use('/api/user/public', registerRoutes);
app.use('/api/user/public', userLoginRoutes);

//Admin Routes
app.use('/api/admin/public', adminLoginRoutes); // Add admin routes

// Protected User Routes (Require user authentication)
app.use('/api/user', authenticateToken, requireUser, userCategoryRoutes);
app.use('/api/user', authenticateToken, requireUser, userLikeRoutes);
app.use('/api/user', authenticateToken, requireUser, userCommentRoutes);
app.use('/api/user', authenticateToken, requireUser, userViewRoutes);
app.use('/api/user', authenticateToken, requireUser, userBookmarkRoutes);
app.use('/api/user', authenticateToken, requireUser, userShareRoutes);
app.use('/api/user', authenticateToken, requireUser, userPostRoutes);
app.use('/api/user', authenticateToken, requireUser, userQuizRoutes); 
app.use('/api/user', authenticateToken, requireUser, userCMSRoutes);
app.use('/api/user', authenticateToken, requireUser, userMyCourseRoutes);
app.use('/api/user', authenticateToken, requireUser, userProfileRoutes);
app.use('/api/user', authenticateToken, requireUser, userTrackingRoutes);


app.use('/api/admin', authenticateToken, requireAdmin, adminUserRoutes);
app.use('/api/admin' ,authenticateToken, requireAdmin, adminCategoryRoutes);
app.use('/api/admin' ,authenticateToken, requireAdmin, adminPostRoutes);
app.use('/api/admin' ,authenticateToken, requireAdmin, adminCmsRoutes);
app.use('/api/admin', authenticateToken, requireAdmin, adminQuizRoutes);
app.use('/api/admin', authenticateToken, requireAdmin, adminNotificationRoutes);
app.use('/api/admin', authenticateToken, requireAdmin, adminRoleRoutes);
app.use('/api/admin', authenticateToken, requireAdmin, adminDashboardRoutes);

//Admin CMS Routes
app.use('/api/admin', authenticateToken, requireAdmin, adminCmsCategoryRoutes);
app.use('/api/admin', authenticateToken, requireAdmin, adminCmsStreamRoutes );
app.use('/api/admin', authenticateToken, requireAdmin, adminCmsSectionRoutes );
app.use('/api/admin', authenticateToken, requireAdmin, adminCmsContentRoutes );
app.use('/api/admin', authenticateToken, requireAdmin, adminCmsAssessmentRoutes );

// Test route
app.get('/api', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'Server is running',
        timestamp: new Date().toISOString()
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err.stack);
    res.status(500).json({ 
        success: false,
        error: 'Something went wrong!' 
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ 
        success: false, 
        error: 'Route not found' 
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});
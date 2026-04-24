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
const userCategoryRoutes = require('./user/category/category.routes'); // Add user category routes
const adminPostRoutes = require('./admin/post/post.routes');
const userLikeRoutes = require('./user/like/like.routes');
const userCommentRoutes = require('./user/comment/comment.routes');
const userViewRoutes = require('./user/view/view.routes');
const userBookmarkRoutes = require('./user/bookmark/bookmark.routes');
const userShareRoutes = require('./user/share/share.routes');
const userPostRoutes = require('./user/post/post.routes');
const userQuizRoutes = require('./user/quiz/quiz.routes');

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


app.use('/api/admin', authenticateToken, requireAdmin, adminUserRoutes);
app.use('/api/admin' ,authenticateToken, requireAdmin, adminCategoryRoutes);
app.use('/api/admin' ,authenticateToken, requireAdmin, adminPostRoutes);

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
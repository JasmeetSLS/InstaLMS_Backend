const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Import routes
const registerRoutes = require('./user/register/register.routes');
const userLoginRoutes = require('./user/login/login.routes');
const adminLoginRoutes = require('./admin/login/login.routes'); // Add this
const adminUserRoutes = require('./admin/user/user.routes');
const adminCategoryRoutes = require('./admin/category/category.routes');

const { authenticateToken, requireAdmin, requireUser } = require('./middleware/auth.middleware');


// Import database
const { pool } = require('./config/db');

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
app.use('/api/user/register', registerRoutes);
app.use('/api/user/login', userLoginRoutes);

//Admin Routes
app.use('/api/admin', adminLoginRoutes); // Add admin routes
app.use('/api/admin', authenticateToken, requireAdmin, adminUserRoutes);
app.use('/api/admin' ,authenticateToken, requireAdmin, adminCategoryRoutes);

// Test route
app.get('/api/health', (req, res) => {
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
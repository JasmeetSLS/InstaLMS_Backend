const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Import routes
const registerRoutes = require('./user/register/register.routes');
const loginRoutes = require('./user/login/login.routes');

// Import middleware
const { authenticateToken } = require('./middleware/auth.middleware');

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

// Routes
app.use('/api/user/register', registerRoutes);
app.use('/api/user/login', loginRoutes);

// Test route
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'Server is running',
        timestamp: new Date().toISOString()
    });
});

// Protected route example
app.get('/api/protected', authenticateToken, (req, res) => {
    res.json({ 
        success: true, 
        message: 'Access granted to protected route',
        user: req.user 
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
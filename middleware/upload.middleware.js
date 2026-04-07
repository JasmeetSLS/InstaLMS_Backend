const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create uploads folder if it doesn't exist
const uploadDir = 'uploads';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Create temp folder
const tempDir = 'uploads/temp';
if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir, { recursive: true });
}

// Configure multer storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/temp');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname);
        cb(null, file.fieldname + '-' + uniqueSuffix + ext);
    }
});

// File filter for different media types
const fileFilter = (req, file, cb) => {
    const allowedTypes = [
        // Images
        'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/avif',
        // Videos
        'video/mp4', 'video/mpeg', 'video/quicktime', 'video/x-msvideo', 'video/webm',
        // WBT files (Web-Based Training)
        'application/zip', 'application/x-zip-compressed', 'application/x-scorm',
        'application/x-html', 'text/html', 'application/xhtml+xml'
    ];
    
    // Also allow common WBT file extensions
    const allowedExtensions = ['.zip', '.wbt', '.scorm', '.html', '.htm'];
    const ext = path.extname(file.originalname).toLowerCase();
    
    if (allowedTypes.includes(file.mimetype) || allowedExtensions.includes(ext)) {
        cb(null, true);
    } else {
        cb(new Error('Only image, video, GIF, and WBT files are allowed'), false);
    }
};

// Create multer upload instance
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
         fileSize: 1024 * 1024 * 1024, // 500MB
    }
});

module.exports = upload;
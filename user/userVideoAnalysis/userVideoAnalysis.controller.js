const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');

// Temporary directory for chunks (under uploads/temp)
const TEMP_CHUNK_DIR = path.join(process.cwd(), 'uploads', 'temp');

// ======================================================
// Helper: combine all chunks into final file (synchronous)
// ======================================================
const combineChunks = (fileId, totalChunks, finalPath) => {
  const chunkDir = path.join(TEMP_CHUNK_DIR, fileId);
  const writeStream = fs.createWriteStream(finalPath);

  for (let i = 0; i < totalChunks; i++) {
    const chunkPath = path.join(chunkDir, `chunk_${i}`);
    if (!fs.existsSync(chunkPath)) {
      throw new Error(`Missing chunk ${i}`);
    }
    const data = fs.readFileSync(chunkPath);
    writeStream.write(data);
    fs.unlinkSync(chunkPath); // clean up chunk
  }
  writeStream.end();
  // Remove empty chunk directory
  fs.rmdirSync(chunkDir);
};

// ======================================================
// 1. UPLOAD VIDEO CHUNK (automatic combine when complete)
// ======================================================
exports.uploadVideoChunk = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { assessment_id, question_id, fileId, chunkIndex, totalChunks } = req.body;
    const chunkFile = req.file;

    // --- 1. Validate required fields ---
    if (!assessment_id || !question_id || !fileId || chunkIndex === undefined || totalChunks === undefined || !chunkFile) {
      return res.status(400).json({
        success: false,
        error: 'assessment_id, question_id, fileId, chunkIndex, totalChunks and chunk file are required'
      });
    }

    // --- 2. Verify assessment & question (same as uploadVideo) ---
    const connection = await pool.getConnection();
    try {
      // 2a. Check assessment exists, is active, and within date range
      const [assessmentRows] = await connection.query(
        `SELECT id FROM video_analysis_assessments
         WHERE id = ? AND status = 'active'
         AND CURDATE() BETWEEN start_date AND end_date`,
        [assessment_id]
      );
      if (!assessmentRows.length) {
        return res.status(404).json({
          success: false,
          error: 'Assessment not available or inactive/out of date'
        });
      }

      // 2b. Check question exists, belongs to the assessment, and is active
      const [questionRows] = await connection.query(
        `SELECT id FROM video_assessment_questions
         WHERE id = ? AND assessment_id = ? AND status = 'active'`,
        [question_id, assessment_id]
      );
      if (!questionRows.length) {
        return res.status(404).json({
          success: false,
          error: 'Question not available in this assessment or inactive'
        });
      }
    } finally {
      connection.release(); // release connection early – we don't need it for file operations
    }

    // --- 3. Ensure temp directory exists ---
    if (!fs.existsSync(TEMP_CHUNK_DIR)) {
      fs.mkdirSync(TEMP_CHUNK_DIR, { recursive: true });
    }

    // --- 4. Create a subdirectory for this fileId ---
    const chunkDir = path.join(TEMP_CHUNK_DIR, fileId);
    if (!fs.existsSync(chunkDir)) {
      fs.mkdirSync(chunkDir, { recursive: true });
    }

    // --- 5. Save the chunk ---
    const chunkPath = path.join(chunkDir, `chunk_${chunkIndex}`);
    fs.renameSync(chunkFile.path, chunkPath);

    // --- 6. Check if all chunks have been received ---
    const receivedChunks = fs.readdirSync(chunkDir).filter(f => f.startsWith('chunk_')).length;
    if (receivedChunks === parseInt(totalChunks, 10)) {
      // ----- All chunks are here – combine them -----
      const ext = path.extname(chunkFile.originalname) || '.mp4';
      const finalFilename = `video_${Date.now()}${ext}`;

      // Build storage path
      const relativeFolder = path.join(
        'uploads',
        'AssessmentUserVideo',
        `AssessmentID_${assessment_id}`,
        `UserID_${userId}`,
        `QuestionID_${question_id}`
      );
      const absoluteFolder = path.join(process.cwd(), relativeFolder);
      if (!fs.existsSync(absoluteFolder)) {
        fs.mkdirSync(absoluteFolder, { recursive: true });
      }

      const finalAbsolutePath = path.join(absoluteFolder, finalFilename);
      combineChunks(fileId, parseInt(totalChunks, 10), finalAbsolutePath);

      // Relative path for DB (forward slashes)
      const relativePath = path.join(relativeFolder, finalFilename).replace(/\\/g, '/');

      // Insert/update record in user_video_analysis
      const dbConnection = await pool.getConnection();
      try {
        await dbConnection.query(
          `INSERT INTO user_video_analysis
           (user_id, assessment_id, question_id, video_file_path, isAwsReportGenerated)
           VALUES (?, ?, ?, ?, 0)
           ON DUPLICATE KEY UPDATE
           video_file_path = VALUES(video_file_path),
           isAwsReportGenerated = 0,
           uploaded_at = CURRENT_TIMESTAMP`,
          [userId, assessment_id, question_id, relativePath]
        );
      } finally {
        dbConnection.release();
      }

      // ✅ Return only the relative path – no base URL
      return res.status(201).json({
        success: true,
        message: 'Video uploaded successfully (all chunks combined)',
        data: {
          assessment_id: parseInt(assessment_id),
          question_id: parseInt(question_id),
          video_path: relativePath,
          fileId
        }
      });
    } else {
      // Not all chunks yet – respond with partial success
      return res.status(200).json({
        success: true,
        message: `Chunk ${chunkIndex} uploaded (${receivedChunks}/${totalChunks})`,
        data: { fileId, chunkIndex, received: receivedChunks, total: totalChunks }
      });
    }
  } catch (error) {
    console.error('Chunk upload error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to upload chunk'
    });
  }
};

// ======================================================
// 2. UPLOAD SINGLE VIDEO (non‑chunked)
// ======================================================
exports.uploadVideo = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { assessment_id, question_id } = req.body;
    const videoFile = req.file;

    // 1. Validate required fields
    if (!assessment_id || !question_id || !videoFile) {
      return res.status(400).json({
        success: false,
        error: 'assessment_id, question_id and video file are required'
      });
    }

    const connection = await pool.getConnection();
    try {
      // 2. Verify assessment
      const [assessmentRows] = await connection.query(
        `SELECT id FROM video_analysis_assessments
         WHERE id = ? AND status = 'active'
         AND CURDATE() BETWEEN start_date AND end_date`,
        [assessment_id]
      );
      if (!assessmentRows.length) {
        return res.status(404).json({
          success: false,
          error: 'Assessment not available or inactive/out of date'
        });
      }

      // 3. Verify question
      const [questionRows] = await connection.query(
        `SELECT id FROM video_assessment_questions
         WHERE id = ? AND assessment_id = ? AND status = 'active'`,
        [question_id, assessment_id]
      );
      if (!questionRows.length) {
        return res.status(404).json({
          success: false,
          error: 'Question not available in this assessment or inactive'
        });
      }

      // 4. Check if video already submitted for this user, assessment, and question
      const [existing] = await connection.query(
        `SELECT id FROM user_video_analysis
         WHERE user_id = ? AND assessment_id = ? AND question_id = ?`,
        [userId, assessment_id, question_id]
      );
      if (existing.length > 0) {
        return res.status(409).json({
          success: false,
          error: 'Video already submitted for this question'
        });
      }

      // 5. Build storage path
      const relativeFolder = path.join(
        'uploads',
        'AssessmentUserVideo',
        `AssessmentID_${assessment_id}`,
        `UserID_${userId}`,
        `QuestionID_${question_id}`
      );
      const absoluteFolder = path.join(process.cwd(), relativeFolder);
      if (!fs.existsSync(absoluteFolder)) {
        fs.mkdirSync(absoluteFolder, { recursive: true });
      }

      // 6. Save the video file
      const ext = path.extname(videoFile.originalname);
      const filename = `video_${Date.now()}${ext}`;
      const absolutePath = path.join(absoluteFolder, filename);
      fs.renameSync(videoFile.path, absolutePath);

      // 7. Relative path (forward slashes)
      const relativePath = path.join(relativeFolder, filename).replace(/\\/g, '/');

      // 8. Insert new record (no longer using ON DUPLICATE KEY UPDATE)
      await connection.query(
        `INSERT INTO user_video_analysis
         (user_id, assessment_id, question_id, video_file_path, isAwsReportGenerated)
         VALUES (?, ?, ?, ?, 0)`,
        [userId, assessment_id, question_id, relativePath]
      );

      return res.status(201).json({
        success: true,
        message: 'Video uploaded successfully',
        data: {
          assessment_id: parseInt(assessment_id),
          question_id: parseInt(question_id),
          video_path: relativePath
        }
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Upload video error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to upload video'
    });
  }
};
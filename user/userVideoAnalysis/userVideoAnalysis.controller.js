const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');


// Temporary directory for chunks (under uploads/temp)
const TEMP_CHUNK_DIR = path.join(process.cwd(), 'uploads', 'temp');

// Helper: combine all chunks into final file
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

exports.uploadVideoChunk = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { assessment_id, question_id, fileId, chunkIndex, totalChunks } = req.body;
    const chunkFile = req.file;

    // 1. Validate required fields
    if (!assessment_id || !question_id || !fileId || chunkIndex === undefined || totalChunks === undefined || !chunkFile) {
      return res.status(400).json({
        success: false,
        error: 'assessment_id, question_id, fileId, chunkIndex, totalChunks and chunk file are required'
      });
    }

    // 2. (Optional) Verify assessment/question as in your existing code – keep it if needed
    // ... (same validation queries as your uploadVideo function)

    // 3. Ensure temp directory exists
    if (!fs.existsSync(TEMP_CHUNK_DIR)) {
      fs.mkdirSync(TEMP_CHUNK_DIR, { recursive: true });
    }

    // 4. Create a subdirectory for this fileId (unique per upload session)
    const chunkDir = path.join(TEMP_CHUNK_DIR, fileId);
    if (!fs.existsSync(chunkDir)) {
      fs.mkdirSync(chunkDir, { recursive: true });
    }

    // 5. Save the chunk with index in filename
    const chunkPath = path.join(chunkDir, `chunk_${chunkIndex}`);
    fs.renameSync(chunkFile.path, chunkPath);

    // 6. Check if all chunks have been received
    const receivedChunks = fs.readdirSync(chunkDir).filter(f => f.startsWith('chunk_')).length;
    if (receivedChunks === parseInt(totalChunks, 10)) {
      // All chunks are here – combine them
      const ext = path.extname(chunkFile.originalname) || '.mp4'; // assume video
      const finalFilename = `video_${Date.now()}${ext}`;

      // Build final storage path (same logic as original)
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
      // Combine chunks into final file
      combineChunks(fileId, parseInt(totalChunks, 10), finalAbsolutePath);

      // Relative path for DB
      const relativePath = path.join(relativeFolder, finalFilename).replace(/\\/g, '/');

      // 7. Insert/update record in user_video_analysis (same as original)
      const connection = await pool.getConnection();
      try {
        await connection.query(
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
        connection.release();
      }

      const baseUrl = (process.env.BASE_URL || 'http://localhost:5000').replace(/\/+$/, '');
      const videoUrl = `${baseUrl}/${relativePath}`;

      return res.status(201).json({
        success: true,
        message: 'Video uploaded successfully (all chunks combined)',
        data: {
          assessment_id: parseInt(assessment_id),
          question_id: parseInt(question_id),
          video_url: videoUrl,
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
      // 2. Verify that the assessment exists, is active, and within date range
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

      // 3. Verify that the question exists, belongs to the assessment, and is active
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

      // 4. Build the storage path
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

      // 5. Save the video file
      const ext = path.extname(videoFile.originalname);
      const filename = `video_${Date.now()}${ext}`;
      const absolutePath = path.join(absoluteFolder, filename);
      fs.renameSync(videoFile.path, absolutePath);

      // 6. Store relative path (forward slashes, no leading slash)
      const relativePath = path.join(relativeFolder, filename).replace(/\\/g, '/');

      // 7. Insert/update record in user_video_analysis
      await connection.query(
        `INSERT INTO user_video_analysis
         (user_id, assessment_id, question_id, video_file_path, isAwsReportGenerated)
         VALUES (?, ?, ?, ?, 0)
         ON DUPLICATE KEY UPDATE
         video_file_path = VALUES(video_file_path),
         isAwsReportGenerated = 0,
         uploaded_at = CURRENT_TIMESTAMP`,
        [userId, assessment_id, question_id, relativePath]
      );

      // 8. Build full URL for response
      const baseUrl = (process.env.BASE_URL || 'http://localhost:5000').replace(/\/+$/, '');
      const videoUrl = `${baseUrl}/${relativePath}`;

      res.status(201).json({
        success: true,
        message: 'Video uploaded successfully',
        data: {
          assessment_id: parseInt(assessment_id),
          question_id: parseInt(question_id),
          video_url: videoUrl
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
const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');

/**
 * Upload a video for a specific assessment question
 * Expects: multipart/form-data with fields: assessment_id, question_id, video file
 */
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
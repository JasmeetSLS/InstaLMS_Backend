const { pool } = require('../../config/db');
const fs = require('fs');
const path = require('path');

exports.uploadVideo = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { assessment_question_id } = req.body;
    const videoFile = req.file;

    if (!assessment_question_id || !videoFile) {
      return res.status(400).json({
        success: false,
        error: 'assessment_question_id and video file are required'
      });
    }

    const connection = await pool.getConnection();
    try {
      // 1. Verify the assessment question exists and is active,
      //    and that its parent assessment is active & within date range
      const [qRows] = await connection.query(
        `SELECT aq.id 
         FROM video_assessment_questions aq
         JOIN video_analysis_assessments a ON aq.assessment_id = a.id
         WHERE aq.id = ?
           AND aq.status = 'active'
           AND a.status = 'active'
           AND CURDATE() BETWEEN a.start_date AND a.end_date`,
        [assessment_question_id]
      );
      if (!qRows.length) {
        return res.status(404).json({
          success: false,
          error: 'Question not available or assessment inactive/out of date'
        });
      }

      // 2. Save video to local directory
      const uploadDir = path.join(
        'uploads',
        'video_analysis',
        userId.toString(),
        `question_${assessment_question_id}`
      );
      if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
      }

      const ext = path.extname(videoFile.originalname);
      const filename = `${Date.now()}${ext}`;
      const videoPath = path.join(uploadDir, filename);
      fs.renameSync(videoFile.path, videoPath);
      const videoUrl = `/uploads/video_analysis/${userId}/question_${assessment_question_id}/${filename}`;

      // 3. Insert/update record in user_video_analysis
      await connection.query(
        `INSERT INTO user_video_analysis (user_id, assessment_question_id, video_url)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE video_url = ?, uploaded_at = NOW()`,
        [userId, assessment_question_id, videoUrl, videoUrl]
      );

      res.status(201).json({
        success: true,
        message: 'Video uploaded successfully',
        data: {
          assessment_question_id: parseInt(assessment_question_id),
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
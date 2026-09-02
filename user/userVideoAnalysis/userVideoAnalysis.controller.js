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
// Helper: delete old files (optional but recommended)
// ======================================================
const safeDeleteFile = (filePath) => {
  if (!filePath) return;
  const absolutePath = path.join(process.cwd(), filePath);
  try {
    if (fs.existsSync(absolutePath)) {
      fs.unlinkSync(absolutePath);
      console.log(`🗑️ Deleted old file: ${absolutePath}`);
    }
  } catch (err) {
    console.error(`Failed to delete ${absolutePath}:`, err.message);
  }
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

      // Insert/update record in user_video_analysis using SELECT + INSERT/UPDATE
      const dbConnection = await pool.getConnection();
      try {
        // Check if a record already exists for this user, assessment, question
        const [existing] = await dbConnection.query(
          `SELECT id, video_file_path, aws_file_path, audio_file_path, GeminiReportFilePath
           FROM user_video_analysis
           WHERE user_id = ? AND assessment_id = ? AND question_id = ?`,
          [userId, assessment_id, question_id]
        );

        if (existing.length > 0) {
          // --- Delete old files (optional) ---
          const old = existing[0];
          safeDeleteFile(old.video_file_path);
          safeDeleteFile(old.aws_file_path);
          safeDeleteFile(old.audio_file_path);
          safeDeleteFile(old.GeminiReportFilePath);

          // --- UPDATE existing record ---
          await dbConnection.query(
            `UPDATE user_video_analysis
             SET video_file_path = ?,
                 isAwsReportGenerated = 0,
                 isGeminiReportGenerated = 0,
                 aws_file_path = NULL,
                 GeminiReportFilePath = NULL,
                 audio_file_path = NULL,
                 uploaded_at = CURRENT_TIMESTAMP
             WHERE id = ?`,
            [relativePath, existing[0].id]
          );
        } else {
          // --- INSERT new record ---
          await dbConnection.query(
            `INSERT INTO user_video_analysis
             (user_id, assessment_id, question_id, video_file_path, isAwsReportGenerated, isGeminiReportGenerated)
             VALUES (?, ?, ?, ?, 0, 0)`,
            [userId, assessment_id, question_id, relativePath]
          );
        }
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
    const { assessment_id, question_id } = req.query;
    const videoFile = req.file;

    // 1. Validate required fields
    if (!assessment_id || !question_id || !videoFile) {
      return res.status(400).json({
        success: false,
        error: 'assessment_id, question_id (as query params) and video file are required'
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

      // 4. Build storage path
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

      // 6. Relative path (forward slashes)
      const relativePath = path.join(relativeFolder, filename).replace(/\\/g, '/');

      // 7. Check if a record already exists for this user, assessment, question
      const [existing] = await connection.query(
        `SELECT id, video_file_path, aws_file_path, audio_file_path, GeminiReportFilePath
         FROM user_video_analysis
         WHERE user_id = ? AND assessment_id = ? AND question_id = ?`,
        [userId, assessment_id, question_id]
      );

      if (existing.length > 0) {
        // --- Delete old files (optional) ---
        const old = existing[0];
        safeDeleteFile(old.video_file_path);
        safeDeleteFile(old.aws_file_path);
        safeDeleteFile(old.audio_file_path);
        safeDeleteFile(old.GeminiReportFilePath);

        // --- UPDATE existing record ---
        await connection.query(
          `UPDATE user_video_analysis
           SET video_file_path = ?,
               isAwsReportGenerated = 0,
               isGeminiReportGenerated = 0,
               aws_file_path = NULL,
               GeminiReportFilePath = NULL,
               audio_file_path = NULL,
               uploaded_at = CURRENT_TIMESTAMP
           WHERE id = ?`,
          [relativePath, existing[0].id]
        );
      } else {
        // --- INSERT new record ---
        await connection.query(
          `INSERT INTO user_video_analysis
           (user_id, assessment_id, question_id, video_file_path, isAwsReportGenerated, isGeminiReportGenerated)
           VALUES (?, ?, ?, ?, 0, 0)`,
          [userId, assessment_id, question_id, relativePath]
        );
      }

      return res.status(201).json({
        success: true,
        message: 'Video uploaded successfully',
        data: {
          assessment_id: parseInt(assessment_id, 10),
          question_id: parseInt(question_id, 10),
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

// ======================================================
// 3. GET ASSESSMENTS (unchanged, included for completeness)
// ======================================================
exports.getAssessments = async (req, res) => {
  try {
    const userId = req.user.userId;

    const connection = await pool.getConnection();
    try {
      // 1. Get all active assessments within date range
      const [assessments] = await connection.query(
        `SELECT id, title, description, start_date, end_date
         FROM video_analysis_assessments
         WHERE status = 'active'
           AND CURDATE() BETWEEN start_date AND end_date
         ORDER BY start_date ASC`
      );

      if (assessments.length === 0) {
        return res.status(200).json({
          success: true,
          data: [],
          message: 'No active assessments available'
        });
      }

      const assessmentIds = assessments.map(a => a.id);

      // 2. Fetch overall summaries for these assessments for this user
      const [overallRows] = await connection.query(
        `SELECT * FROM video_analysis_overall_summary
         WHERE userId = ? AND assessmentId IN (${assessmentIds.map(() => '?').join(',')})`,
        [userId, ...assessmentIds]
      );
      const overallMap = {};
      overallRows.forEach(o => {
        overallMap[o.assessmentId] = o;
      });

      // 3. Fetch user video records and related summaries/evaluations
      const [videoRecords] = await connection.query(
        `SELECT id, assessment_id, question_id, video_file_path
         FROM user_video_analysis
         WHERE user_id = ? AND assessment_id IN (${assessmentIds.map(() => '?').join(',')})`,
        [userId, ...assessmentIds]
      );
      const videoMap = {};
      const questionIds = [];
      videoRecords.forEach(v => {
        const key = `${v.assessment_id}_${v.question_id}`;
        videoMap[key] = { id: v.id, video_file_path: v.video_file_path };
        questionIds.push(v.question_id);
      });

      const summaryMap = {};
      const evalMap = {};
      if (questionIds.length > 0) {
        const [summaries] = await connection.query(
          `SELECT * FROM video_analysis_question_summary
           WHERE userId = ? AND questionId IN (${questionIds.map(() => '?').join(',')})`,
          [userId, ...questionIds]
        );
        summaries.forEach(s => {
          summaryMap[s.questionId] = s;
        });

        const videoIds = videoRecords.map(v => v.id);
        const [evaluations] = await connection.query(
          `SELECT * FROM video_analysis_question_answer_evaluation
           WHERE user_video_analysis_id IN (${videoIds.map(() => '?').join(',')})`,
          videoIds
        );
        evaluations.forEach(e => {
          evalMap[e.user_video_analysis_id] = e;
        });
      }

      // 4. Build the response
      const result = [];
      for (const assessment of assessments) {
        const [questions] = await connection.query(
          `SELECT q.id, q.question_text, q.sort_order, l.name AS language
           FROM video_assessment_questions q
           LEFT JOIN languages l ON q.language_id = l.id
           WHERE q.assessment_id = ? AND q.status = 'active'
           ORDER BY q.sort_order ASC`,
          [assessment.id]
        );

        const questionsWithReport = [];
        for (const question of questions) {
          const key = `${assessment.id}_${question.id}`;
          const videoInfo = videoMap[key];
          const submitted = !!videoInfo;
          const video_path = submitted ? videoInfo.video_file_path : null;
          const videoAnalysisId = submitted ? videoInfo.id : null;

          let report = null;
          if (submitted) {
            const summary = summaryMap[question.id] || {};
            const evalData = evalMap[videoAnalysisId] || {};

            // ---- NEW: compute combined score ----
            // Get overall face/voice/emotion for this assessment (from overallMap)
            const overallFace = overallMap[assessment.id]?.overall_face || 0;
            const overallVoice = overallMap[assessment.id]?.overall_voice || 0;
            const overallEmotion = overallMap[assessment.id]?.overall_emotion || 0;

            // Original evaluation score (out of 70)
            const evalScore = parseFloat(evalData.score) || 0;

            // Convert overall percentages (out of 100) to 0‑10 scale
            const faceScore = overallFace / 10;
            const voiceScore = overallVoice / 10;
            const emotionScore = overallEmotion / 10;

            // Combined score (out of 100)
            const combinedScore = evalScore + faceScore + voiceScore + emotionScore;
            const combinedRounded = Math.round(combinedScore * 100) / 100; // 2 decimal places
            // --------------------------------------------------------

            // Parse keywords (unchanged)
            let matchedKeywords = [];
            let missingKeywords = [];
            try {
              matchedKeywords = evalData.matched_keywords ? JSON.parse(evalData.matched_keywords) : [];
              missingKeywords = evalData.missing_keywords ? JSON.parse(evalData.missing_keywords) : [];
            } catch (e) {
              matchedKeywords = evalData.matched_keywords ? evalData.matched_keywords.split(',').map(k => k.trim()) : [];
              missingKeywords = evalData.missing_keywords ? evalData.missing_keywords.split(',').map(k => k.trim()) : [];
            }

            const totalWords = evalData.transcript ? evalData.transcript.split(/\s+/).filter(Boolean).length : 0;

            // Build the report object – note: score and score_percentage now use the combined value
            report = {
              transcript: evalData.transcript || null,
              face: {
                Confidence: parseFloat(summary.face_interest) || 0,
                Attention: parseFloat(summary.face_concentration) || 0,
                Doubt: parseFloat(summary.face_doubt) || 0,
                Anxiety: parseFloat(summary.face_anxiety) || 0
              },
              voice: {
                Confidence: parseFloat(summary.voice_interest) || 0,
                Attention: parseFloat(summary.voice_concentration) || 0,
                Doubt: parseFloat(summary.voice_doubt) || 0,
                Anxiety: parseFloat(summary.voice_anxiety) || 0
              },
              emotion: {
                Happy: parseFloat(summary.emotion_happy) || 0,
                Neutral: parseFloat(summary.emotion_sadness) || 0,
                Fear: parseFloat(summary.emotion_fear) || 0,
                Confusion: parseFloat(summary.emotion_confusion) || 0
              },
              // ---- UPDATED: score and score_percentage now reflect combined value ----
              score: combinedRounded,               // out of 100
              score_percentage: combinedRounded,    // out of 100 (same as score)
              // ---------------------------------------------------------------------
              grammar_mistakes: parseInt(evalData.grammar_mistakes) || 0,
              sentiment: evalData.sentiment || 'neutral',
              emotion_analysis: evalData.emotion || 'neutral',
              word: {
                total_words: totalWords,
                keyword_count: matchedKeywords.length,
                matched_keywords: JSON.stringify(matchedKeywords),
                missing_keywords: JSON.stringify(missingKeywords)
              },
              correctness: {
                Correctness: evalData.correctness || 'Not evaluated',
                Understanding: evalData.understanding || 'Not evaluated',
                'Depth and Clarity': evalData.depth_and_clarity || 'Not evaluated',
                Explanation: evalData.explanation || 'Not evaluated'
              }
            };
          }

          questionsWithReport.push({
            id: question.id,
            question_text: question.question_text,
            sort_order: question.sort_order,
            language: question.language,
            submitted,
            video_path,
            final_submit: 0, // kept as per your existing field
            report
          });
        }

        // Overall assessment-level summary (unchanged)
        let overall = { face: 0, voice: 0, emotion: 0 };
        if (overallMap[assessment.id]) {
          const ov = overallMap[assessment.id];
          overall.face = parseFloat(ov.overall_face) || 0;
          overall.voice = parseFloat(ov.overall_voice) || 0;
          overall.emotion = parseFloat(ov.overall_emotion) || 0;
        }

        result.push({
          id: assessment.id,
          title: assessment.title,
          description: assessment.description,
          start_date: assessment.start_date,
          end_date: assessment.end_date,
          expected_score: 60,     // if needed – keep as is
          total_score: 100,       // if needed – keep as is
          overall,
          questions: questionsWithReport
        });
      }

      res.status(200).json({
        success: true,
        data: result
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Error fetching assessments:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch assessments'
    });
  }
};


// ======================================================
// FINAL SUBMIT (assessment_id & question_id as query params)
// ======================================================
exports.finalSubmit = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { assessment_id, question_id } = req.query;

    // Validate required query params
    if (!assessment_id || !question_id) {
      return res.status(400).json({
        success: false,
        error: 'assessment_id and question_id are required as query params'
      });
    }

    const connection = await pool.getConnection();
    try {
      // Fetch the record
      const [rows] = await connection.query(
        `SELECT id, final_submit
         FROM user_video_analysis
         WHERE user_id = ? AND assessment_id = ? AND question_id = ?`,
        [userId, assessment_id, question_id]
      );

      if (rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: 'Record not found for this user, assessment, and question'
        });
      }

      // Check if already final submitted
      if (rows[0].final_submit === 1) {
        return res.status(400).json({
          success: false,
          error: 'Already final submitted'
        });
      }

      // Update to 1
      await connection.query(
        `UPDATE user_video_analysis SET final_submit = 1 WHERE id = ?`,
        [rows[0].id]
      );

      return res.status(200).json({
        success: true,
        message: 'Final submission successful'
      });

    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Final submit error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to final submit'
    });
  }
};
const { pool } = require('../../config/db');

exports.getUsersWithVideoAnalysis = async (req, res) => {
  try {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query(`
        SELECT DISTINCT
          u.id,
          u.name,
          u.email,
          u.employee_id,
          u.phone,
          r.name AS role
        FROM user_video_analysis uva
        JOIN users u ON uva.user_id = u.id
        LEFT JOIN roles r ON u.role_id = r.id
        ORDER BY u.name ASC
      `);

      res.json({
        success: true,
        data: rows,
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Get users with video analysis error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};
// Get full report for a specific user (matching reference response structure)
exports.getUserReport = async (req, res) => {
  try {
    const { userId } = req.params;
    const connection = await pool.getConnection();

    try {
      // 1. Get user details
      const [userRows] = await connection.query(
        `SELECT u.id, u.name, u.email, u.employee_id, u.phone, r.name AS role
         FROM users u
         LEFT JOIN roles r ON u.role_id = r.id
         WHERE u.id = ?`,
        [userId]
      );
      if (userRows.length === 0) {
        return res.status(404).json({ success: false, error: 'User not found' });
      }
      const user = userRows[0];

      // 2. Get all video analysis records for this user
      const [videos] = await connection.query(
        `SELECT uva.*, 
                a.title AS assessment_title,
                a.start_date, a.end_date,
                vq.question_text, vq.expected_answer, vq.keywords,
                l.code AS language_code
         FROM user_video_analysis uva
         JOIN video_analysis_assessments a ON uva.assessment_id = a.id
         JOIN video_assessment_questions vq ON uva.question_id = vq.id
         JOIN languages l ON vq.language_id = l.id
         WHERE uva.user_id = ?
         ORDER BY uva.uploaded_at ASC`,
        [userId]
      );

      if (videos.length === 0) {
        return res.status(404).json({
          success: false,
          error: 'No video analysis records found for this user'
        });
      }

      // 3. Get question summaries
      const videoIds = videos.map(v => v.id);
      const placeholders = videoIds.map(() => '?').join(',');

      const [summaries] = await connection.query(
        `SELECT * FROM video_analysis_question_summary
         WHERE userId = ? AND questionId IN (
           SELECT question_id FROM user_video_analysis WHERE id IN (${placeholders})
         )`,
        [userId, ...videoIds]
      );
      const summaryMap = {};
      summaries.forEach(s => {
        summaryMap[s.questionId] = s;
      });

      // 4. Get evaluation data
      const [evaluations] = await connection.query(
        `SELECT * FROM video_analysis_question_answer_evaluation
         WHERE user_video_analysis_id IN (${placeholders})`,
        videoIds
      );
      const evalMap = {};
      evaluations.forEach(e => {
        evalMap[e.user_video_analysis_id] = e;
      });

      // 5. Get overall summary
      const assessmentIds = [...new Set(videos.map(v => v.assessment_id))];
      const [overallRows] = await connection.query(
        `SELECT * FROM video_analysis_overall_summary
         WHERE userId = ? AND assessmentId IN (${assessmentIds.map(() => '?').join(',')})`,
        [userId, ...assessmentIds]
      );
      const overallMap = {};
      overallRows.forEach(o => {
        overallMap[o.assessmentId] = o;
      });

      // 6. Build assessment response (take the first assessment - adjust as needed)
      const firstVideo = videos[0];
      const assessment = {
        id: firstVideo.assessment_id,
        title: firstVideo.assessment_title,
        attempted_date: new Date(videos[0].uploaded_at).toISOString().split('T')[0],
        overall: {
          face: 0,
          voice: 0,
          emotion: 0
        }
      };

      // Get overall from DB
      if (overallMap[firstVideo.assessment_id]) {
        const ov = overallMap[firstVideo.assessment_id];
        assessment.overall.face = parseFloat(ov.overall_face) || 0;
        assessment.overall.voice = parseFloat(ov.overall_voice) || 0;
        assessment.overall.emotion = parseFloat(ov.overall_emotion) || 0;
      }

      // 7. Build questions array
      const questions = videos.map(v => {
        const summary = summaryMap[v.question_id] || {};
        const evalData = evalMap[v.id] || {};

        // Parse matched/missing keywords from evaluation table (JSON stored as text)
        let matchedKeywords = [];
        let missingKeywords = [];
        try {
          matchedKeywords = evalData.matched_keywords ? JSON.parse(evalData.matched_keywords) : [];
          missingKeywords = evalData.missing_keywords ? JSON.parse(evalData.missing_keywords) : [];
        } catch (e) {
          matchedKeywords = evalData.matched_keywords ? evalData.matched_keywords.split(',').map(k => k.trim()) : [];
          missingKeywords = evalData.missing_keywords ? evalData.missing_keywords.split(',').map(k => k.trim()) : [];
        }

        // Compute word metrics
        const keywordsList = v.keywords ? v.keywords.split(',').map(k => k.trim()).filter(Boolean) : [];
        const totalKeywordCount = keywordsList.length;
        const matchedCount = matchedKeywords.length;
        const totalWords = evalData.transcript ? evalData.transcript.split(/\s+/).filter(Boolean).length : 0;
        // Build base URL for video
        return {
          question: v.question_text,
          video:  v.video_file_path,
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
          score: parseFloat(evalData.score) || 0,
          score_percentage: parseFloat(evalData.score_percentage) || 0,
          grammar_mistakes: parseInt(evalData.grammar_mistakes) || 0,
          sentiment: evalData.sentiment || 'neutral',
          emotion_analysis: evalData.emotion || 'neutral',
          word: {
            total_words: totalWords,
            keyword_count: matchedCount,
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
      });

      // 8. Build final response
      res.json({
        success: true,
        assessment: assessment,
        user: {
          id: user.id,
          name: user.name,
          designation: user.role || 'N/A',
          userid: user.employee_id || 'N/A'
        },
        questions: questions
      });

    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Get user report error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
};
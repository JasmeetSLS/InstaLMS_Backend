// services/VideoEmotionService.js
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const ffmpeg = require('fluent-ffmpeg');
const { pool } = require('../config/db');
const { processVideo } = require('../video_emotion');

// ================= FFMPEG PATH DETECTION =================
function findFFmpegPath() {
  if (process.env.FFMPEG_PATH) {
    console.log(`🔧 Using FFMPEG_PATH from env: ${process.env.FFMPEG_PATH}`);
    return process.env.FFMPEG_PATH;
  }
  return 'ffmpeg'; // fallback
}

let ffmpegPath = findFFmpegPath();
ffmpeg.setFfmpegPath(ffmpegPath);

// ================= EXTRACT AUDIO =================
const extractAudio = (videoPath, audioPath) => {
  return new Promise((resolve, reject) => {
    ffmpeg(videoPath)
      .audioCodec('pcm_s16le')
      .audioFrequency(16000)
      .audioChannels(1)
      .format('wav')
      .on('end', resolve)
      .on('error', reject)
      .save(audioPath);
  });
};

// ================= MAIN PROCESSING =================
async function processVideoEmotions() {
  console.log('='.repeat(60));
  console.log(`📹 Video Emotion Service Started: ${new Date().toLocaleString()}`);
  console.log('='.repeat(60));

  const connection = await pool.getConnection();
  try {
    // Fetch pending videos (isAwsReportGenerated = 0)
    const [pending] = await connection.query(`
      SELECT id, user_id, assessment_id, question_id, video_file_path
      FROM user_video_analysis
      WHERE isAwsReportGenerated = 0
        AND video_file_path IS NOT NULL
        AND video_file_path != ''
      LIMIT 2
    `);

    if (!pending || pending.length === 0) {
      console.log('✅ No pending videos found.');
      return { success: true, message: 'No pending videos', total: 0 };
    }

    console.log(`📹 Found ${pending.length} videos to process.`);
    let successCount = 0, failCount = 0;
    const results = [];

    for (const record of pending) {
      const { id, user_id, assessment_id, question_id, video_file_path } = record;

      try {
        console.log(`\n🔹 Processing video ID: ${id}`);
        console.log(`   User: ${user_id}, Assessment: ${assessment_id}, Question: ${question_id}`);

        // Lock record
        await connection.query(
          `UPDATE user_video_analysis SET isAwsReportGenerated = 1 WHERE id = ?`,
          [id]
        );

        // Build absolute path to the existing video
        const absoluteVideoPath = path.join(process.cwd(), video_file_path);
        if (!fs.existsSync(absoluteVideoPath)) {
          throw new Error(`Video file not found: ${absoluteVideoPath}`);
        }
        console.log(`   Using local video: ${absoluteVideoPath}`);

        // Build folder for output (audio + JSON) – same as video folder
        const baseFolder = path.dirname(absoluteVideoPath);
        if (!fs.existsSync(baseFolder)) {
          fs.mkdirSync(baseFolder, { recursive: true });
        }

        // Extract audio
        const audioFileName = `audio_${Date.now()}.wav`;
        const audioPath = path.join(baseFolder, audioFileName);
        await extractAudio(absoluteVideoPath, audioPath);
        console.log(`   ✅ Audio extracted: ${audioPath}`);

        // Run emotion analysis (local file)
        console.log('   ⏳ Running emotion analysis...');
        const result = await processVideo(absoluteVideoPath, ffmpegPath);
        console.log('   ✅ Emotion analysis complete.');

        // Save JSON result
        const resultFileName = `result_${Date.now()}.json`;
        const resultFilePath = path.join(baseFolder, resultFileName);
        fs.writeFileSync(resultFilePath, JSON.stringify(result, null, 2));

        // Build relative paths for DB (relative to project root)
        const relativeResultPath = path.relative(process.cwd(), resultFilePath).replace(/\\/g, '/');
        const relativeAudioPath = path.relative(process.cwd(), audioPath).replace(/\\/g, '/');

        // Update user_video_analysis
        await connection.query(
          `UPDATE user_video_analysis
           SET isAwsReportGenerated = 2,
               aws_file_path = ?,
               audio_file_path = ?
           WHERE id = ?`,
          [relativeResultPath, relativeAudioPath, id]
        );

        // Insert/update into video_analysis_question_summary
        const face = result.scores.FACE_Expression.details;
        const voice = result.scores.VOICE_Expression.details;
        const emotion = result.scores.EMOTION_Expression.details;

        // Check if summary already exists
        const [existingSummary] = await connection.query(
          `SELECT id FROM video_analysis_question_summary
           WHERE userId = ? AND assessmentId = ? AND questionId = ?`,
          [user_id, assessment_id, question_id]
        );

        if (existingSummary.length > 0) {
          // UPDATE
          await connection.query(
            `UPDATE video_analysis_question_summary
             SET face_interest = ?, face_concentration = ?, face_doubt = ?, face_anxiety = ?,
                 face_confidence = ?, face_attention = ?,
                 voice_interest = ?, voice_concentration = ?, voice_doubt = ?, voice_anxiety = ?,
                 voice_confidence = ?, voice_attention = ?,
                 emotion_joy = ?, emotion_sadness = ?, emotion_fear = ?, emotion_confusion = ?,
                 emotion_happy = ?, emotion_neutral = ?,
                 updatedAt = CURRENT_TIMESTAMP
             WHERE userId = ? AND assessmentId = ? AND questionId = ?`,
            [
              face.Confidence || 0,
              face.Attention || 0,
              face.Doubt || 0,
              face.Anxiety || 0,
              (face.Confidence || 0) + (face.Attention || 0),
              face.Attention || 0,
              voice.Confidence || 0,
              voice.Attention || 0,
              voice.Doubt || 0,
              voice.Anxiety || 0,
              (voice.Confidence || 0) + (voice.Attention || 0),
              voice.Attention || 0,
              emotion.Happy || 0,
              emotion.Neutral || 0,
              emotion.Fear || 0,
              emotion.Confusion || 0,
              emotion.Happy || 0,
              (emotion.Neutral || 0) + (emotion.Happy || 0),
              user_id, assessment_id, question_id
            ]
          );
        } else {
          // INSERT
          await connection.query(
            `INSERT INTO video_analysis_question_summary (
              userId, assessmentId, questionId,
              face_interest, face_concentration, face_doubt, face_anxiety, face_confidence, face_attention,
              voice_interest, voice_concentration, voice_doubt, voice_anxiety, voice_confidence, voice_attention,
              emotion_joy, emotion_sadness, emotion_fear, emotion_confusion, emotion_happy, emotion_neutral
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
              user_id, assessment_id, question_id,
              face.Confidence || 0,
              face.Attention || 0,
              face.Doubt || 0,
              face.Anxiety || 0,
              (face.Confidence || 0) + (face.Attention || 0),
              face.Attention || 0,
              voice.Confidence || 0,
              voice.Attention || 0,
              voice.Doubt || 0,
              voice.Anxiety || 0,
              (voice.Confidence || 0) + (voice.Attention || 0),
              voice.Attention || 0,
              emotion.Happy || 0,
              emotion.Neutral || 0,
              emotion.Fear || 0,
              emotion.Confusion || 0,
              emotion.Happy || 0,
              (emotion.Neutral || 0) + (emotion.Happy || 0)
            ]
          );
        }

        successCount++;
        results.push({ videoId: id, success: true });

      } catch (err) {
        console.error(`❌ Error processing video ${id}:`, err.message);
        // Unlock on failure
        await connection.query(
          `UPDATE user_video_analysis SET isAwsReportGenerated = 0 WHERE id = ?`,
          [id]
        );
        failCount++;
        results.push({ videoId: id, success: false, error: err.message });
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log(`📊 Summary: ${successCount} succeeded, ${failCount} failed`);
    console.log('='.repeat(60));

    return { success: true, total: pending.length, successCount, failCount, results };
  } catch (err) {
    console.error('❌ Database error:', err.message);
    return { success: false, error: err.message };
  } finally {
    connection.release();
  }
}

module.exports = { processVideoEmotions };
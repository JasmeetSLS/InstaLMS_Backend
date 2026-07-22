// services/GeminiReportService.js
require('dotenv').config();
const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const { pool } = require('../config/db');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { GoogleAIFileManager } = require('@google/generative-ai/server');

// Gemini Config
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
if (!GEMINI_API_KEY) {
  console.warn('⚠️ GEMINI_API_KEY not set. Gemini service will not work.');
}
const fileManager = new GoogleAIFileManager(GEMINI_API_KEY);
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

const GEMINI_MODEL = "gemini-3.1-flash-lite";
const GEMINI_FALLBACK_MODEL = "gemini-3.5-flash";

// Configuration from environment (with defaults)
const MAX_RETRIES = parseInt(process.env.GEMINI_MAX_RETRIES) || 5;
const RETRY_DELAY = parseInt(process.env.GEMINI_RETRY_DELAY) || 2000;
const BATCH_SIZE = parseInt(process.env.GEMINI_BATCH_SIZE) || 2;
const RATE_LIMIT_REQUESTS = parseInt(process.env.GEMINI_RATE_LIMIT_REQUESTS) || 3;
const RATE_LIMIT_WINDOW = parseInt(process.env.GEMINI_RATE_LIMIT_WINDOW) || 60000;

// ============================================================
//  HELPER: RETRY WITH EXPONENTIAL BACKOFF
// ============================================================
async function retryWithBackoff(fn, maxRetries = MAX_RETRIES, initialDelay = RETRY_DELAY) {
  let lastError;
  let delay = initialDelay;
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      const shouldRetry = error.status === 503 || error.status === 429 ||
                          error.code === 'ECONNRESET' || error.code === 'ETIMEDOUT';
      if (!shouldRetry) throw error;
      console.log(`Attempt ${attempt}/${maxRetries} failed (${error.status || error.code}). Retrying in ${delay}ms...`);
      await new Promise(r => setTimeout(r, delay));
      delay = Math.min(delay * 2, 30000) + Math.random() * 1000;
    }
  }
  throw lastError;
}

// ============================================================
//  HELPER: RATE LIMITER
// ============================================================
class RateLimiter {
  constructor(maxRequests = RATE_LIMIT_REQUESTS, timeWindow = RATE_LIMIT_WINDOW) {
    this.maxRequests = maxRequests;
    this.timeWindow = timeWindow;
    this.timestamps = [];
  }
  async waitForSlot() {
    const now = Date.now();
    this.timestamps = this.timestamps.filter(t => now - t < this.timeWindow);
    if (this.timestamps.length >= this.maxRequests) {
      const oldest = this.timestamps[0];
      const waitTime = this.timeWindow - (now - oldest);
      console.log(`Rate limit reached. Waiting ${Math.round(waitTime)}ms...`);
      await new Promise(r => setTimeout(r, waitTime + 100));
      return this.waitForSlot();
    }
    this.timestamps.push(now);
  }
}
const rateLimiter = new RateLimiter();

// ============================================================
//  HELPER: CHECK GEMINI AVAILABILITY
// ============================================================
async function checkGeminiAvailability() {
  try {
    const model = genAI.getGenerativeModel({ model: GEMINI_MODEL });
    await model.generateContent('test');
    return true;
  } catch (err) {
    console.warn('Gemini API availability check failed:', err.message);
    return false;
  }
}

// ============================================================
//  TRANSCRIBE AUDIO (Gemini File API - supports larger files)
// ============================================================
async function transcribeAudio(fileFullPath, language = null) {
  try {
    await fsp.access(fileFullPath).catch(() => {
      throw new Error(`Audio file not found: ${fileFullPath}`);
    });

    await rateLimiter.waitForSlot();

    const upload = await retryWithBackoff(async () => {
      return await fileManager.uploadFile(fileFullPath, {
        mimeType: 'audio/wav',
        displayName: 'interview_audio.wav',
      });
    });

    const model = genAI.getGenerativeModel({ model: GEMINI_MODEL });

    let instructions = `
      You are a multilingual transcription expert.
      - Transcribe exactly as spoken.
      - Do NOT translate.
      - Return only clean text.
    `;
    if (language) {
      instructions += `\n- Transcribe in the following language: ${language}.`;
    } else {
      instructions += `\n- Detect language automatically.`;
    }

    const result = await retryWithBackoff(async () => {
      return await model.generateContent([
        { fileData: { fileUri: upload.file.uri, mimeType: upload.file.mimeType } },
        instructions,
      ]);
    });

    const transcript = result.response?.text() || '';
    return transcript.trim();
  } catch (err) {
    console.error('Gemini transcription error:', err.message);
    throw err;
  }
}

// ============================================================
//  EVALUATE ANSWER USING GEMINI
// ============================================================
async function evaluateAnswer(question, reference, keywords, userAnswer) {
  try {
    await rateLimiter.waitForSlot();

    let model = genAI.getGenerativeModel({ model: GEMINI_MODEL });

    const prompt = `You are an AI tutor evaluating a user's answer. Provide a structured JSON response with these keys:
- score (integer, 0-70)
- score_percentage (integer)
- grammar_mistakes (integer)
- sentiment (string)
- emotion (string)
- correctness (string)
- understanding (string)
- depth_and_clarity (string)
- explanation (string)
- matched_keywords (array)
- missing_keywords (array)

Question: ${question}
Reference Answer: ${reference}
Keywords: ${keywords}
User Answer: ${userAnswer}
`;

    let res;
    try {
      res = await retryWithBackoff(() => model.generateContent(prompt));
    } catch (primaryError) {
      if (primaryError.status === 503 || primaryError.status === 429) {
        console.log('Primary model unavailable, trying fallback...');
        model = genAI.getGenerativeModel({ model: GEMINI_FALLBACK_MODEL });
        res = await retryWithBackoff(() => model.generateContent(prompt));
      } else {
        throw primaryError;
      }
    }

    const text = res.response?.text() || '{}';

    let cleaned = text.replace(/```json/g, '').replace(/```/g, '').trim();
    if (!cleaned.startsWith('{')) cleaned = '{' + cleaned;
    if (!cleaned.endsWith('}')) cleaned = cleaned + '}';
    try {
      return JSON.parse(cleaned);
    } catch (e) {
      console.error('JSON parse error. Raw:', text);
      return {
        score: 0,
        score_percentage: 0,
        grammar_mistakes: 0,
        sentiment: 'neutral',
        emotion: 'neutral',
        correctness: 'Unable to evaluate',
        understanding: 'Unable to evaluate',
        depth_and_clarity: 'Unable to evaluate',
        explanation: 'Parse error',
        matched_keywords: [],
        missing_keywords: keywords ? keywords.split(',').map(k => k.trim()) : [],
      };
    }
  } catch (err) {
    console.error('Evaluation error:', err.message);
    throw err;
  }
}

// ============================================================
//  INSERT/UPDATE EVALUATION DATA
// ============================================================
async function insertOrUpdateEvaluation(evaluationData) {
  const {
    user_video_analysis_id,
    user_id,
    question_id,
    transcript,
    evaluation,
    score,
    score_percentage,
    reportFilePath,
  } = evaluationData;

  const connection = await pool.getConnection();
  try {
    const matchedKeywords = evaluation.matched_keywords || [];
    const missingKeywords = evaluation.missing_keywords || [];

    const query = `
      INSERT INTO video_analysis_question_answer_evaluation (
        user_video_analysis_id, user_id, question_id,
        transcript, score, score_percentage, grammar_mistakes,
        sentiment, emotion, correctness, understanding,
        depth_and_clarity, explanation, matched_keywords, missing_keywords
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        user_id = VALUES(user_id),
        question_id = VALUES(question_id),
        transcript = VALUES(transcript),
        score = VALUES(score),
        score_percentage = VALUES(score_percentage),
        grammar_mistakes = VALUES(grammar_mistakes),
        sentiment = VALUES(sentiment),
        emotion = VALUES(emotion),
        correctness = VALUES(correctness),
        understanding = VALUES(understanding),
        depth_and_clarity = VALUES(depth_and_clarity),
        explanation = VALUES(explanation),
        matched_keywords = VALUES(matched_keywords),
        missing_keywords = VALUES(missing_keywords),
        updated_at = CURRENT_TIMESTAMP
    `;

    const params = [
      user_video_analysis_id,
      user_id,
      question_id,
      transcript,
      score,
      score_percentage,
      evaluation.grammar_mistakes || 0,
      evaluation.sentiment || 'neutral',
      evaluation.emotion || 'neutral',
      evaluation.correctness || '',
      evaluation.understanding || '',
      evaluation.depth_and_clarity || '',
      evaluation.explanation || '',
      JSON.stringify(matchedKeywords),
      JSON.stringify(missingKeywords),
    ];

    await connection.query(query, params);
    console.log(`✅ Evaluation data inserted/updated for video ${user_video_analysis_id}`);
  } finally {
    connection.release();
  }
}

// ============================================================
//  MAIN REPORT GENERATOR
// ============================================================
async function generateGeminiReport() {
  console.log('='.repeat(60));
  console.log(`🤖 Gemini Report Service Started: ${new Date().toLocaleString()}`);
  console.log('='.repeat(60));

  const isAvailable = await checkGeminiAvailability();
  if (!isAvailable) {
    console.warn('Gemini API unavailable. Skipping this run.');
    return { success: false, error: 'Gemini unavailable' };
  }

  const connection = await pool.getConnection();
  try {
    // Fetch videos where AWS emotion is done, Gemini pending, and audio exists
    const [pending] = await connection.query(`
      SELECT uva.id, uva.user_id, uva.assessment_id, uva.question_id,
             uva.audio_file_path,
             vq.question_text, vq.expected_answer, vq.keywords, vq.language_id,
             l.code AS language_code
      FROM user_video_analysis uva
      JOIN video_assessment_questions vq ON uva.question_id = vq.id
      JOIN languages l ON vq.language_id = l.id
      WHERE uva.isAwsReportGenerated = 2
        AND uva.isGeminiReportGenerated = 0
        AND uva.audio_file_path IS NOT NULL
        AND uva.audio_file_path != ''
      LIMIT ?
    `, [BATCH_SIZE]);

    if (!pending || pending.length === 0) {
      console.log('✅ No pending videos for Gemini report.');
      return { success: true, message: 'No pending', total: 0 };
    }

    console.log(`📹 Found ${pending.length} videos for Gemini processing.`);
    let successCount = 0, failCount = 0;

    for (const row of pending) {
      try {
        console.log(`\n🔹 Processing Gemini for video ID: ${row.id}`);
        console.log(`   User: ${row.user_id}, Assessment: ${row.assessment_id}, Question: ${row.question_id}`);

        // Lock record
        await connection.query(
          `UPDATE user_video_analysis SET isGeminiReportGenerated = 1 WHERE id = ?`,
          [row.id]
        );

        const audioFullPath = path.join(process.cwd(), row.audio_file_path);
        if (!fs.existsSync(audioFullPath)) {
          throw new Error(`Audio file not found: ${audioFullPath}`);
        }

        // Use expected_answer if available, otherwise fallback to question_text
        const referenceAnswer = row.expected_answer || row.question_text;
        const keywords = row.keywords || '';
        const language = row.language_code || 'en';

        // 1. Transcribe audio
        console.log('   🎤 Transcribing audio...');
        const transcript = await transcribeAudio(audioFullPath, language);
        console.log(`   📝 Transcript (${transcript.length} chars): ${transcript.substring(0, 100)}...`);

        // 2. Evaluate answer
        console.log('   🧠 Evaluating answer...');
        const evaluation = await evaluateAnswer(row.question_text, referenceAnswer, keywords, transcript);
        console.log('   ✅ Evaluation complete.');

        const score = evaluation.score || 0;
        const scorePercentage = evaluation.score_percentage || Math.round((score / 70) * 100);

        // 3. Save JSON report
        const baseFolder = path.dirname(audioFullPath);
        const reportFileName = `gemini_report_${Date.now()}.json`;
        const reportPath = path.join(baseFolder, reportFileName);
        fs.writeFileSync(reportPath, JSON.stringify({
          transcript,
          evaluation,
          score,
          scorePercentage,
          matchedKeywords: evaluation.matched_keywords || [],
          missingKeywords: evaluation.missing_keywords || [],
          generatedAt: new Date().toISOString(),
        }, null, 2));

        const relativeReportPath = path.join(
          path.dirname(row.audio_file_path),
          reportFileName
        ).replace(/\\/g, '/');

        // 4. Insert evaluation
        await insertOrUpdateEvaluation({
          user_video_analysis_id: row.id,
          user_id: row.user_id,
          question_id: row.question_id,
          transcript: transcript,
          evaluation: evaluation,
          score: score,
          score_percentage: scorePercentage,
          reportFilePath: relativeReportPath,
        });

        // 5. Update user_video_analysis
        await connection.query(
          `UPDATE user_video_analysis
           SET isGeminiReportGenerated = 2,
               GeminiReportFilePath = ?
           WHERE id = ?`,
          [relativeReportPath, row.id]
        );

        successCount++;
        console.log(`   ✅ Gemini report completed for video ${row.id}`);

      } catch (err) {
        console.error(`❌ Error processing Gemini for video ${row.id}:`, err.message);
        // Unlock on failure
        await connection.query(
          `UPDATE user_video_analysis SET isGeminiReportGenerated = 0 WHERE id = ?`,
          [row.id]
        );
        failCount++;
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log(`📊 Gemini Report Summary: ${successCount} succeeded, ${failCount} failed`);
    console.log('='.repeat(60));

    return { success: true, total: pending.length, successCount, failCount };
  } catch (err) {
    console.error('❌ Gemini Service Error:', err.message);
    return { success: false, error: err.message };
  } finally {
    connection.release();
  }
}

module.exports = { generateGeminiReport };
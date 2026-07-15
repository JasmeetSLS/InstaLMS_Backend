// app.js – Background cron service for Video Emotion + Gemini Report
require('dotenv').config();
const { scheduleVideoEmotionCron } = require('./cron/VideoEmotionCron');
const { scheduleGeminiReportCron } = require('./cron/GeminiReportCron');
const { processVideoEmotions } = require('./services/VideoEmotionService');
const { generateGeminiReport } = require('./services/GeminiReportService');

console.log('='.repeat(60));
console.log('🎬 VIDEO EMOTION + GEMINI CRON SERVICE');
console.log('='.repeat(60));
console.log(`🚀 Started at: ${new Date().toLocaleString()}`);
console.log('📋 Video Emotion Cron: runs every 2 minutes (pending videos)');
console.log('📋 Gemini Report Cron: runs every 2 minutes (pending audio files)');
console.log('💡 Keep this terminal open. Press Ctrl+C to stop.');
console.log('='.repeat(60));

// ============================================================
// SCHEDULE VIDEO EMOTION CRON
// ============================================================
scheduleVideoEmotionCron();

// ============================================================
// SCHEDULE GEMINI REPORT CRON
// ============================================================
scheduleGeminiReportCron();

// ============================================================
// RUN IMMEDIATELY ON STARTUP (catch any pending work)
// ============================================================
(async () => {
  console.log('\n🔄 Running initial Video Emotion processing...');
  try {
    const result = await processVideoEmotions();
    console.log(`✅ Emotion: ${result.successCount || 0} processed, ${result.failCount || 0} failed.`);
  } catch (err) {
    console.error('❌ Emotion initial run failed:', err.message);
  }

  console.log('\n🔄 Running initial Gemini Report processing...');
  try {
    const result = await generateGeminiReport();
    console.log(`✅ Gemini: ${result.successCount || 0} processed, ${result.failCount || 0} failed.`);
  } catch (err) {
    console.error('❌ Gemini initial run failed:', err.message);
  }

  console.log('\n✅ Both initial runs completed.');
})();

// ============================================================
// GRACEFUL SHUTDOWN
// ============================================================
process.on('SIGINT', () => {
  console.log('\n🛑 Cron service stopped.');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Cron service terminated.');
  process.exit(0);
});
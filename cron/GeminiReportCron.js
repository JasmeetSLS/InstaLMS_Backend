const cron = require('node-cron');
const { generateGeminiReport } = require('../services/GeminiReportService');

const scheduleGeminiReportCron = () => {
  console.log('🤖 Gemini Report Cron scheduled (every 2 minutes)');
  cron.schedule('*/2 * * * *', async () => {
    console.log(`⏰ Gemini Cron triggered at ${new Date().toLocaleString()}`);
    try {
      await generateGeminiReport();
    } catch (err) {
      console.error('❌ Gemini Cron error:', err.message);
    }
  });
};

module.exports = { scheduleGeminiReportCron };
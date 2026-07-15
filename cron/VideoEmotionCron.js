const cron = require('node-cron');
const { processVideoEmotions } = require('../services/VideoEmotionService');

const scheduleVideoEmotionCron = () => {
  console.log('⏰ Video Emotion Cron scheduled (every 2 minutes)');
  cron.schedule('*/2 * * * *', async () => {
    console.log(`⏰ Cron job triggered at ${new Date().toLocaleString()}`);
    try {
      await processVideoEmotions();
    } catch (err) {
      console.error('❌ Cron job error:', err.message);
    }
  });
};

module.exports = { scheduleVideoEmotionCron };
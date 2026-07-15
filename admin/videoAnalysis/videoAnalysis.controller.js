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
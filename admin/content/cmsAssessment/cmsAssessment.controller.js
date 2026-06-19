const { pool } = require('../../../config/db');

exports.getAssessmentsBySection = async (req, res) => {
    try {
        const { sectionId } = req.params;

        if (!sectionId || isNaN(sectionId)) {
            return res.status(400).json({ success: false, error: 'Invalid section ID' });
        }

        const connection = await pool.getConnection();

        try {
            const [assessments] = await connection.query(
                `SELECT id, title, description, assessment_type, passing_percentage, status, sort_order, created_at, updated_at
                 FROM cms_assessments
                 WHERE section_id = ? AND status = 'active'
                 ORDER BY sort_order ASC, id ASC`,
                [sectionId]
            );

            res.json({ success: true, data: assessments });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Get assessments by section error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};


// admin/content/cms/assessment.controller.js

exports.getAssessmentQuestions = async (req, res) => {
    try {
        const { assessmentId } = req.params;

        if (!assessmentId || isNaN(assessmentId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid assessment ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Fetch assessment details
            const [assessmentRows] = await connection.query(
                `SELECT id, title, assessment_type FROM cms_assessments WHERE id = ?`,
                [assessmentId]
            );

            if (assessmentRows.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Assessment not found'
                });
            }

            const assessment = assessmentRows[0];

            // Fetch questions
            const [questions] = await connection.query(
                `SELECT id, question_text, question_type, marks, sort_order 
                 FROM cms_assessment_questions 
                 WHERE assessment_id = ? 
                 ORDER BY sort_order ASC, id ASC`,
                [assessmentId]
            );

            // For each question, fetch specific data
            for (let q of questions) {
                if (['mcq', 'this_or_that'].includes(q.question_type)) {
                    const [options] = await connection.query(
                        `SELECT id, option_text, is_correct 
                         FROM cms_assessment_options 
                         WHERE question_id = ? 
                         ORDER BY sort_order ASC`,
                        [q.id]
                    );
                    q.options = options;
                } else if (q.question_type === 'true_false') {
                    // For true/false, we treat as MCQ with fixed options; we can fetch from options table if present.
                    // If no options, we'll create pseudo.
                    const [options] = await connection.query(
                        `SELECT id, option_text, is_correct 
                         FROM cms_assessment_options 
                         WHERE question_id = ? 
                         ORDER BY sort_order ASC`,
                        [q.id]
                    );
                    if (options && options.length > 0) {
                        q.options = options;
                    } else {
                        // Fallback
                        q.options = [
                            { option_text: 'True', is_correct: false },
                            { option_text: 'False', is_correct: false }
                        ];
                    }
                } else if (q.question_type === 'match_following') {
                    const [matches] = await connection.query(
                        `SELECT id, left_text, right_text, sort_order 
                         FROM cms_match_following 
                         WHERE question_id = ? 
                         ORDER BY sort_order ASC`,
                        [q.id]
                    );
                    q.matches = matches;
                } else if (q.question_type === 'order_following') {
                    const [orders] = await connection.query(
                        `SELECT id, item_text, correct_position 
                         FROM cms_order_following 
                         WHERE question_id = ? 
                         ORDER BY correct_position ASC`,
                        [q.id]
                    );
                    q.orders = orders;
                } else if (q.question_type === 'fill_blank') {
                    const [blanks] = await connection.query(
                        `SELECT id, answer 
                         FROM cms_fill_blanks 
                         WHERE question_id = ?`,
                        [q.id]
                    );
                    q.answer = blanks.length > 0 ? blanks[0].answer : '';
                }
            }

            res.json({
                success: true,
                data: {
                    assessment,
                    questions
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get assessment questions error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
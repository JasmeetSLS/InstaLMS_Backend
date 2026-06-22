const { pool } = require('../../../config/db');

// Get all questions for a section (list view)
exports.getQuestionsBySection = async (req, res) => {
    try {
        const { sectionId } = req.params;

        if (!sectionId || isNaN(sectionId)) {
            return res.status(400).json({ success: false, error: 'Invalid section ID' });
        }

        const connection = await pool.getConnection();

        try {
            // Verify section exists
            const [section] = await connection.query(
                'SELECT id FROM cms_sections WHERE id = ? AND status = "active"',
                [sectionId]
            );
            if (section.length === 0) {
                return res.status(404).json({ success: false, error: 'Section not found' });
            }

            // Fetch all questions for this section
            const [questions] = await connection.query(
                `SELECT id, question_text, question_type, marks, sort_order, created_at
                 FROM cms_questions
                 WHERE section_id = ?
                 ORDER BY sort_order ASC, id ASC`,
                [sectionId]
            );

            res.json({ success: true, data: questions });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Get questions by section error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

// Get full details of a single question by ID
exports.getQuestionById = async (req, res) => {
    try {
        const { questionId } = req.params;

        if (!questionId || isNaN(questionId)) {
            return res.status(400).json({ success: false, error: 'Invalid question ID' });
        }

        const connection = await pool.getConnection();

        try {
            // Fetch question details
            const [questionRows] = await connection.query(
                `SELECT id, section_id, question_text, question_type, marks, sort_order, created_at
                 FROM cms_questions
                 WHERE id = ?`,
                [questionId]
            );

            if (questionRows.length === 0) {
                return res.status(404).json({ success: false, error: 'Question not found' });
            }

            const question = questionRows[0];

            // Fetch related data based on question_type
            if (['mcq', 'true_false', 'this_or_that'].includes(question.question_type)) {
                const [options] = await connection.query(
                    `SELECT id, option_text, is_correct, sort_order
                     FROM cms_options
                     WHERE question_id = ?
                     ORDER BY sort_order ASC`,
                    [questionId]
                );
                question.options = options;
            } else if (question.question_type === 'fill_blank') {
                const [blanks] = await connection.query(
                    `SELECT id, answer
                     FROM cms_fill_blanks
                     WHERE question_id = ?`,
                    [questionId]
                );
                question.answer = blanks.length > 0 ? blanks[0].answer : '';
            } else if (question.question_type === 'match_following') {
                const [matches] = await connection.query(
                    `SELECT id, left_text, right_text, sort_order
                     FROM cms_match_following
                     WHERE question_id = ?
                     ORDER BY sort_order ASC`,
                    [questionId]
                );
                question.matches = matches;
            } else if (question.question_type === 'order_following') {
                const [orders] = await connection.query(
                    `SELECT id, item_text, correct_position
                     FROM cms_order_following
                     WHERE question_id = ?
                     ORDER BY correct_position ASC`,
                    [questionId]
                );
                question.orders = orders;
            }

            res.json({ success: true, data: question });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Get question by ID error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};
const { pool } = require('../../../config/db');

// ------------------------------
// GET QUESTIONS BY SECTION
// ------------------------------
exports.getQuestionsBySection = async (req, res) => {
    try {
        const { sectionId } = req.params;

        if (!sectionId || isNaN(sectionId)) {
            return res.status(400).json({ success: false, error: 'Invalid section ID' });
        }

        const connection = await pool.getConnection();
        try {
            const [section] = await connection.query(
                'SELECT id FROM cms_sections WHERE id = ? AND status = "active"',
                [sectionId]
            );
            if (section.length === 0) {
                return res.status(404).json({ success: false, error: 'Section not found' });
            }

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

// ------------------------------
// GET QUESTION BY ID
// ------------------------------
exports.getQuestionById = async (req, res) => {
    try {
        const { questionId } = req.params;

        if (!questionId || isNaN(questionId)) {
            return res.status(400).json({ success: false, error: 'Invalid question ID' });
        }

        const connection = await pool.getConnection();
        try {
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

// ------------------------------
// CREATE QUESTION
// ------------------------------
exports.addQuestion = async (req, res) => {
    try {
        const {
            sectionId,
            question_text,
            question_type,
            marks,
            sort_order,
            options,
            answer,
            matches,
            orders,
        } = req.body;

        if (!sectionId || isNaN(sectionId)) {
            return res.status(400).json({ success: false, error: 'Valid section ID required' });
        }
        if (!question_text || !question_text.trim()) {
            return res.status(400).json({ success: false, error: 'Question text is required' });
        }
        if (!question_type) {
            return res.status(400).json({ success: false, error: 'Question type is required' });
        }

        const validTypes = ['mcq', 'match_following', 'fill_blank', 'order_following', 'true_false', 'this_or_that'];
        if (!validTypes.includes(question_type)) {
            return res.status(400).json({ success: false, error: 'Invalid question type' });
        }

        const connection = await pool.getConnection();
        try {
            const [section] = await connection.query(
                'SELECT id FROM cms_sections WHERE id = ? AND status = "active"',
                [sectionId]
            );
            if (section.length === 0) {
                return res.status(404).json({ success: false, error: 'Section not found or inactive' });
            }

            await connection.beginTransaction();

            const [result] = await connection.query(
                `INSERT INTO cms_questions 
                 (section_id, question_text, question_type, marks, sort_order)
                 VALUES (?, ?, ?, ?, ?)`,
                [sectionId, question_text.trim(), question_type, marks || 1, sort_order || 0]
            );
            const questionId = result.insertId;

            // Insert type-specific data
            if (['mcq', 'true_false', 'this_or_that'].includes(question_type)) {
                if (options && Array.isArray(options) && options.length > 0) {
                    const optionValues = options.map((opt, idx) => [
                        questionId,
                        opt.option_text || '',
                        opt.is_correct ? 1 : 0,
                        opt.sort_order !== undefined ? opt.sort_order : idx,
                    ]);
                    await connection.query(
                        'INSERT INTO cms_options (question_id, option_text, is_correct, sort_order) VALUES ?',
                        [optionValues]
                    );
                }
            } else if (question_type === 'fill_blank') {
                if (answer !== undefined && answer !== null) {
                    await connection.query(
                        'INSERT INTO cms_fill_blanks (question_id, answer) VALUES (?, ?)',
                        [questionId, answer.trim()]
                    );
                }
            } else if (question_type === 'match_following') {
                if (matches && Array.isArray(matches) && matches.length > 0) {
                    const matchValues = matches.map((m, idx) => [
                        questionId,
                        m.left_text || '',
                        m.right_text || '',
                        m.sort_order !== undefined ? m.sort_order : idx,
                    ]);
                    await connection.query(
                        'INSERT INTO cms_match_following (question_id, left_text, right_text, sort_order) VALUES ?',
                        [matchValues]
                    );
                }
            } else if (question_type === 'order_following') {
                if (orders && Array.isArray(orders) && orders.length > 0) {
                    const orderValues = orders.map((o, idx) => [
                        questionId,
                        o.item_text || '',
                        o.correct_position !== undefined ? o.correct_position : idx + 1,
                    ]);
                    await connection.query(
                        'INSERT INTO cms_order_following (question_id, item_text, correct_position) VALUES ?',
                        [orderValues]
                    );
                }
            }

            await connection.commit();

            const [created] = await connection.query(
                'SELECT * FROM cms_questions WHERE id = ?',
                [questionId]
            );

            res.status(201).json({
                success: true,
                message: 'Question created successfully',
                data: created[0]
            });
        } catch (err) {
            await connection.rollback();
            console.error('Add question error:', err);
            throw err;
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Add question error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

// ------------------------------
// UPDATE QUESTION (IN-PLACE)
// ------------------------------
exports.updateQuestion = async (req, res) => {
    try {
        const { questionId } = req.params;
        const {
            question_text,
            question_type,
            marks,
            sort_order,
            options,
            answer,
            matches,
            orders,
        } = req.body;

        if (!questionId || isNaN(questionId)) {
            return res.status(400).json({ success: false, error: 'Valid question ID required' });
        }

        const connection = await pool.getConnection();
        try {
            const [existing] = await connection.query(
                'SELECT * FROM cms_questions WHERE id = ?',
                [questionId]
            );
            if (existing.length === 0) {
                return res.status(404).json({ success: false, error: 'Question not found' });
            }
            const question = existing[0];

            // Build common updates
            const updates = [];
            const values = [];

            if (question_text !== undefined) {
                updates.push('question_text = ?');
                values.push(question_text.trim() || null);
            }
            if (question_type !== undefined) {
                const validTypes = ['mcq', 'match_following', 'fill_blank', 'order_following', 'true_false', 'this_or_that'];
                if (!validTypes.includes(question_type)) {
                    return res.status(400).json({ success: false, error: 'Invalid question type' });
                }
                updates.push('question_type = ?');
                values.push(question_type);
            }
            if (marks !== undefined) {
                if (isNaN(marks)) {
                    return res.status(400).json({ success: false, error: 'Marks must be a number' });
                }
                updates.push('marks = ?');
                values.push(parseInt(marks));
            }
            if (sort_order !== undefined) {
                if (isNaN(sort_order)) {
                    return res.status(400).json({ success: false, error: 'sort_order must be a number' });
                }
                updates.push('sort_order = ?');
                values.push(parseInt(sort_order));
            }

            const effectiveType = question_type || question.question_type;

            // ----- MCQ / TrueFalse / ThisOrThat – in-place option updates -----
            if (['mcq', 'true_false', 'this_or_that'].includes(effectiveType)) {
                if (options !== undefined) {
                    // Fetch existing options
                    const [existingOpts] = await connection.query(
                        'SELECT id, sort_order FROM cms_options WHERE question_id = ? ORDER BY sort_order ASC',
                        [questionId]
                    );
                    const existingMap = {};
                    existingOpts.forEach(row => { existingMap[row.sort_order] = row; });

                    // Update or insert each option
                    for (let i = 0; i < options.length; i++) {
                        const opt = options[i];
                        const sortOrder = opt.sort_order !== undefined ? opt.sort_order : i;
                        if (existingMap[sortOrder]) {
                            await connection.query(
                                'UPDATE cms_options SET option_text = ?, is_correct = ? WHERE id = ?',
                                [opt.option_text || '', opt.is_correct ? 1 : 0, existingMap[sortOrder].id]
                            );
                        } else {
                            await connection.query(
                                'INSERT INTO cms_options (question_id, option_text, is_correct, sort_order) VALUES (?, ?, ?, ?)',
                                [questionId, opt.option_text || '', opt.is_correct ? 1 : 0, sortOrder]
                            );
                        }
                    }

                    // Delete options that are no longer present (i.e., sort_order beyond new count)
                    const sortOrdersToKeep = options.map((_, idx) => idx);
                    if (sortOrdersToKeep.length > 0) {
                        await connection.query(
                            'DELETE FROM cms_options WHERE question_id = ? AND sort_order NOT IN (?)',
                            [questionId, sortOrdersToKeep]
                        );
                    } else {
                        await connection.query('DELETE FROM cms_options WHERE question_id = ?', [questionId]);
                    }
                }
            }

            // ----- Fill Blank – in-place answer update -----
            if (effectiveType === 'fill_blank') {
                if (answer !== undefined) {
                    const [existingAnswer] = await connection.query(
                        'SELECT id FROM cms_fill_blanks WHERE question_id = ?',
                        [questionId]
                    );
                    if (existingAnswer.length > 0) {
                        await connection.query(
                            'UPDATE cms_fill_blanks SET answer = ? WHERE question_id = ?',
                            [answer.trim() || null, questionId]
                        );
                    } else {
                        await connection.query(
                            'INSERT INTO cms_fill_blanks (question_id, answer) VALUES (?, ?)',
                            [questionId, answer.trim() || null]
                        );
                    }
                }
            }

            // ----- Match Following – in-place updates -----
            if (effectiveType === 'match_following') {
                if (matches !== undefined) {
                    const [existingMatches] = await connection.query(
                        'SELECT id, sort_order FROM cms_match_following WHERE question_id = ? ORDER BY sort_order ASC',
                        [questionId]
                    );
                    const existingMap = {};
                    existingMatches.forEach(row => { existingMap[row.sort_order] = row; });

                    for (let i = 0; i < matches.length; i++) {
                        const m = matches[i];
                        const sortOrder = m.sort_order !== undefined ? m.sort_order : i;
                        if (existingMap[sortOrder]) {
                            await connection.query(
                                'UPDATE cms_match_following SET left_text = ?, right_text = ? WHERE id = ?',
                                [m.left_text || '', m.right_text || '', existingMap[sortOrder].id]
                            );
                        } else {
                            await connection.query(
                                'INSERT INTO cms_match_following (question_id, left_text, right_text, sort_order) VALUES (?, ?, ?, ?)',
                                [questionId, m.left_text || '', m.right_text || '', sortOrder]
                            );
                        }
                    }

                    const sortOrdersToKeep = matches.map((_, idx) => idx);
                    if (sortOrdersToKeep.length > 0) {
                        await connection.query(
                            'DELETE FROM cms_match_following WHERE question_id = ? AND sort_order NOT IN (?)',
                            [questionId, sortOrdersToKeep]
                        );
                    } else {
                        await connection.query('DELETE FROM cms_match_following WHERE question_id = ?', [questionId]);
                    }
                }
            }

            // ----- Order Following – in-place updates -----
            if (effectiveType === 'order_following') {
                if (orders !== undefined) {
                    const [existingOrders] = await connection.query(
                        'SELECT id, correct_position FROM cms_order_following WHERE question_id = ? ORDER BY correct_position ASC',
                        [questionId]
                    );
                    const existingMap = {};
                    existingOrders.forEach(row => { existingMap[row.correct_position] = row; });

                    for (let i = 0; i < orders.length; i++) {
                        const o = orders[i];
                        const pos = o.correct_position !== undefined ? o.correct_position : i + 1;
                        if (existingMap[pos]) {
                            await connection.query(
                                'UPDATE cms_order_following SET item_text = ? WHERE id = ?',
                                [o.item_text || '', existingMap[pos].id]
                            );
                        } else {
                            await connection.query(
                                'INSERT INTO cms_order_following (question_id, item_text, correct_position) VALUES (?, ?, ?)',
                                [questionId, o.item_text || '', pos]
                            );
                        }
                    }

                    const positionsToKeep = orders.map((_, idx) => idx + 1);
                    if (positionsToKeep.length > 0) {
                        await connection.query(
                            'DELETE FROM cms_order_following WHERE question_id = ? AND correct_position NOT IN (?)',
                            [questionId, positionsToKeep]
                        );
                    } else {
                        await connection.query('DELETE FROM cms_order_following WHERE question_id = ?', [questionId]);
                    }
                }
            }

            // Execute main update if any common field changed
            if (updates.length > 0) {
                const query = `UPDATE cms_questions SET ${updates.join(', ')} WHERE id = ?`;
                values.push(questionId);
                await connection.query(query, values);
            }

            // Fetch updated question
            const [updated] = await connection.query(
                'SELECT * FROM cms_questions WHERE id = ?',
                [questionId]
            );

            res.json({
                success: true,
                message: 'Question updated successfully',
                data: updated[0]
            });
        } catch (err) {
            console.error('Update question error:', err);
            throw err;
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Update question error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};

// ------------------------------
// DELETE QUESTION
// ------------------------------
exports.deleteQuestion = async (req, res) => {
    try {
        const { questionId } = req.params;

        if (!questionId || isNaN(questionId)) {
            return res.status(400).json({ success: false, error: 'Valid question ID required' });
        }

        const connection = await pool.getConnection();
        try {
            const [rows] = await connection.query(
                'SELECT id FROM cms_questions WHERE id = ?',
                [questionId]
            );
            if (rows.length === 0) {
                return res.status(404).json({ success: false, error: 'Question not found' });
            }

            await connection.query('DELETE FROM cms_questions WHERE id = ?', [questionId]);

            res.json({
                success: true,
                message: 'Question deleted successfully'
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('Delete question error:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
};
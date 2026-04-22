const { pool } = require('../../config/db');

// Get quiz questions for a post
exports.getQuizQuestions = async (req, res) => {
    try {
        const { post_id } = req.query;
        const userId = req.user.userId;

        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required in query params'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if post exists and is active
            const [posts] = await connection.query(
                'SELECT id, title, quiz_active FROM posts WHERE id = ? AND status = "active"',
                [post_id]
            );

            if (posts.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Post not found or inactive'
                });
            }

            // Check if quiz is active for this post
            if (posts[0].quiz_active !== 1) {
                return res.status(400).json({
                    success: false,
                    error: 'Quiz is not active for this post'
                });
            }

            // Check if user has already completed the quiz
            const [existingCompletion] = await connection.query(
                'SELECT id, score, completed_at FROM user_quiz_completion WHERE user_id = ? AND post_id = ?',
                [userId, post_id]
            );

            if (existingCompletion.length > 0) {
                return res.status(400).json({
                    success: false,
                    error: 'You have already completed this quiz',
                    data: {
                        score: existingCompletion[0].score,
                        completed_at: existingCompletion[0].completed_at
                    }
                });
            }

            // Get quiz questions
            const [questions] = await connection.query(
                `SELECT id, question_text, question_media_url, 
                        option_a, option_b, option_c, option_d, marks
                 FROM quiz_questions 
                 WHERE post_id = ? AND status = 'active'
                 ORDER BY id ASC`,
                [post_id]
            );

            if (questions.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'No quiz questions found for this post'
                });
            }

            // Calculate total marks
            let totalMarks = 0;
            questions.forEach(q => {
                totalMarks += q.marks;
            });

            res.status(200).json({
                success: true,
                data: {
                    post_id: parseInt(post_id),
                    post_title: posts[0].title,
                    total_questions: questions.length,
                    total_marks: totalMarks,
                    questions: questions.map(q => ({
                        id: q.id,
                        question_text: q.question_text,
                        question_media_url: q.question_media_url,
                        options: {
                            A: q.option_a,
                            B: q.option_b,
                            C: q.option_c,
                            D: q.option_d
                        },
                        marks: q.marks
                    }))
                }
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get quiz questions error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};

// Submit quiz answers - SIMPLIFIED RESPONSE
exports.submitQuizAnswers = async (req, res) => {
    try {
        const { post_id } = req.query;
        const { answers } = req.body;
        const userId = req.user.userId;

        // Validation
        if (!post_id) {
            return res.status(400).json({
                success: false,
                error: 'Post ID is required in query params'
            });
        }

        if (!answers || !Array.isArray(answers) || answers.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Answers array is required in body'
            });
        }

        const connection = await pool.getConnection();

        try {
            await connection.beginTransaction();

            // Check if post exists and quiz is active
            const [posts] = await connection.query(
                'SELECT id, title, quiz_active FROM posts WHERE id = ? AND status = "active"',
                [post_id]
            );

            if (posts.length === 0) {
                await connection.rollback();
                return res.status(404).json({
                    success: false,
                    error: 'Post not found or inactive'
                });
            }

            if (posts[0].quiz_active !== 1) {
                await connection.rollback();
                return res.status(400).json({
                    success: false,
                    error: 'Quiz is not active for this post'
                });
            }

            // Check if user has already completed the quiz
            const [existingCompletion] = await connection.query(
                'SELECT id FROM user_quiz_completion WHERE user_id = ? AND post_id = ?',
                [userId, post_id]
            );

            if (existingCompletion.length > 0) {
                await connection.rollback();
                return res.status(400).json({
                    success: false,
                    error: 'You have already completed this quiz'
                });
            }

            // Get all questions for this post
            const [questions] = await connection.query(
                'SELECT id, correct_option, marks FROM quiz_questions WHERE post_id = ? AND status = "active"',
                [post_id]
            );

            if (questions.length === 0) {
                await connection.rollback();
                return res.status(404).json({
                    success: false,
                    error: 'No quiz questions found'
                });
            }

            // Create a map of questions for easy lookup
            const questionMap = new Map();
            questions.forEach(q => {
                questionMap.set(q.id, q);
            });

            // Process answers and calculate score
            let totalScore = 0;
            const processedAnswers = [];

            for (const answer of answers) {
                const { question_id, selected_option } = answer;

                if (!question_id || !selected_option) {
                    await connection.rollback();
                    return res.status(400).json({
                        success: false,
                        error: 'Each answer must have question_id and selected_option'
                    });
                }

                const question = questionMap.get(question_id);
                
                if (!question) {
                    await connection.rollback();
                    return res.status(400).json({
                        success: false,
                        error: `Invalid question_id: ${question_id}`
                    });
                }

                // Check if answer already exists for this user and question
                const [existingAnswer] = await connection.query(
                    'SELECT id FROM user_quiz_answers WHERE user_id = ? AND post_id = ? AND question_id = ?',
                    [userId, post_id, question_id]
                );

                if (existingAnswer.length > 0) {
                    await connection.rollback();
                    return res.status(400).json({
                        success: false,
                        error: `Answer already submitted for question ${question_id}`
                    });
                }

                const isCorrect = (selected_option.toUpperCase() === question.correct_option);
                
                if (isCorrect) {
                    totalScore += question.marks;
                }

                processedAnswers.push({
                    user_id: userId,
                    post_id: post_id,
                    question_id: question_id,
                    selected_option: selected_option.toUpperCase(),
                    is_correct: isCorrect ? 1 : 0
                });
            }

            // Check if all questions were answered
            if (processedAnswers.length !== questions.length) {
                await connection.rollback();
                return res.status(400).json({
                    success: false,
                    error: `Please answer all questions. Answered: ${processedAnswers.length}, Total: ${questions.length}`
                });
            }

            // Insert answers
            for (const answer of processedAnswers) {
                await connection.query(
                    `INSERT INTO user_quiz_answers 
                     (user_id, post_id, question_id, selected_option, is_correct) 
                     VALUES (?, ?, ?, ?, ?)`,
                    [answer.user_id, answer.post_id, answer.question_id, 
                     answer.selected_option, answer.is_correct]
                );
            }

            // Insert quiz completion record
            await connection.query(
                `INSERT INTO user_quiz_completion (user_id, post_id, score) 
                 VALUES (?, ?, ?)`,
                [userId, post_id, totalScore]
            );

            await connection.commit();

            // SIMPLIFIED RESPONSE - Only success and message
            res.status(200).json({
                success: true,
                message: 'Quiz submitted successfully'
            });

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Submit quiz answers error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error: ' + error.message
        });
    }
};
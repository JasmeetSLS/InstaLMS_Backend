const { pool } = require('../../config/db');
const xlsx = require('xlsx');
const fs = require('fs');

exports.bulkUploadQuiz = async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: 'Excel file required' });

        // Read file from disk
        const workbook = xlsx.readFile(req.file.path);
        const rows = xlsx.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]]);
        
        if (!rows.length) {
            fs.unlinkSync(req.file.path);
            return res.status(400).json({ error: 'No data found' });
        }

        const connection = await pool.getConnection();
        let inserted = 0;
        let skipped = 0;
        const errors = [];

        await connection.beginTransaction();

        try {
            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                const rowNum = i + 2;
                
                // Get values with validation
                const postTitle = row.Post || row.post;
                const question = row.Question || row.question;
                const optionA = row['Option A'] || row.option_a;
                const optionB = row['Option B'] || row.option_b;
                const optionC = row['Option C'] || row.option_c;
                const optionD = row['Option D'] || row.option_d;
                const correctOption = row['Correct Option'] || row.correct_option;
                const marks = parseInt(row.Marks || row.marks || 1);

                // Validation
                if (!postTitle) {
                    errors.push(`Row ${rowNum}: Missing post title`);
                    skipped++;
                    continue;
                }
                if (!question) {
                    errors.push(`Row ${rowNum}: Missing question`);
                    skipped++;
                    continue;
                }
                if (!optionA || !optionB) {
                    errors.push(`Row ${rowNum}: Missing options A or B`);
                    skipped++;
                    continue;
                }
                if (!correctOption || !['A','B','C','D'].includes(correctOption.toUpperCase())) {
                    errors.push(`Row ${rowNum}: Invalid correct option`);
                    skipped++;
                    continue;
                }

                // Find post
                const [posts] = await connection.query(
                    'SELECT id FROM posts WHERE title = ?', 
                    [postTitle]
                );
                
                if (!posts.length) {
                    errors.push(`Row ${rowNum}: Post "${postTitle}" not found`);
                    skipped++;
                    continue;
                }

                // Check for duplicate question
                const [existing] = await connection.query(
                    'SELECT id FROM quiz_questions WHERE post_id = ? AND question_text = ?',
                    [posts[0].id, question]
                );
                
                if (existing.length) {
                    skipped++;
                    continue;
                }

                // Insert
                await connection.query(
                    `INSERT INTO quiz_questions 
                     (post_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, status) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active')`,
                    [posts[0].id, question, optionA, optionB, optionC || null, optionD || null, correctOption.toUpperCase(), marks]
                );
                inserted++;
            }

            await connection.commit();
            
        } catch (err) {
            await connection.rollback();
            throw err;
        } finally {
            connection.release();
        }
        
        // Delete file after processing
        fs.unlinkSync(req.file.path);
        
        res.json({ 
            success: true, 
            inserted, 
            skipped,
            total: rows.length,
            errors: errors.length > 0 ? errors : null
        });

    } catch (error) {
        // Clean up file on error
        if (req.file && fs.existsSync(req.file.path)) {
            try {
                fs.unlinkSync(req.file.path);
            } catch (unlinkError) {
                console.error('Error deleting file:', unlinkError);
            }
        }
        
        console.error('Bulk upload error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Get quiz questions by post ID
exports.getQuizQuestionsByPost = async (req, res) => {
    try {
        const { post_id } = req.params;
        
        if (!post_id) {
            return res.status(400).json({ error: 'Post ID is required' });
        }

        const connection = await pool.getConnection();
        
        // Get quiz questions
        const [questions] = await connection.query(
            `SELECT id, post_id, question_text, question_media_url, 
                    option_a, option_b, option_c, option_d, correct_option, marks, 
                    status, created_at
             FROM quiz_questions 
             WHERE post_id = ? AND status = 'active'
             ORDER BY id ASC`,
            [post_id]
        );
        
        // Get post details
        const [posts] = await connection.query(
            'SELECT id, title, quiz_active FROM posts WHERE id = ?',
            [post_id]
        );
        
        connection.release();
        
        res.json({
            success: true,
            data: {
                post: posts[0] || null,
                total_questions: questions.length,
                questions: questions
            }
        });
        
    } catch (error) {
        console.error('Error fetching quiz questions:', error);
        res.status(500).json({ error: error.message });
    }
};

// Get all post titles (for dropdown/selection)
exports.getAllPostTitles = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        
        const [posts] = await connection.query(
            `SELECT id, title
             FROM posts 
             WHERE quiz_active = '1'
             ORDER BY id ASC`
        );
        
        connection.release();
        
        res.json({
            success: true,
            total: posts.length,
            data: posts
        });
        
    } catch (error) {
        console.error('Error fetching post titles:', error);
        res.status(500).json({ error: error.message });
    }
};
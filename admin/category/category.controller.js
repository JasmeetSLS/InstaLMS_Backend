const { pool } = require('../../config/db');
const fs = require('fs');

// Get all categories
exports.getAllCategories = async (req, res) => {
    try {
        const [categories] = await pool.query('SELECT * FROM categories ORDER BY created_at DESC');
        res.json({ success: true, data: categories });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get category by ID
exports.getCategoryById = async (req, res) => {
    try {
        const { id } = req.params;
        const [category] = await pool.query('SELECT * FROM categories WHERE id = ?', [id]);
        
        if (category.length === 0) {
            return res.status(404).json({ error: 'Category not found' });
        }
        
        res.json({ success: true, data: category[0] });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Create category
exports.createCategory = async (req, res) => {
    try {
        const { name } = req.body;
        
        if (!name) return res.status(400).json({ error: 'Category name required' });
        
        // Check if category exists
        const [existing] = await pool.query('SELECT id FROM categories WHERE name = ?', [name]);
        if (existing.length > 0) {
            if (req.file && fs.existsSync(req.file.path)) {
                fs.unlinkSync(req.file.path);
            }
            return res.status(409).json({ error: 'Category exists' });
        }
        
        // Get icon filename if uploaded
        let iconUrl = null;
        if (req.file) {
            iconUrl = req.file.filename;
        }
        
        // Insert category
        const [result] = await pool.query(
            'INSERT INTO categories (name, icon_url, status) VALUES (?, ?, "active")',
            [name, iconUrl]
        );
        
        const [category] = await pool.query('SELECT * FROM categories WHERE id = ?', [result.insertId]);
        
        res.json({ success: true, data: category[0] });
    } catch (error) {
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json({ error: error.message });
    }
};

// Update category
exports.updateCategory = async (req, res) => {
    try {
        const { id } = req.params;
        const { name } = req.body;
        
        // Check if category exists
        const [existing] = await pool.query('SELECT icon_url FROM categories WHERE id = ?', [id]);
        if (existing.length === 0) {
            if (req.file && fs.existsSync(req.file.path)) {
                fs.unlinkSync(req.file.path);
            }
            return res.status(404).json({ error: 'Category not found' });
        }
        
        // Check name duplicate
        if (name) {
            const [duplicate] = await pool.query(
                'SELECT id FROM categories WHERE name = ? AND id != ?',
                [name, id]
            );
            if (duplicate.length > 0) {
                if (req.file && fs.existsSync(req.file.path)) {
                    fs.unlinkSync(req.file.path);
                }
                return res.status(409).json({ error: 'Category name already exists' });
            }
        }
        
        // Update icon
        let iconUrl = existing[0].icon_url;
        if (req.file) {
            // Delete old icon
            if (existing[0].icon_url && fs.existsSync(`uploads/${existing[0].icon_url}`)) {
                fs.unlinkSync(`uploads/${existing[0].icon_url}`);
            }
            iconUrl = req.file.filename;
        }
        
        // Build update query
        let updateQuery = 'UPDATE categories SET ';
        const values = [];
        
        if (name) {
            updateQuery += 'name = ?, ';
            values.push(name);
        }
        if (req.file) {
            updateQuery += 'icon_url = ?, ';
            values.push(iconUrl);
        }
        
        updateQuery = updateQuery.slice(0, -2) + ' WHERE id = ?';
        values.push(id);
        
        await pool.query(updateQuery, values);
        
        const [category] = await pool.query('SELECT * FROM categories WHERE id = ?', [id]);
        
        res.json({ success: true, data: category[0] });
    } catch (error) {
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json({ error: error.message });
    }
};

// Delete category
exports.deleteCategory = async (req, res) => {
    try {
        const { id } = req.params;
        
        const [existing] = await pool.query('SELECT name, icon_url FROM categories WHERE id = ?', [id]);
        if (existing.length === 0) return res.status(404).json({ error: 'Category not found' });
        
        // Delete icon file
        if (existing[0].icon_url && fs.existsSync(`uploads/${existing[0].icon_url}`)) {
            fs.unlinkSync(`uploads/${existing[0].icon_url}`);
        }
        
        await pool.query('DELETE FROM categories WHERE id = ?', [id]);
        
        res.json({ success: true, message: 'Category deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update category status
exports.updateCategoryStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        
        if (!status) return res.status(400).json({ error: 'Status required' });
        
        const [result] = await pool.query(
            'UPDATE categories SET status = ? WHERE id = ?',
            [status, id]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Category not found' });
        }
        
        const [category] = await pool.query('SELECT * FROM categories WHERE id = ?', [id]);
        
        res.json({ success: true, data: category[0] });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
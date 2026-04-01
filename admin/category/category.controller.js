const { pool } = require('../../config/db');

// Get all categories
exports.getAllCategories = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        
        try {
            const [categories] = await connection.query(
                `SELECT 
                    id, 
                    name, 
                    icon_url, 
                    status, 
                    created_at,
                    updated_at 
                 FROM categories 
                 ORDER BY created_at DESC`
            );

            res.json({
                success: true,
                data: categories
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get all categories error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Get category by ID
exports.getCategoryById = async (req, res) => {
    try {
        const { id } = req.params;

        const connection = await pool.getConnection();

        try {
            const [categories] = await connection.query(
                `SELECT 
                    id, 
                    name, 
                    icon_url, 
                    status, 
                    created_at,
                    updated_at 
                 FROM categories 
                 WHERE id = ?`,
                [id]
            );

            if (categories.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found'
                });
            }

            res.json({
                success: true,
                data: categories[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get category by ID error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Create new category
exports.createCategory = async (req, res) => {
    try {
        const { name, icon_url, status } = req.body;

        // Validate required fields
        if (!name) {
            return res.status(400).json({
                success: false,
                error: 'Category name is required'
            });
        }

        // Validate status if provided
        if (status && !['active', 'inactive'].includes(status)) {
            return res.status(400).json({
                success: false,
                error: 'Status must be either "active" or "inactive"'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if category already exists
            const [existing] = await connection.query(
                'SELECT id FROM categories WHERE name = ?',
                [name]
            );

            if (existing.length > 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Category with this name already exists'
                });
            }

            // Insert new category
            const [result] = await connection.query(
                'INSERT INTO categories (name, icon_url, status) VALUES (?, ?, ?)',
                [name, icon_url || null, status || 'active']
            );

            // Fetch the created category
            const [newCategory] = await connection.query(
                'SELECT id, name, icon_url, status, created_at, updated_at FROM categories WHERE id = ?',
                [result.insertId]
            );

            res.status(201).json({
                success: true,
                message: 'Category created successfully',
                data: newCategory[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create category error:', error);
        
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({
                success: false,
                error: 'Category with this name already exists'
            });
        }
        
        res.status(500).json({
            success: false,
            error: error.message || 'Internal server error'
        });
    }
};

// Update category
exports.updateCategory = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, icon_url, status } = req.body;

        if (!name && !icon_url && !status) {
            return res.status(400).json({
                success: false,
                error: 'At least one field (name, icon_url, status) is required to update'
            });
        }

        // Validate status if provided
        if (status && !['active', 'inactive'].includes(status)) {
            return res.status(400).json({
                success: false,
                error: 'Status must be either "active" or "inactive"'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Check if category exists
            const [existing] = await connection.query(
                'SELECT id FROM categories WHERE id = ?',
                [id]
            );

            if (existing.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found'
                });
            }

            // Check if new name conflicts with existing category
            if (name) {
                const [nameConflict] = await connection.query(
                    'SELECT id FROM categories WHERE name = ? AND id != ?',
                    [name, id]
                );
                
                if (nameConflict.length > 0) {
                    return res.status(400).json({
                        success: false,
                        error: 'Another category with this name already exists'
                    });
                }
            }

            // Build update query dynamically
            const updates = [];
            const values = [];
            
            if (name) {
                updates.push('name = ?');
                values.push(name);
            }
            if (icon_url !== undefined) {
                updates.push('icon_url = ?');
                values.push(icon_url);
            }
            if (status) {
                updates.push('status = ?');
                values.push(status);
            }
            
            values.push(id);
            
            await connection.query(
                `UPDATE categories SET ${updates.join(', ')} WHERE id = ?`,
                values
            );

            // Fetch updated category
            const [updatedCategory] = await connection.query(
                'SELECT id, name, icon_url, status, created_at, updated_at FROM categories WHERE id = ?',
                [id]
            );

            res.json({
                success: true,
                message: 'Category updated successfully',
                data: updatedCategory[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Update category error:', error);
        
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({
                success: false,
                error: 'Category with this name already exists'
            });
        }
        
        res.status(500).json({
            success: false,
            error: error.message || 'Internal server error'
        });
    }
};

// Delete category
exports.deleteCategory = async (req, res) => {
    try {
        const { id } = req.params;

        const connection = await pool.getConnection();

        try {
            // Check if category exists
            const [categories] = await connection.query(
                'SELECT id, name FROM categories WHERE id = ?',
                [id]
            );

            if (categories.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found'
                });
            }

            // Delete category
            await connection.query('DELETE FROM categories WHERE id = ?', [id]);

            res.json({
                success: true,
                message: `Category "${categories[0].name}" deleted successfully`
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Delete category error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Internal server error'
        });
    }
};

// Update category status (activate/deactivate)
exports.updateCategoryStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        if (!status || !['active', 'inactive'].includes(status)) {
            return res.status(400).json({
                success: false,
                error: 'Valid status (active/inactive) is required'
            });
        }

        const connection = await pool.getConnection();

        try {
            const [result] = await connection.query(
                'UPDATE categories SET status = ? WHERE id = ?',
                [status, id]
            );

            if (result.affectedRows === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Category not found'
                });
            }

            res.json({
                success: true,
                message: `Category status updated to ${status}`
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Update category status error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
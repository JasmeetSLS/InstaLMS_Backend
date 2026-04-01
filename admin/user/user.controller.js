const { pool } = require('../../config/db');
const xlsx = require('xlsx');
const fs = require('fs');
exports.getAllUsers = async (req, res) => {
    try {
        const connection = await pool.getConnection();

        try {
            const [users] = await connection.query(
                `SELECT 
                    id, 
                    email, 
                    employee_id, 
                    name, 
                    role, 
                    status, 
                    created_at,
                    updated_at 
                 FROM users 
                 ORDER BY created_at ASC`
            );

            res.json({
                success: true,
                data: users
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get all users error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Get user by ID
exports.getUserById = async (req, res) => {
    try {
        const { id } = req.params;

        const connection = await pool.getConnection();

        try {
            const [users] = await connection.query(
                `SELECT 
                    id, 
                    email, 
                    employee_id, 
                    name, 
                    role, 
                    status, 
                    created_at,
                    updated_at 
                 FROM users 
                 WHERE id = ?`,
                [id]
            );

            if (users.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'User not found'
                });
            }

            res.json({
                success: true,
                data: users[0]
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Get user by ID error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Update user status
exports.updateUserStatus = async (req, res) => {
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
                'UPDATE users SET status = ? WHERE id = ?',
                [status, id]
            );

            if (result.affectedRows === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'User not found'
                });
            }

            res.json({
                success: true,
                message: `User status updated to ${status}`
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Update user status error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Delete user
exports.deleteUser = async (req, res) => {
    try {
        const { id } = req.params;

        const connection = await pool.getConnection();

        try {
            // Check if user exists
            const [users] = await connection.query(
                'SELECT id FROM users WHERE id = ?',
                [id]
            );

            if (users.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'User not found'
                });
            }

            // Delete user (OTPs will be deleted automatically due to foreign key)
            await connection.query('DELETE FROM users WHERE id = ?', [id]);

            res.json({
                success: true,
                message: 'User deleted successfully'
            });

        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

// Export users to Excel
exports.exportUsers = async (req, res) => {
    try {
        const connection = await pool.getConnection();
        
        try {
            // Fetch all users from the database
            const [users] = await connection.query(
                'SELECT id, email, employee_id, name, role, status, created_at FROM users ORDER BY created_at ASC'
            );
            
            if (!users || users.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'No users found to export'
                });
            }
            
            // Prepare data for Excel export
            const exportData = users.map(user => ({
                'ID': user.id,
                'Email': user.email,
                'Employee ID': user.employee_id,
                'Name': user.name,
                'Role': user.role,
                'Status': user.status,
                'Created At': user.created_at
            }));
            
            // Create workbook and worksheet
            const worksheet = xlsx.utils.json_to_sheet(exportData);
            const workbook = xlsx.utils.book_new();
            xlsx.utils.book_append_sheet(workbook, worksheet, 'Users');
            
            // Generate buffer
            const buffer = xlsx.write(workbook, { type: 'buffer', bookType: 'xlsx' });
            
            // Set response headers
            res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            res.setHeader('Content-Disposition', `attachment; filename=users_export_${Date.now()}.xlsx`);
            
            // Send the file
            res.send(buffer);
            
        } finally {
            connection.release();
        }
        
    } catch (error) {
        console.error('Export users error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Failed to export users'
        });
    }
};

// Import users from Excel (Bulk Upload)
exports.bulkUploadUsers = async (req, res) => {
    let filePath = null;
    
    try {
        // Check if file was uploaded
        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: 'Please upload an Excel file (.xlsx, .xls, or .csv)'
            });
        }

        filePath = req.file.path;
        
        // Read the Excel file
        const workbook = xlsx.readFile(filePath);
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        
        // Convert to JSON
        const data = xlsx.utils.sheet_to_json(worksheet);
        
        if (data.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Excel file is empty'
            });
        }

        // Validate required columns
        const requiredColumns = ['email', 'employee_id', 'name'];
        const firstRow = data[0];
        const missingColumns = requiredColumns.filter(col => !firstRow.hasOwnProperty(col));
        
        if (missingColumns.length > 0) {
            return res.status(400).json({
                success: false,
                error: `Missing required columns: ${missingColumns.join(', ')}`
            });
        }

        const connection = await pool.getConnection();
        let successCount = 0;
        let failedCount = 0;
        let updatedCount = 0;
        const errors = [];

        try {
            await connection.beginTransaction();

            for (let i = 0; i < data.length; i++) {
                const row = data[i];
                const email = row.email?.trim();
                const employeeId = row.employee_id?.toString().trim();
                const name = row.name?.trim();
                const role = row.role?.trim() || 'user';

                // Validate each row
                if (!email || !employeeId || !name) {
                    failedCount++;
                    errors.push({
                        row: i + 2,
                        error: 'Missing required fields (email, employee_id, or name)',
                        data: row
                    });
                    continue;
                }

                // Validate email format
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email)) {
                    failedCount++;
                    errors.push({
                        row: i + 2,
                        error: 'Invalid email format',
                        data: row
                    });
                    continue;
                }

                // Validate role if provided
                const allowedRoles = ['user', 'admin', 'manager', 'employee', 'Sales', 'DFM', 'DSE'];
                if (role && !allowedRoles.includes(role)) {
                    failedCount++;
                    errors.push({
                        row: i + 2,
                        error: `Invalid role. Allowed roles: ${allowedRoles.join(', ')}`,
                        data: row
                    });
                    continue;
                }

                try {
                    // Check if user already exists by email or employee_id
                    const [existing] = await connection.query(
                        'SELECT id, email, employee_id FROM users WHERE email = ? OR employee_id = ?',
                        [email, employeeId]
                    );

                    if (existing.length > 0) {
                        // Update existing user
                        const existingUser = existing[0];
                        await connection.query(
                            'UPDATE users SET name = ?, role = ? WHERE id = ?',
                            [name, role, existingUser.id]
                        );
                        updatedCount++;
                    } else {
                        // Insert new user
                        await connection.query(
                            'INSERT INTO users (email, employee_id, name, role, status) VALUES (?, ?, ?, ?, "active")',
                            [email, employeeId, name, role]
                        );
                        successCount++;
                    }
                    
                } catch (dbError) {
                    failedCount++;
                    errors.push({
                        row: i + 2,
                        error: dbError.message,
                        data: row
                    });
                }
            }

            await connection.commit();
            
            res.json({
                success: true,
                message: 'Import completed',
                data: {
                    total: data.length,
                    new: successCount,
                    updated: updatedCount,
                    failed: failedCount,
                    errors: errors
                }
            });

        } catch (dbError) {
            await connection.rollback();
            throw dbError;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Import users error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Internal server error'
        });
    } finally {
        // Delete the uploaded file
        if (filePath && fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    }
};
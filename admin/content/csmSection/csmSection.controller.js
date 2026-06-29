const { pool } = require('../../../config/db');
const path = require('path');
const fs = require('fs');

// Helper to delete a file
const deleteFile = (filePath) => {
  if (!filePath) return;
  const fullPath = path.join(__dirname, '../../../', filePath);
  if (fs.existsSync(fullPath)) {
    fs.unlinkSync(fullPath);
    console.log(`Deleted file: ${fullPath}`);
  }
};

// Helper to recursively delete a directory
const deleteDirectory = (dirPath) => {
  const fullPath = path.join(__dirname, '../../../', dirPath);
  if (fs.existsSync(fullPath)) {
    fs.rmSync(fullPath, { recursive: true, force: true });
    console.log(`Deleted directory: ${fullPath}`);
  }
};

// ------------------------------
// CREATE SECTION
// ------------------------------
exports.createSection = async (req, res) => {
  try {
    const { stream_id, title, description } = req.body;

    if (!stream_id || isNaN(stream_id)) {
      return res.status(400).json({ success: false, error: 'Valid stream ID is required' });
    }
    if (!title || !title.trim()) {
      return res.status(400).json({ success: false, error: 'Title is required' });
    }

    const connection = await pool.getConnection();

    try {
      const [streamCheck] = await connection.query(
        'SELECT id FROM cms_streams WHERE id = ? AND status = "active"',
        [stream_id]
      );

      if (streamCheck.length === 0) {
        return res.status(404).json({ success: false, error: 'Stream not found or inactive' });
      }

      const [existing] = await connection.query(
        'SELECT id FROM cms_sections WHERE stream_id = ? AND title = ?',
        [stream_id, title.trim()]
      );

      if (existing.length > 0) {
        return res.status(409).json({ success: false, error: 'A section with this title already exists in this stream' });
      }

      const [result] = await connection.query(
        `INSERT INTO cms_sections 
         (stream_id, title, description, status, sort_order) 
         VALUES (?, ?, ?, ?, ?)`,
        [stream_id, title.trim(), description || null, 'active', 0]
      );

      const sectionId = result.insertId;

      const [newSection] = await connection.query(
        `SELECT id, stream_id, title, description, status, sort_order, created_at, updated_at
         FROM cms_sections WHERE id = ?`,
        [sectionId]
      );

      res.status(201).json({
        success: true,
        message: 'Section created successfully',
        data: newSection[0]
      });

    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Create section error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// ------------------------------
// GET SECTIONS BY STREAM
// ------------------------------
exports.getSectionsByStream = async (req, res) => {
  try {
    const { streamId } = req.params;

    if (!streamId || isNaN(streamId)) {
      return res.status(400).json({ success: false, error: 'Invalid stream ID' });
    }

    const connection = await pool.getConnection();

    try {
      const [streamCheck] = await connection.query(
        'SELECT id FROM cms_streams WHERE id = ? AND status = "active"',
        [streamId]
      );

      if (streamCheck.length === 0) {
        return res.status(404).json({ success: false, error: 'Stream not found or inactive' });
      }

      const [sections] = await connection.query(
        `SELECT 
          s.id, s.title, s.description, s.status, s.sort_order,
          s.created_at, s.updated_at,
          (SELECT COUNT(*) FROM cms_contents WHERE section_id = s.id AND status = 'active') AS contents_count,
          (SELECT COUNT(*) FROM cms_questions WHERE section_id = s.id) AS assessments_count
         FROM cms_sections s
         WHERE s.stream_id = ? AND s.status = 'active'
         ORDER BY s.sort_order ASC, s.id ASC`,
        [streamId]
      );

      res.json({ success: true, data: sections });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Get sections by stream error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// ------------------------------
// GET SECTION BY ID
// ------------------------------
exports.getSectionById = async (req, res) => {
  try {
    const { sectionId } = req.params;

    if (!sectionId || isNaN(sectionId)) {
      return res.status(400).json({ success: false, error: 'Invalid section ID' });
    }

    const connection = await pool.getConnection();

    try {
      const [rows] = await connection.query(
        `SELECT 
          s.id, s.stream_id, s.title, s.description, s.status, s.sort_order,
          s.created_at, s.updated_at,
          (SELECT COUNT(*) FROM cms_contents WHERE section_id = s.id AND status = 'active') AS contents_count,
          (SELECT COUNT(*) FROM cms_questions WHERE section_id = s.id) AS assessments_count,
          st.title AS stream_title
         FROM cms_sections s
         LEFT JOIN cms_streams st ON s.stream_id = st.id
         WHERE s.id = ?`,
        [sectionId]
      );

      if (rows.length === 0) {
        return res.status(404).json({ success: false, error: 'Section not found' });
      }

      res.json({ success: true, data: rows[0] });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Get section by ID error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// ------------------------------
// UPDATE SECTION (partial)
// ------------------------------
exports.updateSection = async (req, res) => {
  try {
    const { sectionId } = req.params;
    const { title, description, status, sort_order } = req.body;

    if (!sectionId || isNaN(sectionId)) {
      return res.status(400).json({ success: false, error: 'Valid section ID required' });
    }

    const connection = await pool.getConnection();

    try {
      // Check existence
      const [existing] = await connection.query(
        'SELECT * FROM cms_sections WHERE id = ?',
        [sectionId]
      );
      if (existing.length === 0) {
        return res.status(404).json({ success: false, error: 'Section not found' });
      }

      const updates = [];
      const values = [];

      if (title !== undefined) {
        if (!title.trim()) {
          return res.status(400).json({ success: false, error: 'Title cannot be empty' });
        }
        // Check duplicate within the same stream
        const [dup] = await connection.query(
          'SELECT id FROM cms_sections WHERE stream_id = ? AND title = ? AND id != ?',
          [existing[0].stream_id, title.trim(), sectionId]
        );
        if (dup.length > 0) {
          return res.status(409).json({ success: false, error: 'A section with this title already exists in this stream' });
        }
        updates.push('title = ?');
        values.push(title.trim());
      }

      if (description !== undefined) {
        updates.push('description = ?');
        values.push(description || null);
      }

      if (status !== undefined) {
        if (!['active', 'inactive'].includes(status)) {
          return res.status(400).json({ success: false, error: 'Status must be "active" or "inactive"' });
        }
        updates.push('status = ?');
        values.push(status);
      }

      if (sort_order !== undefined) {
        if (isNaN(sort_order)) {
          return res.status(400).json({ success: false, error: 'sort_order must be a number' });
        }
        updates.push('sort_order = ?');
        values.push(parseInt(sort_order));
      }

      if (updates.length === 0) {
        return res.json({ success: true, message: 'No changes provided', data: existing[0] });
      }

      const query = `UPDATE cms_sections SET ${updates.join(', ')} WHERE id = ?`;
      values.push(sectionId);
      await connection.query(query, values);

      const [updated] = await connection.query(
        'SELECT * FROM cms_sections WHERE id = ?',
        [sectionId]
      );

      res.json({ success: true, message: 'Section updated successfully', data: updated[0] });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Update section error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// ------------------------------
// DELETE SECTION (cascade + file cleanup)
// ------------------------------
exports.deleteSection = async (req, res) => {
  try {
    const { sectionId } = req.params;

    if (!sectionId || isNaN(sectionId)) {
      return res.status(400).json({ success: false, error: 'Valid section ID required' });
    }

    const connection = await pool.getConnection();

    try {
      // Verify section exists
      const [rows] = await connection.query(
        'SELECT id FROM cms_sections WHERE id = ?',
        [sectionId]
      );
      if (rows.length === 0) {
        return res.status(404).json({ success: false, error: 'Section not found' });
      }

      // ---- Clean up files BEFORE cascade deletion ----
      // 1. Get all content IDs in this section
      const [contents] = await connection.query(
        'SELECT id FROM cms_contents WHERE section_id = ?',
        [sectionId]
      );

      for (const content of contents) {
        const contentId = content.id;
        // Fetch file paths for this content
        const [contentData] = await connection.query(
          'SELECT media_url, pdf_url, thumbnail_url FROM cms_contents WHERE id = ?',
          [contentId]
        );
        if (contentData.length > 0) {
          const data = contentData[0];
          if (data.media_url && !data.media_url.startsWith('http')) deleteFile(data.media_url);
          if (data.pdf_url) deleteFile(data.pdf_url);
          if (data.thumbnail_url && !data.thumbnail_url.startsWith('http')) deleteFile(data.thumbnail_url);
        }

        // Delete slide images (from cms_content_images)
        const [images] = await connection.query(
          'SELECT image_url FROM cms_content_images WHERE content_id = ?',
          [contentId]
        );
        for (const img of images) {
          if (img.image_url) deleteFile(img.image_url);
        }

        // Delete the content directory
        deleteDirectory(`uploads/cmscontent/${contentId}`);
      }

      // ---- Delete the section (cascade deletes contents and questions) ----
      await connection.query('DELETE FROM cms_sections WHERE id = ?', [sectionId]);

      res.json({ success: true, message: 'Section deleted successfully' });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Delete section error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};
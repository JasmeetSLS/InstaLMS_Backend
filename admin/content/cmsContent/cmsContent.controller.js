const path = require('path');
const fs = require('fs');
const { pool } = require('../../../config/db');

// Helper to ensure directory exists
const ensureDir = (dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

// Helper to move uploaded file
const saveFile = (file, targetDir, prefix = '') => {
  const ext = path.extname(file.originalname);
  const baseName = path.basename(file.originalname, ext);
  const filename = `${prefix}${Date.now()}_${baseName.replace(/\s+/g, '_')}${ext}`;
  const filePath = path.join(targetDir, filename);
  fs.renameSync(file.path, filePath);
  return `/uploads/cmscontent/${path.basename(targetDir)}/${filename}`;
};

// Helper to get a file by fieldname from req.files array
const getFile = (req, fieldname) => {
  if (!req.files) return null;
  const file = req.files.find(f => f.fieldname === fieldname);
  return file || null;
};

// Helper to delete a file from disk
const deleteFile = (filePath) => {
  if (!filePath) return;
  const fullPath = path.join(__dirname, '../../../', filePath);
  if (fs.existsSync(fullPath)) {
    fs.unlinkSync(fullPath);
    console.log(`Deleted file: ${fullPath}`);
  }
};

// ------------------------------
// CREATE CONTENT
// ------------------------------
exports.addContent = async (req, res) => {
  try {
    const {
      sectionId,
      title,
      description,
      template,
      isNumberedList,
      openInBrowser,
      videoUrl,
      sourceUrl,
      pdfText,
      slideCount,
    } = req.body;

    if (!sectionId || isNaN(sectionId)) {
      return res.status(400).json({ success: false, error: 'Valid section ID required' });
    }
    if (!title || !title.trim()) {
      return res.status(400).json({ success: false, error: 'Title is required' });
    }
    if (!template) {
      return res.status(400).json({ success: false, error: 'Template/content type is required' });
    }

    const contentTypeMap = {
      'Video': 'video',
      'Extract from PDF': 'pdf_extract',
      'Extract from URL': 'url_extract',
      'Multiple Image Text': 'multiple_image_text',
    };
    const contentType = contentTypeMap[template];
    if (!contentType) {
      return res.status(400).json({ success: false, error: 'Invalid template type' });
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
        `INSERT INTO cms_contents 
         (section_id, content_type, title, description, status, sort_order) 
         VALUES (?, ?, ?, ?, 'active', 0)`,
        [sectionId, contentType, title.trim(), description || null]
      );
      const contentId = result.insertId;

      const contentDir = path.join('uploads', 'cmscontent', contentId.toString());
      ensureDir(contentDir);

      let mediaUrl = null;
      let thumbnailUrl = null;
      let pdfUrl = null;

      if (template === 'Video') {
        const videoFile = getFile(req, 'videoFile');
        if (videoFile) {
          mediaUrl = saveFile(videoFile, contentDir, 'video_');
        } else if (videoUrl) {
          mediaUrl = videoUrl;
        } else {
          return res.status(400).json({ success: false, error: 'Video file or URL is required' });
        }
        await connection.query(
          'UPDATE cms_contents SET media_url = ? WHERE id = ?',
          [mediaUrl, contentId]
        );
      }
      else if (template === 'Extract from PDF') {
        const pdfFile = getFile(req, 'pdfFile');
        if (pdfFile) {
          pdfUrl = saveFile(pdfFile, contentDir, 'pdf_');
        } else {
          return res.status(400).json({ success: false, error: 'PDF file is required' });
        }
        await connection.query(
          'UPDATE cms_contents SET pdf_url = ?, pdf_text = ? WHERE id = ?',
          [pdfUrl, pdfText || null, contentId]
        );
      }
      else if (template === 'Extract from URL') {
        if (!sourceUrl) {
          return res.status(400).json({ success: false, error: 'Source URL is required' });
        }
        await connection.query(
          'UPDATE cms_contents SET source_url = ? WHERE id = ?',
          [sourceUrl, contentId]
        );
      }
      else if (template === 'Multiple Image Text') {
        const slideCountNum = parseInt(slideCount) || 0;
        if (slideCountNum === 0) {
          return res.status(400).json({ success: false, error: 'At least one slide is required' });
        }

        const imageInserts = [];
        const textInserts = [];

        for (let i = 0; i < slideCountNum; i++) {
          const type = req.body[`slideType_${i}`];
          if (!type) continue;

          if (type === 'image') {
            const imageFile = getFile(req, `slideImage_${i}`);
            let imageUrl = null;
            if (imageFile) {
              imageUrl = saveFile(imageFile, contentDir, `slide_${i}_`);
            }
            // For creation, if no file, we could skip or keep null - but we require file for new content
            if (imageUrl) {
              imageInserts.push([contentId, imageUrl, i]);
            }
          } else if (type === 'text') {
            const textContent = req.body[`slideText_${i}`] || '';
            textInserts.push([contentId, textContent, i]);
          }
        }

        if (imageInserts.length > 0) {
          await connection.query(
            'INSERT INTO cms_content_images (content_id, image_url, sort_order) VALUES ?',
            [imageInserts]
          );
        }
        if (textInserts.length > 0) {
          await connection.query(
            'INSERT INTO cms_content_text (content_id, text_content, sort_order) VALUES ?',
            [textInserts]
          );
        }

        if (imageInserts.length > 0) {
          thumbnailUrl = imageInserts[0][1];
          await connection.query(
            'UPDATE cms_contents SET thumbnail_url = ? WHERE id = ?',
            [thumbnailUrl, contentId]
          );
        }
      }

      await connection.commit();

      const [created] = await connection.query(
        'SELECT * FROM cms_contents WHERE id = ?',
        [contentId]
      );

      res.status(201).json({
        success: true,
        message: 'Content created successfully',
        data: created[0]
      });

    } catch (err) {
      await connection.rollback();
      console.error('Add content error:', err);
      throw err;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Add content error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// ------------------------------
// GET CONTENTS BY SECTION
// ------------------------------
exports.getContentsBySection = async (req, res) => {
  try {
    const { sectionId } = req.params;

    if (!sectionId || isNaN(sectionId)) {
      return res.status(400).json({ success: false, error: 'Invalid section ID' });
    }

    const connection = await pool.getConnection();
    try {
      const [contents] = await connection.query(
        `SELECT id, title, content_type 
         FROM cms_contents 
         WHERE section_id = ? AND status = 'active'
         ORDER BY sort_order ASC, id ASC`,
        [sectionId]
      );

      res.json({
        success: true,
        data: contents
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Get contents by section error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// ------------------------------
// GET CONTENT BY ID
// ------------------------------
exports.getContentById = async (req, res) => {
  try {
    const { contentId } = req.params;

    if (!contentId || isNaN(contentId)) {
      return res.status(400).json({ success: false, error: 'Invalid content ID' });
    }

    const connection = await pool.getConnection();
    try {
      const [contentRows] = await connection.query(
        `SELECT id, section_id, content_type, title, description, 
                media_url, thumbnail_url, pdf_url, pdf_text, source_url, 
                status, sort_order, created_at, updated_at
         FROM cms_contents 
         WHERE id = ? AND status = 'active'`,
        [contentId]
      );

      if (contentRows.length === 0) {
        return res.status(404).json({ success: false, error: 'Content not found or inactive' });
      }

      const content = contentRows[0];

      const [slidesRows] = await connection.query(
        `SELECT 'image' AS type, image_url AS content, sort_order
         FROM cms_content_images
         WHERE content_id = ?
         UNION ALL
         SELECT 'text' AS type, text_content AS content, sort_order
         FROM cms_content_text
         WHERE content_id = ?
         ORDER BY sort_order ASC`,
        [contentId, contentId]
      );

      content.slides = slidesRows.map(({ type, content }) => ({ type, content }));

      res.json({
        success: true,
        data: content
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Get content by ID error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// ------------------------------
// UPDATE CONTENT (FIXED)
// ------------------------------
exports.updateContent = async (req, res) => {
  try {
    const { contentId } = req.params;
    const {
      title,
      description,
      status,
      sort_order,
      videoUrl,
      sourceUrl,
      pdfText,
      slideCount,
    } = req.body;

    if (!contentId || isNaN(contentId)) {
      return res.status(400).json({ success: false, error: 'Valid content ID required' });
    }

    const connection = await pool.getConnection();
    try {
      // 1. Fetch existing content
      const [existing] = await connection.query(
        'SELECT * FROM cms_contents WHERE id = ?',
        [contentId]
      );
      if (existing.length === 0) {
        return res.status(404).json({ success: false, error: 'Content not found' });
      }
      const content = existing[0];

      // 2. Build update query (common fields)
      const updates = [];
      const values = [];

      if (title !== undefined) {
        updates.push('title = ?');
        values.push(title.trim() || null);
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

      // 3. Handle media fields based on content_type
      const contentType = content.content_type;
      const contentDir = path.join('uploads', 'cmscontent', contentId.toString());
      ensureDir(contentDir);

      // --- Video, PDF, URL handling unchanged ---
      if (contentType === 'video') {
        const videoFile = getFile(req, 'videoFile');
        if (videoFile) {
          if (content.media_url && !content.media_url.startsWith('http')) {
            deleteFile(content.media_url);
          }
          const newMediaUrl = saveFile(videoFile, contentDir, 'video_');
          updates.push('media_url = ?');
          values.push(newMediaUrl);
        } else if (videoUrl !== undefined) {
          updates.push('media_url = ?');
          values.push(videoUrl || null);
        }
      }

      if (contentType === 'pdf_extract') {
        const pdfFile = getFile(req, 'pdfFile');
        if (pdfFile) {
          if (content.pdf_url) deleteFile(content.pdf_url);
          const newPdfUrl = saveFile(pdfFile, contentDir, 'pdf_');
          updates.push('pdf_url = ?');
          values.push(newPdfUrl);
        }
        if (pdfText !== undefined) {
          updates.push('pdf_text = ?');
          values.push(pdfText || null);
        }
      }

      if (contentType === 'url_extract') {
        if (sourceUrl !== undefined) {
          updates.push('source_url = ?');
          values.push(sourceUrl || null);
        }
      }

      // ----------------- NEW MULTIPLE IMAGE TEXT UPDATE -----------------
if (contentType === 'multiple_image_text') {
  const slideCountNum = parseInt(slideCount);
  if (!isNaN(slideCountNum) && slideCountNum >= 0) {
    // 1. Fetch existing slides
    const [existingImages] = await connection.query(
      'SELECT id, image_url, sort_order FROM cms_content_images WHERE content_id = ? ORDER BY sort_order ASC',
      [contentId]
    );
    const [existingTexts] = await connection.query(
      'SELECT id, text_content, sort_order FROM cms_content_text WHERE content_id = ? ORDER BY sort_order ASC',
      [contentId]
    );

    // Build maps by sort_order
    const imageMap = {};
    existingImages.forEach(row => { imageMap[row.sort_order] = row; });
    const textMap = {};
    existingTexts.forEach(row => { textMap[row.sort_order] = row; });

    // Keep track of which old rows are used
    const usedImageIds = new Set();
    const usedTextIds = new Set();

    // Prepare arrays for new inserts (only for new positions or type changes)
    const imageInserts = [];
    const textInserts = [];

    for (let i = 0; i < slideCountNum; i++) {
      const type = req.body[`slideType_${i}`];
      if (!type) continue;

      if (type === 'image') {
        const imageFile = getFile(req, `slideImage_${i}`);
        let newImageUrl = null;
        if (imageFile) {
          newImageUrl = saveFile(imageFile, contentDir, `slide_${i}_`);
        }

        // Check if we already have an image at this position
        if (imageMap[i]) {
          // Update existing image
          const existingRow = imageMap[i];
          usedImageIds.add(existingRow.id);
          const finalUrl = newImageUrl || existingRow.image_url;
          // Delete old file if replaced
          if (newImageUrl && existingRow.image_url && !existingRow.image_url.startsWith('http')) {
            deleteFile(existingRow.image_url);
          }
          await connection.query(
            'UPDATE cms_content_images SET image_url = ?, sort_order = ? WHERE id = ?',
            [finalUrl, i, existingRow.id]
          );
        } else if (textMap[i]) {
          // There is a text at this position – replace it with an image
          const textRow = textMap[i];
          usedTextIds.add(textRow.id);
          // Delete the text row
          await connection.query('DELETE FROM cms_content_text WHERE id = ?', [textRow.id]);
          // Insert new image (only if we have a file)
          if (newImageUrl) {
            imageInserts.push([contentId, newImageUrl, i]);
          } else {
            // No file provided for new image – skip? Or maybe keep something? Better to require file.
            // We'll insert with null and later handle? But we can't insert null. We'll warn and skip.
            console.warn(`New image slide ${i} has no file, skipping.`);
          }
        } else {
          // Completely new slide – insert
          if (newImageUrl) {
            imageInserts.push([contentId, newImageUrl, i]);
          }
        }
      } else if (type === 'text') {
        const textContent = req.body[`slideText_${i}`] || '';

        if (textMap[i]) {
          // Update existing text
          const existingRow = textMap[i];
          usedTextIds.add(existingRow.id);
          await connection.query(
            'UPDATE cms_content_text SET text_content = ?, sort_order = ? WHERE id = ?',
            [textContent, i, existingRow.id]
          );
        } else if (imageMap[i]) {
          // There is an image at this position – replace it with text
          const imageRow = imageMap[i];
          usedImageIds.add(imageRow.id);
          // Delete the image row and its file
          if (imageRow.image_url && !imageRow.image_url.startsWith('http')) {
            deleteFile(imageRow.image_url);
          }
          await connection.query('DELETE FROM cms_content_images WHERE id = ?', [imageRow.id]);
          // Insert new text
          textInserts.push([contentId, textContent, i]);
        } else {
          // Completely new slide – insert text
          textInserts.push([contentId, textContent, i]);
        }
      }
    }

    // 2. Delete any old rows that were not used (i.e., removed slides)
    for (const row of existingImages) {
      if (!usedImageIds.has(row.id)) {
        if (row.image_url && !row.image_url.startsWith('http')) {
          deleteFile(row.image_url);
        }
        await connection.query('DELETE FROM cms_content_images WHERE id = ?', [row.id]);
      }
    }
    for (const row of existingTexts) {
      if (!usedTextIds.has(row.id)) {
        await connection.query('DELETE FROM cms_content_text WHERE id = ?', [row.id]);
      }
    }

    // 3. Insert new rows (if any)
    if (imageInserts.length > 0) {
      await connection.query(
        'INSERT INTO cms_content_images (content_id, image_url, sort_order) VALUES ?',
        [imageInserts]
      );
    }
    if (textInserts.length > 0) {
      await connection.query(
        'INSERT INTO cms_content_text (content_id, text_content, sort_order) VALUES ?',
        [textInserts]
      );
    }

    // 4. Update thumbnail
    const [firstImage] = await connection.query(
      'SELECT image_url FROM cms_content_images WHERE content_id = ? ORDER BY sort_order ASC LIMIT 1',
      [contentId]
    );
    if (firstImage.length > 0) {
      updates.push('thumbnail_url = ?');
      values.push(firstImage[0].image_url);
    } else {
      updates.push('thumbnail_url = ?');
      values.push(null);
    }
  }
}

      // If no updates, return existing
      if (updates.length === 0) {
        return res.json({
          success: true,
          message: 'No changes provided',
          data: content
        });
      }

      // 4. Execute update
      const query = `UPDATE cms_contents SET ${updates.join(', ')} WHERE id = ?`;
      values.push(contentId);
      await connection.query(query, values);

      // 5. Fetch updated content
      const [updated] = await connection.query(
        'SELECT * FROM cms_contents WHERE id = ?',
        [contentId]
      );

      res.json({
        success: true,
        message: 'Content updated successfully',
        data: updated[0]
      });

    } catch (err) {
      console.error('Update content error:', err);
      throw err;
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Update content error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};
// ------------------------------
// DELETE CONTENT
// ------------------------------
exports.deleteContent = async (req, res) => {
  try {
    const { contentId } = req.params;

    if (!contentId || isNaN(contentId)) {
      return res.status(400).json({ success: false, error: 'Valid content ID required' });
    }

    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query(
        'SELECT * FROM cms_contents WHERE id = ?',
        [contentId]
      );
      if (rows.length === 0) {
        return res.status(404).json({ success: false, error: 'Content not found' });
      }
      const content = rows[0];

      const contentDir = path.join('uploads', 'cmscontent', contentId.toString());
      if (content.media_url && !content.media_url.startsWith('http')) {
        deleteFile(content.media_url);
      }
      if (content.pdf_url) {
        deleteFile(content.pdf_url);
      }
      if (content.thumbnail_url && !content.thumbnail_url.startsWith('http')) {
        deleteFile(content.thumbnail_url);
      }
      const [images] = await connection.query(
        'SELECT image_url FROM cms_content_images WHERE content_id = ?',
        [contentId]
      );
      images.forEach(img => {
        if (img.image_url) deleteFile(img.image_url);
      });

      if (fs.existsSync(contentDir)) {
        fs.rmdirSync(contentDir, { recursive: true });
        console.log(`Deleted directory: ${contentDir}`);
      }

      await connection.query('DELETE FROM cms_contents WHERE id = ?', [contentId]);

      res.json({
        success: true,
        message: 'Content deleted successfully'
      });

    } catch (err) {
      console.error('Delete content error:', err);
      throw err;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Delete content error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};
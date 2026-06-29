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

    // Basic validation
    if (!sectionId || isNaN(sectionId)) {
      return res.status(400).json({ success: false, error: 'Valid section ID required' });
    }
    if (!title || !title.trim()) {
      return res.status(400).json({ success: false, error: 'Title is required' });
    }
    if (!template) {
      return res.status(400).json({ success: false, error: 'Template/content type is required' });
    }

    // Map frontend template to DB content_type
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
      // Verify section exists
      const [section] = await connection.query(
        'SELECT id FROM cms_sections WHERE id = ? AND status = "active"',
        [sectionId]
      );
      if (section.length === 0) {
        return res.status(404).json({ success: false, error: 'Section not found or inactive' });
      }

      await connection.beginTransaction();

      // Insert into cms_contents
      const [result] = await connection.query(
        `INSERT INTO cms_contents 
         (section_id, content_type, title, description, status, sort_order) 
         VALUES (?, ?, ?, ?, 'active', 0)`,
        [sectionId, contentType, title.trim(), description || null]
      );
      const contentId = result.insertId;

      // Create content directory
      const contentDir = path.join('uploads', 'cmscontent', contentId.toString());
      ensureDir(contentDir);

      let mediaUrl = null;
      let thumbnailUrl = null;
      let pdfUrl = null;

      // --- Handle files based on template ---
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
            imageInserts.push([contentId, imageUrl, i]);
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

        // Set thumbnail from first image slide
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
      // Optionally clean up uploaded files
      throw err;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Add content error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

// Modify existing getContentsBySection or add a new one for admin list view
exports.getContentsBySection = async (req, res) => {
    try {
        const { sectionId } = req.params;

        if (!sectionId || isNaN(sectionId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid section ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // Return only id, title, content_type for list view
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
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};

exports.getContentById = async (req, res) => {
    try {
        const { contentId } = req.params;

        if (!contentId || isNaN(contentId)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid content ID'
            });
        }

        const connection = await pool.getConnection();

        try {
            // 1. Fetch content
            const [contentRows] = await connection.query(
                `SELECT id, section_id, content_type, title, description, 
                        media_url, thumbnail_url, pdf_url,pdf_text, source_url, 
                        status, sort_order, created_at, updated_at
                 FROM cms_contents 
                 WHERE id = ? AND status = 'active'`,
                [contentId]
            );

            if (contentRows.length === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Content not found or inactive'
                });
            }

            const content = contentRows[0];

            // 2. Fetch all slides in a single UNION query (already ordered)
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

            // 3. Attach slides (remove sort_order)
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
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
};
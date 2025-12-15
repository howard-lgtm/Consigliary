const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// GET /api/v1/tracks - List user's tracks
router.get('/', async (req, res) => {
    try {
        const result = await query(
            `SELECT id, title, artist_name, duration, release_date, isrc_code, 
                    spotify_url, apple_music_url, soundcloud_url,
                    streams, revenue, created_at, updated_at
             FROM tracks 
             WHERE user_id = $1 
             ORDER BY created_at DESC`,
            [req.user.id]
        );

        res.json({
            success: true,
            data: {
                tracks: result.rows
            }
        });
    } catch (error) {
        console.error('Fetch tracks error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to fetch tracks'
            }
        });
    }
});

// GET /api/v1/tracks/:id - Get track details
router.get('/:id', async (req, res) => {
    try {
        const result = await query(
            'SELECT * FROM tracks WHERE id = $1 AND user_id = $2',
            [req.params.id, req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Track not found'
                }
            });
        }

        // Get contributors
        const contributors = await query(
            'SELECT * FROM contributors WHERE track_id = $1',
            [req.params.id]
        );

        const track = {
            ...result.rows[0],
            contributors: contributors.rows
        };

        res.json({
            success: true,
            data: { track }
        });
    } catch (error) {
        console.error('Fetch track error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to fetch track'
            }
        });
    }
});

// POST /api/v1/tracks - Create new track
router.post('/', async (req, res) => {
    try {
        const {
            title, artistName, duration, releaseDate,
            isrcCode, upcCode, copyrightOwner, copyrightYear, publisher,
            copyrightRegNumber, proAffiliation, spotifyUrl, appleMusicUrl,
            soundcloudUrl, drmStatus, licenseType, territory,
            masterFileLocation, contributors
        } = req.body;

        // Validation
        if (!title || !artistName) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Title and artist name are required'
                }
            });
        }

        // Insert track
        const result = await query(
            `INSERT INTO tracks (
                user_id, title, artist_name, duration, release_date,
                isrc_code, upc_code, copyright_owner, copyright_year, publisher,
                copyright_reg_number, pro_affiliation, spotify_url, apple_music_url,
                soundcloud_url, drm_status, license_type, territory, master_file_location
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
            RETURNING *`,
            [
                req.user.id, title, artistName, duration, releaseDate,
                isrcCode, upcCode, copyrightOwner, copyrightYear, publisher,
                copyrightRegNumber, proAffiliation, spotifyUrl, appleMusicUrl,
                soundcloudUrl, drmStatus, licenseType, territory, masterFileLocation
            ]
        );

        const track = result.rows[0];

        // Insert contributors if provided
        if (contributors && contributors.length > 0) {
            for (const contributor of contributors) {
                await query(
                    `INSERT INTO contributors (track_id, name, role, split_percentage, email, pro_affiliation)
                     VALUES ($1, $2, $3, $4, $5, $6)`,
                    [track.id, contributor.name, contributor.role, contributor.splitPercentage, 
                     contributor.email, contributor.proAffiliation]
                );
            }
        }

        res.status(201).json({
            success: true,
            data: { track },
            message: 'Track created successfully'
        });
    } catch (error) {
        console.error('Create track error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to create track'
            }
        });
    }
});

// PUT /api/v1/tracks/:id - Update track
router.put('/:id', async (req, res) => {
    try {
        // Verify ownership
        const existing = await query(
            'SELECT id FROM tracks WHERE id = $1 AND user_id = $2',
            [req.params.id, req.user.id]
        );

        if (existing.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Track not found'
                }
            });
        }

        const {
            title, artistName, duration, releaseDate,
            isrcCode, upcCode, copyrightOwner, copyrightYear, publisher,
            copyrightRegNumber, proAffiliation, spotifyUrl, appleMusicUrl,
            soundcloudUrl, drmStatus, licenseType, territory, masterFileLocation
        } = req.body;

        const result = await query(
            `UPDATE tracks SET
                title = COALESCE($1, title),
                artist_name = COALESCE($2, artist_name),
                duration = COALESCE($3, duration),
                release_date = COALESCE($4, release_date),
                isrc_code = COALESCE($5, isrc_code),
                upc_code = COALESCE($6, upc_code),
                copyright_owner = COALESCE($7, copyright_owner),
                copyright_year = COALESCE($8, copyright_year),
                publisher = COALESCE($9, publisher),
                copyright_reg_number = COALESCE($10, copyright_reg_number),
                pro_affiliation = COALESCE($11, pro_affiliation),
                spotify_url = COALESCE($12, spotify_url),
                apple_music_url = COALESCE($13, apple_music_url),
                soundcloud_url = COALESCE($14, soundcloud_url),
                drm_status = COALESCE($15, drm_status),
                license_type = COALESCE($16, license_type),
                territory = COALESCE($17, territory),
                master_file_location = COALESCE($18, master_file_location)
             WHERE id = $19 AND user_id = $20
             RETURNING *`,
            [
                title, artistName, duration, releaseDate,
                isrcCode, upcCode, copyrightOwner, copyrightYear, publisher,
                copyrightRegNumber, proAffiliation, spotifyUrl, appleMusicUrl,
                soundcloudUrl, drmStatus, licenseType, territory, masterFileLocation,
                req.params.id, req.user.id
            ]
        );

        res.json({
            success: true,
            data: { track: result.rows[0] },
            message: 'Track updated successfully'
        });
    } catch (error) {
        console.error('Update track error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to update track'
            }
        });
    }
});

// DELETE /api/v1/tracks/:id - Delete track
router.delete('/:id', async (req, res) => {
    try {
        const result = await query(
            'DELETE FROM tracks WHERE id = $1 AND user_id = $2 RETURNING id',
            [req.params.id, req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Track not found'
                }
            });
        }

        res.json({
            success: true,
            message: 'Track deleted successfully'
        });
    } catch (error) {
        console.error('Delete track error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to delete track'
            }
        });
    }
});

module.exports = router;

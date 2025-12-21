const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');

const execAsync = promisify(exec);

/**
 * Download audio from TikTok URL using yt-dlp
 * @param {string} url - TikTok video URL
 * @returns {Promise<{buffer: Buffer, filename: string, metadata: Object}>}
 */
async function downloadTikTokAudio(url) {
    // Validate TikTok URL
    if (!url || (!url.includes('tiktok.com') && !url.includes('vm.tiktok.com'))) {
        throw new Error('Invalid TikTok URL');
    }

    const tempDir = os.tmpdir();
    const outputTemplate = path.join(tempDir, `tiktok_${Date.now()}_%(id)s.%(ext)s`);

    try {
        // Download audio using yt-dlp
        console.log(`Downloading TikTok audio from: ${url}`);
        
        const { stdout, stderr } = await execAsync(
            `yt-dlp -x --audio-format mp3 --audio-quality 0 ` +
            `--output "${outputTemplate}" ` +
            `--print-json ` +
            `"${url}"`,
            {
                maxBuffer: 50 * 1024 * 1024, // 50MB buffer
                timeout: 120000 // 2 minute timeout
            }
        );

        // Parse metadata from stdout
        let metadata = {};
        try {
            const lines = stdout.trim().split('\n');
            const jsonLine = lines.find(line => line.startsWith('{'));
            if (jsonLine) {
                metadata = JSON.parse(jsonLine);
            }
        } catch (parseError) {
            console.warn('Could not parse yt-dlp metadata:', parseError);
        }

        // Find the downloaded file
        const files = await fs.readdir(tempDir);
        const downloadedFile = files.find(f => 
            f.startsWith(`tiktok_`) && 
            f.includes(metadata.id || '') && 
            f.endsWith('.mp3')
        );

        if (!downloadedFile) {
            throw new Error('Downloaded file not found');
        }

        const filePath = path.join(tempDir, downloadedFile);
        
        // Read file into buffer
        const buffer = await fs.readFile(filePath);
        
        // Clean up temp file
        await fs.unlink(filePath).catch(err => 
            console.warn('Could not delete temp file:', err)
        );

        console.log(`Successfully downloaded TikTok audio: ${downloadedFile}`);

        return {
            buffer,
            filename: downloadedFile,
            metadata: {
                title: metadata.title || 'TikTok Audio',
                author: metadata.uploader || metadata.creator || 'Unknown',
                duration: metadata.duration || null,
                description: metadata.description || null,
                uploadDate: metadata.upload_date || null,
                videoId: metadata.id || null,
                url: metadata.webpage_url || url
            }
        };
    } catch (error) {
        console.error('TikTok download error:', error);
        
        // Provide more specific error messages
        if (error.message.includes('not found')) {
            throw new Error('yt-dlp is not installed or not in PATH');
        } else if (error.message.includes('timeout')) {
            throw new Error('Download timeout - video may be too large or network is slow');
        } else if (error.message.includes('Video unavailable')) {
            throw new Error('TikTok video is unavailable or private');
        } else {
            throw new Error(`Failed to download TikTok audio: ${error.message}`);
        }
    }
}

/**
 * Extract TikTok video ID from URL
 * @param {string} url - TikTok URL
 * @returns {string|null} Video ID
 */
function extractTikTokId(url) {
    try {
        const patterns = [
            /tiktok\.com\/@[\w.-]+\/video\/(\d+)/,
            /tiktok\.com\/v\/(\d+)/,
            /vm\.tiktok\.com\/([A-Za-z0-9]+)/
        ];

        for (const pattern of patterns) {
            const match = url.match(pattern);
            if (match) return match[1];
        }
        return null;
    } catch (error) {
        return null;
    }
}

module.exports = {
    downloadTikTokAudio,
    extractTikTokId
};

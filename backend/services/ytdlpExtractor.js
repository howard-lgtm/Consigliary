const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');
const ffmpeg = require('fluent-ffmpeg');

const execAsync = promisify(exec);

class YtDlpExtractor {
  /**
   * Extract audio from YouTube using yt-dlp
   * @param {string} url - YouTube URL
   * @returns {Promise<Object>} Audio buffer and metadata
   */
  async extractFromYouTube(url) {
    const tempDir = os.tmpdir();
    const videoId = this.extractYouTubeId(url);
    const tempAudioPath = path.join(tempDir, `${videoId}_ytdlp.mp3`);

    try {
      console.log(`📹 Extracting audio with yt-dlp: ${videoId}`);

      // Get video info first
      const infoCommand = `yt-dlp --dump-json "${url}"`;
      const { stdout: infoJson } = await execAsync(infoCommand);
      const info = JSON.parse(infoJson);

      const metadata = {
        title: info.title,
        author: info.uploader || info.channel,
        channelUrl: info.channel_url || info.uploader_url,
        viewCount: info.view_count || 0,
        uploadDate: info.upload_date || null,
        duration: info.duration || 0
      };

      console.log(`📊 Video metadata: ${metadata.title} by ${metadata.author}`);

      // Download and extract audio (30 seconds)
      const downloadCommand = `yt-dlp -x --audio-format mp3 --audio-quality 128K --postprocessor-args "ffmpeg:-t 30" -o "${tempAudioPath}" "${url}"`;
      
      console.log('⬇️  Downloading audio...');
      await execAsync(downloadCommand, { maxBuffer: 50 * 1024 * 1024 }); // 50MB buffer

      // Read the audio file
      const buffer = await fs.readFile(tempAudioPath);
      console.log(`📦 Audio buffer size: ${buffer.length} bytes`);

      // Clean up
      await fs.unlink(tempAudioPath).catch(err => {
        console.warn('⚠️  Could not delete temp file:', err.message);
      });

      return {
        buffer,
        metadata
      };

    } catch (error) {
      console.error('❌ yt-dlp extraction error:', error);
      
      // Clean up on error
      try {
        await fs.unlink(tempAudioPath);
      } catch (cleanupError) {
        // Ignore cleanup errors
      }

      throw new Error(`Failed to extract audio with yt-dlp: ${error.message}`);
    }
  }

  /**
   * Extract video ID from YouTube URL
   * @param {string} url
   * @returns {string} Video ID
   */
  extractYouTubeId(url) {
    const videoIdMatch = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)/);
    return videoIdMatch ? videoIdMatch[1] : 'unknown';
  }
}

module.exports = new YtDlpExtractor();

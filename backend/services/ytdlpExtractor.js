const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');
const ffmpeg = require('fluent-ffmpeg');

const execAsync = promisify(exec);

class YtDlpExtractor {
  /**
   * Extract audio from any supported platform using yt-dlp
   * @param {string} url - Video URL (YouTube, TikTok, Instagram)
   * @param {string} platform - Platform name
   * @returns {Promise<Object>} Audio buffer and metadata
   */
  async extractAudio(url, platform = 'YouTube') {
    const tempDir = os.tmpdir();
    const videoId = this.extractVideoId(url, platform);
    const tempAudioPath = path.join(tempDir, `${videoId}_ytdlp.mp3`);

    try {
      console.log(`📹 Extracting audio with yt-dlp from ${platform}: ${videoId}`);

      // Build yt-dlp command with platform-specific options
      let baseOptions = '';
      if (platform === 'TikTok') {
        // Use browser impersonation for TikTok to bypass bot detection
        baseOptions = '--impersonate chrome';
      } else if (platform === 'Instagram') {
        // Instagram also benefits from impersonation
        baseOptions = '--impersonate chrome';
      }

      // Get video info first
      const infoCommand = `yt-dlp ${baseOptions} --dump-json "${url}"`;
      const { stdout: infoJson } = await execAsync(infoCommand);
      const info = JSON.parse(infoJson);

      const metadata = {
        title: info.title,
        author: info.uploader || info.channel || info.creator,
        channelUrl: info.channel_url || info.uploader_url || null,
        viewCount: info.view_count || 0,
        uploadDate: info.upload_date || null,
        duration: info.duration || 0,
        platform: platform
      };

      console.log(`📊 Video metadata: ${metadata.title} by ${metadata.author}`);

      // Download and extract audio (30 seconds)
      const downloadCommand = `yt-dlp ${baseOptions} -x --audio-format mp3 --audio-quality 128K --postprocessor-args "ffmpeg:-t 30" -o "${tempAudioPath}" "${url}"`;
      
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
      console.error(`❌ yt-dlp extraction error (${platform}):`, error);
      
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
   * Extract audio from YouTube using yt-dlp (legacy method)
   * @param {string} url - YouTube URL
   * @returns {Promise<Object>} Audio buffer and metadata
   */
  async extractFromYouTube(url) {
    return this.extractAudio(url, 'YouTube');
  }

  /**
   * Extract audio from TikTok using yt-dlp
   * @param {string} url - TikTok URL
   * @returns {Promise<Object>} Audio buffer and metadata
   */
  async extractFromTikTok(url) {
    return this.extractAudio(url, 'TikTok');
  }

  /**
   * Extract audio from Instagram using yt-dlp
   * @param {string} url - Instagram URL
   * @returns {Promise<Object>} Audio buffer and metadata
   */
  async extractFromInstagram(url) {
    return this.extractAudio(url, 'Instagram');
  }

  /**
   * Old YouTube extraction method - keeping for compatibility
   */
  async _extractFromYouTubeOld(url) {
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

  /**
   * Extract video ID from any platform URL
   * @param {string} url
   * @param {string} platform
   * @returns {string} Video ID or hash
   */
  extractVideoId(url, platform) {
    if (platform === 'YouTube') {
      return this.extractYouTubeId(url);
    } else if (platform === 'TikTok') {
      // TikTok URLs: https://www.tiktok.com/@user/video/1234567890
      const match = url.match(/\/video\/(\d+)/);
      return match ? match[1] : `tiktok_${Date.now()}`;
    } else if (platform === 'Instagram') {
      // Instagram URLs: https://www.instagram.com/p/ABC123/ or /reel/ABC123/
      const match = url.match(/\/(p|reel)\/([^\/\?]+)/);
      return match ? match[2] : `instagram_${Date.now()}`;
    }
    return `video_${Date.now()}`;
  }
}

module.exports = new YtDlpExtractor();

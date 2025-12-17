const ytdl = require('ytdl-core');
const ffmpeg = require('fluent-ffmpeg');
const { Readable } = require('stream');
const path = require('path');
const fs = require('fs').promises;
const os = require('os');

class AudioExtractor {
  /**
   * Extract audio from a video URL
   * @param {string} url - Video URL (YouTube, TikTok, Instagram)
   * @returns {Promise<{buffer: Buffer, platform: string, videoId: string, metadata: Object}>}
   */
  async extractAudio(url) {
    const platform = this.detectPlatform(url);
    
    switch (platform) {
      case 'YouTube':
        return await this.extractFromYouTube(url);
      case 'TikTok':
        throw new Error('TikTok extraction not yet implemented');
      case 'Instagram':
        throw new Error('Instagram extraction not yet implemented');
      default:
        throw new Error(`Unsupported platform: ${platform}`);
    }
  }

  /**
   * Detect platform from URL
   * @param {string} url
   * @returns {string} Platform name
   */
  detectPlatform(url) {
    if (url.includes('youtube.com') || url.includes('youtu.be')) {
      return 'YouTube';
    }
    if (url.includes('tiktok.com')) {
      return 'TikTok';
    }
    if (url.includes('instagram.com')) {
      return 'Instagram';
    }
    return 'Unknown';
  }

  /**
   * Extract video ID from YouTube URL
   * @param {string} url
   * @returns {string} Video ID
   */
  extractYouTubeId(url) {
    const videoIdMatch = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)/);
    return videoIdMatch ? videoIdMatch[1] : null;
  }

  /**
   * Extract audio from YouTube video
   * @param {string} url
   * @returns {Promise<Object>}
   */
  async extractFromYouTube(url) {
    try {
      // Validate URL
      if (!ytdl.validateURL(url)) {
        throw new Error('Invalid YouTube URL');
      }

      const videoId = this.extractYouTubeId(url);
      if (!videoId) {
        throw new Error('Could not extract video ID from URL');
      }

      console.log(`📹 Extracting audio from YouTube video: ${videoId}`);

      // Get video info
      const info = await ytdl.getInfo(url);
      const metadata = {
        title: info.videoDetails.title,
        author: info.videoDetails.author.name,
        channelUrl: info.videoDetails.author.channel_url,
        viewCount: parseInt(info.videoDetails.viewCount) || 0,
        uploadDate: info.videoDetails.uploadDate || null,
        duration: parseInt(info.videoDetails.lengthSeconds) || 0
      };

      console.log(`📊 Video metadata: ${metadata.title} by ${metadata.author}`);

      // Create temporary file path
      const tempDir = os.tmpdir();
      const tempAudioPath = path.join(tempDir, `${videoId}_audio.mp3`);

      // Download audio stream
      const audioStream = ytdl(url, {
        quality: 'highestaudio',
        filter: 'audioonly'
      });

      // Convert to MP3 and extract 30-second sample
      await new Promise((resolve, reject) => {
        ffmpeg(audioStream)
          .audioCodec('libmp3lame')
          .audioBitrate(128)
          .audioChannels(2)
          .audioFrequency(44100)
          .duration(30) // Extract first 30 seconds
          .output(tempAudioPath)
          .on('end', () => {
            console.log('✅ Audio extraction complete');
            resolve();
          })
          .on('error', (err) => {
            console.error('❌ FFmpeg error:', err);
            reject(err);
          })
          .run();
      });

      // Read the audio file into buffer
      const buffer = await fs.readFile(tempAudioPath);
      console.log(`📦 Audio buffer size: ${buffer.length} bytes`);

      // Clean up temp file
      await fs.unlink(tempAudioPath).catch(err => {
        console.warn('⚠️  Could not delete temp file:', err.message);
      });

      return {
        buffer,
        platform: 'YouTube',
        videoId,
        metadata
      };

    } catch (error) {
      console.error('❌ YouTube extraction error:', error);
      throw new Error(`Failed to extract audio from YouTube: ${error.message}`);
    }
  }

  /**
   * Extract audio from TikTok video (placeholder)
   * @param {string} url
   * @returns {Promise<Object>}
   */
  async extractFromTikTok(url) {
    // TODO: Implement TikTok extraction
    // May require different library or API
    throw new Error('TikTok extraction not yet implemented');
  }

  /**
   * Extract audio from Instagram video (placeholder)
   * @param {string} url
   * @returns {Promise<Object>}
   */
  async extractFromInstagram(url) {
    // TODO: Implement Instagram extraction
    // May require different library or API
    throw new Error('Instagram extraction not yet implemented');
  }
}

module.exports = new AudioExtractor();

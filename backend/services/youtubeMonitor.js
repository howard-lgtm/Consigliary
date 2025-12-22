const axios = require('axios');
const { query } = require('../config/database');

class YouTubeMonitorService {
  constructor() {
    this.apiKey = process.env.YOUTUBE_API_KEY;
    this.baseUrl = 'https://www.googleapis.com/youtube/v3';
    this.quotaLimit = 10000; // Daily quota limit for free tier
    this.quotaUsed = 0;
  }

  /**
   * Search YouTube for videos matching track information
   * @param {Object} track - Track information
   * @param {Object} options - Search options
   * @returns {Promise<Array>} Array of video results
   */
  async searchForTrack(track, options = {}) {
    if (!this.apiKey) {
      throw new Error('YouTube API key not configured');
    }

    const {
      maxResults = 10,
      publishedAfter = null,
      order = 'relevance' // relevance, date, viewCount
    } = options;

    // Build search query
    const searchQuery = this.buildSearchQuery(track);
    
    console.log(`🔍 Searching YouTube for: "${searchQuery}"`);

    try {
      const params = {
        part: 'snippet',
        q: searchQuery,
        type: 'video',
        maxResults,
        order,
        key: this.apiKey
      };

      if (publishedAfter) {
        params.publishedAfter = publishedAfter;
      }

      const response = await axios.get(`${this.baseUrl}/search`, { params });
      
      // Track quota usage (search costs 100 units)
      this.quotaUsed += 100;
      
      const videos = response.data.items || [];
      console.log(`✅ Found ${videos.length} videos`);

      return videos.map(video => ({
        videoId: video.id.videoId,
        videoUrl: `https://www.youtube.com/watch?v=${video.id.videoId}`,
        title: video.snippet.title,
        channelName: video.snippet.channelTitle,
        channelId: video.snippet.channelId,
        channelUrl: `https://www.youtube.com/channel/${video.snippet.channelId}`,
        thumbnailUrl: video.snippet.thumbnails.high?.url || video.snippet.thumbnails.default?.url,
        publishedAt: video.snippet.publishedAt,
        description: video.snippet.description
      }));

    } catch (error) {
      console.error('YouTube search error:', error.response?.data || error.message);
      throw new Error(`YouTube search failed: ${error.message}`);
    }
  }

  /**
   * Get detailed video statistics
   * @param {Array<string>} videoIds - Array of video IDs
   * @returns {Promise<Array>} Array of video statistics
   */
  async getVideoStatistics(videoIds) {
    if (!this.apiKey) {
      throw new Error('YouTube API key not configured');
    }

    if (videoIds.length === 0) {
      return [];
    }

    try {
      const params = {
        part: 'statistics,contentDetails',
        id: videoIds.join(','),
        key: this.apiKey
      };

      const response = await axios.get(`${this.baseUrl}/videos`, { params });
      
      // Track quota usage (videos.list costs 1 unit per video)
      this.quotaUsed += videoIds.length;

      const videos = response.data.items || [];

      return videos.map(video => ({
        videoId: video.id,
        viewCount: parseInt(video.statistics.viewCount) || 0,
        likeCount: parseInt(video.statistics.likeCount) || 0,
        commentCount: parseInt(video.statistics.commentCount) || 0,
        duration: video.contentDetails.duration
      }));

    } catch (error) {
      console.error('YouTube statistics error:', error.response?.data || error.message);
      return [];
    }
  }

  /**
   * Build search query from track information
   * @param {Object} track - Track information
   * @returns {string} Search query
   */
  buildSearchQuery(track) {
    const parts = [];
    
    if (track.title) {
      parts.push(`"${track.title}"`);
    }
    
    if (track.artist_name) {
      parts.push(track.artist_name);
    }

    return parts.join(' ');
  }

  /**
   * Monitor a single track for new uses
   * @param {string} trackId - Track ID
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Monitoring results
   */
  async monitorTrack(trackId, userId) {
    try {
      console.log(`\n📊 Starting monitoring for track: ${trackId}`);

      // Get track details
      const trackResult = await query(
        'SELECT * FROM tracks WHERE id = $1 AND user_id = $2',
        [trackId, userId]
      );

      if (trackResult.rows.length === 0) {
        throw new Error('Track not found');
      }

      const track = trackResult.rows[0];

      // Get monitoring job configuration
      const jobResult = await query(
        'SELECT * FROM monitoring_jobs WHERE track_id = $1 AND enabled = true',
        [trackId]
      );

      let job = jobResult.rows[0];
      
      // Create job if it doesn't exist
      if (!job) {
        const createJobResult = await query(
          `INSERT INTO monitoring_jobs (user_id, track_id, search_terms)
           VALUES ($1, $2, $3)
           RETURNING *`,
          [userId, trackId, [track.title, track.artist_name]]
        );
        job = createJobResult.rows[0];
      }

      // Calculate date range (last run or last 7 days)
      const publishedAfter = job.last_run_at 
        ? new Date(job.last_run_at).toISOString()
        : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

      // Search YouTube
      const videos = await this.searchForTrack(track, {
        maxResults: 20,
        publishedAfter,
        order: 'date'
      });

      // Get video statistics
      const videoIds = videos.map(v => v.videoId);
      const statistics = await this.getVideoStatistics(videoIds);

      // Merge statistics with video data
      const videosWithStats = videos.map(video => {
        const stats = statistics.find(s => s.videoId === video.videoId);
        return { ...video, ...stats };
      });

      // Filter out videos from the artist's own channel (if known)
      const filteredVideos = videosWithStats.filter(video => {
        // Skip if it's the artist's own upload
        if (track.artist_name && video.channelName.toLowerCase().includes(track.artist_name.toLowerCase())) {
          return false;
        }
        return true;
      });

      console.log(`📹 Found ${filteredVideos.length} potential matches (after filtering)`);

      // Create alerts for new matches
      const newAlerts = [];
      for (const video of filteredVideos) {
        try {
          // Check if alert already exists
          const existingAlert = await query(
            'SELECT id FROM monitoring_alerts WHERE track_id = $1 AND video_url = $2',
            [trackId, video.videoUrl]
          );

          if (existingAlert.rows.length === 0) {
            // Create new alert
            const alertResult = await query(
              `INSERT INTO monitoring_alerts (
                user_id, track_id, monitoring_job_id,
                platform, video_url, video_id, video_title,
                channel_name, channel_url, thumbnail_url,
                view_count, like_count, comment_count, upload_date,
                match_type, confidence_score
              ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
              RETURNING *`,
              [
                userId, trackId, job.id,
                'YouTube', video.videoUrl, video.videoId, video.title,
                video.channelName, video.channelUrl, video.thumbnailUrl,
                video.viewCount || 0, video.likeCount || 0, video.commentCount || 0,
                video.publishedAt,
                'potential', 0.5 // Will be updated after audio verification
              ]
            );
            
            newAlerts.push(alertResult.rows[0]);
            console.log(`🔔 New alert created: ${video.title}`);
          }
        } catch (error) {
          console.error(`Failed to create alert for ${video.videoId}:`, error.message);
        }
      }

      // Update monitoring job
      await query(
        `UPDATE monitoring_jobs 
         SET last_run_at = CURRENT_TIMESTAMP,
             next_run_at = CURRENT_TIMESTAMP + INTERVAL '7 days',
             total_runs = total_runs + 1,
             total_matches_found = total_matches_found + $1
         WHERE id = $2`,
        [newAlerts.length, job.id]
      );

      console.log(`✅ Monitoring complete: ${newAlerts.length} new alerts created\n`);

      return {
        success: true,
        trackId,
        videosFound: filteredVideos.length,
        newAlerts: newAlerts.length,
        alerts: newAlerts,
        quotaUsed: this.quotaUsed
      };

    } catch (error) {
      console.error('Track monitoring error:', error);
      
      // Update job with error
      await query(
        `UPDATE monitoring_jobs 
         SET last_error = $1,
             error_count = error_count + 1,
             status = CASE WHEN error_count >= 3 THEN 'error' ELSE status END
         WHERE track_id = $2`,
        [error.message, trackId]
      );

      throw error;
    }
  }

  /**
   * Monitor all active tracks for a user
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Monitoring results
   */
  async monitorUserTracks(userId) {
    try {
      console.log(`\n🎵 Starting monitoring for user: ${userId}`);

      // Get all tracks with active monitoring
      const result = await query(
        `SELECT DISTINCT t.* 
         FROM tracks t
         INNER JOIN monitoring_jobs mj ON t.id = mj.track_id
         WHERE t.user_id = $1 
         AND mj.enabled = true
         AND (mj.next_run_at IS NULL OR mj.next_run_at <= CURRENT_TIMESTAMP)
         ORDER BY t.created_at DESC`,
        [userId]
      );

      const tracks = result.rows;
      console.log(`📊 Found ${tracks.length} tracks to monitor`);

      const results = [];
      let totalNewAlerts = 0;

      for (const track of tracks) {
        try {
          const result = await this.monitorTrack(track.id, userId);
          results.push(result);
          totalNewAlerts += result.newAlerts;
        } catch (error) {
          console.error(`Failed to monitor track ${track.id}:`, error.message);
          results.push({
            success: false,
            trackId: track.id,
            error: error.message
          });
        }
      }

      console.log(`\n✅ User monitoring complete: ${totalNewAlerts} total new alerts`);

      return {
        success: true,
        userId,
        tracksMonitored: tracks.length,
        totalNewAlerts,
        results,
        quotaUsed: this.quotaUsed
      };

    } catch (error) {
      console.error('User monitoring error:', error);
      throw error;
    }
  }

  /**
   * Get quota usage information
   * @returns {Object} Quota information
   */
  getQuotaInfo() {
    return {
      used: this.quotaUsed,
      limit: this.quotaLimit,
      remaining: this.quotaLimit - this.quotaUsed,
      percentUsed: (this.quotaUsed / this.quotaLimit * 100).toFixed(2)
    };
  }
}

module.exports = new YouTubeMonitorService();

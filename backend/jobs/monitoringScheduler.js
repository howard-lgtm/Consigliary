const { query } = require('../config/database');
const youtubeMonitor = require('../services/youtubeMonitor');

class MonitoringScheduler {
  constructor() {
    this.isRunning = false;
    this.interval = null;
  }

  /**
   * Start the monitoring scheduler
   * @param {number} intervalMinutes - How often to check for jobs (default: 60 minutes)
   */
  start(intervalMinutes = 60) {
    if (this.isRunning) {
      console.log('⚠️  Monitoring scheduler is already running');
      return;
    }

    console.log(`🚀 Starting monitoring scheduler (checking every ${intervalMinutes} minutes)`);
    
    // Run immediately on start
    this.runScheduledJobs();

    // Then run on interval
    this.interval = setInterval(() => {
      this.runScheduledJobs();
    }, intervalMinutes * 60 * 1000);

    this.isRunning = true;
  }

  /**
   * Stop the monitoring scheduler
   */
  stop() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
      this.isRunning = false;
      console.log('🛑 Monitoring scheduler stopped');
    }
  }

  /**
   * Run all scheduled monitoring jobs that are due
   */
  async runScheduledJobs() {
    try {
      console.log('\n⏰ Checking for scheduled monitoring jobs...');

      // Get all jobs that are due to run
      const result = await query(
        `SELECT mj.*, t.title, t.artist_name, u.email
         FROM monitoring_jobs mj
         INNER JOIN tracks t ON mj.track_id = t.id
         INNER JOIN users u ON mj.user_id = u.id
         WHERE mj.enabled = true
         AND (mj.next_run_at IS NULL OR mj.next_run_at <= CURRENT_TIMESTAMP)
         AND mj.status != 'error'
         ORDER BY mj.next_run_at ASC NULLS FIRST
         LIMIT 10`
      );

      const jobs = result.rows;

      if (jobs.length === 0) {
        console.log('✅ No jobs due to run');
        return;
      }

      console.log(`📊 Found ${jobs.length} jobs to run`);

      for (const job of jobs) {
        try {
          console.log(`\n🎵 Running job for track: "${job.title}" by ${job.artist_name}`);
          
          const result = await youtubeMonitor.monitorTrack(job.track_id, job.user_id);
          
          console.log(`✅ Job completed: ${result.newAlerts} new alerts`);

          // TODO: Send notification email if new alerts found
          if (result.newAlerts > 0) {
            console.log(`📧 TODO: Send notification to ${job.email}`);
          }

        } catch (error) {
          console.error(`❌ Job failed for track ${job.track_id}:`, error.message);
        }
      }

      console.log('\n✅ Scheduled jobs completed\n');

    } catch (error) {
      console.error('❌ Scheduler error:', error);
    }
  }

  /**
   * Run monitoring for a specific user (manual trigger)
   * @param {string} userId - User ID
   */
  async runForUser(userId) {
    try {
      console.log(`\n🎵 Running monitoring for user: ${userId}`);
      const result = await youtubeMonitor.monitorUserTracks(userId);
      console.log(`✅ User monitoring completed: ${result.totalNewAlerts} new alerts`);
      return result;
    } catch (error) {
      console.error('❌ User monitoring error:', error);
      throw error;
    }
  }
}

module.exports = new MonitoringScheduler();

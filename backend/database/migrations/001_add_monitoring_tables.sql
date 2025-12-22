-- Monitoring Tables for Consigliary
-- Add monitoring jobs and alerts functionality

-- Monitoring Jobs Table
-- Tracks scheduled monitoring tasks for each track
CREATE TABLE IF NOT EXISTS monitoring_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    
    -- Job Configuration
    enabled BOOLEAN DEFAULT true,
    frequency VARCHAR(50) DEFAULT 'weekly', -- daily, weekly, monthly
    platforms TEXT[] DEFAULT ARRAY['YouTube', 'TikTok', 'Instagram'],
    
    -- Search Terms
    search_terms TEXT[], -- artist name, track title, custom keywords
    
    -- Job Status
    status VARCHAR(50) DEFAULT 'active', -- active, paused, error
    last_run_at TIMESTAMP,
    next_run_at TIMESTAMP,
    total_runs INTEGER DEFAULT 0,
    total_matches_found INTEGER DEFAULT 0,
    
    -- Error Tracking
    last_error TEXT,
    error_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Monitoring Alerts Table
-- Stores potential matches found by monitoring jobs
CREATE TABLE IF NOT EXISTS monitoring_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    monitoring_job_id UUID REFERENCES monitoring_jobs(id) ON DELETE SET NULL,
    
    -- Video Information
    platform VARCHAR(50) NOT NULL,
    video_url TEXT NOT NULL,
    video_id VARCHAR(255) NOT NULL,
    video_title TEXT,
    channel_name VARCHAR(255),
    channel_url TEXT,
    thumbnail_url TEXT,
    
    -- Match Information
    confidence_score DECIMAL(5,4), -- 0.0000 to 1.0000
    match_type VARCHAR(50), -- exact, partial, potential
    matched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Video Metrics
    view_count BIGINT,
    like_count INTEGER,
    comment_count INTEGER,
    upload_date TIMESTAMP,
    
    -- Alert Status
    status VARCHAR(50) DEFAULT 'new', -- new, reviewed, verified, dismissed, licensed
    reviewed_at TIMESTAMP,
    reviewed_by UUID REFERENCES users(id),
    
    -- Actions Taken
    verification_id UUID REFERENCES verifications(id),
    license_id UUID REFERENCES licenses(id),
    
    -- Notes
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent duplicate alerts
    UNIQUE(track_id, video_url)
);

-- Monitoring Statistics Table
-- Aggregated stats for dashboard
CREATE TABLE IF NOT EXISTS monitoring_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID REFERENCES tracks(id) ON DELETE CASCADE,
    
    -- Time Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Metrics
    total_scans INTEGER DEFAULT 0,
    total_matches_found INTEGER DEFAULT 0,
    total_verified INTEGER DEFAULT 0,
    total_licensed INTEGER DEFAULT 0,
    total_dismissed INTEGER DEFAULT 0,
    
    -- Revenue
    potential_revenue DECIMAL(10,2) DEFAULT 0,
    actual_revenue DECIMAL(10,2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, track_id, period_start, period_end)
);

-- Indexes for Performance
CREATE INDEX idx_monitoring_jobs_user_id ON monitoring_jobs(user_id);
CREATE INDEX idx_monitoring_jobs_track_id ON monitoring_jobs(track_id);
CREATE INDEX idx_monitoring_jobs_next_run ON monitoring_jobs(next_run_at) WHERE enabled = true;

CREATE INDEX idx_monitoring_alerts_user_id ON monitoring_alerts(user_id);
CREATE INDEX idx_monitoring_alerts_track_id ON monitoring_alerts(track_id);
CREATE INDEX idx_monitoring_alerts_status ON monitoring_alerts(status);
CREATE INDEX idx_monitoring_alerts_created_at ON monitoring_alerts(created_at DESC);

CREATE INDEX idx_monitoring_stats_user_id ON monitoring_stats(user_id);
CREATE INDEX idx_monitoring_stats_period ON monitoring_stats(period_start, period_end);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_monitoring_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER monitoring_jobs_updated_at
    BEFORE UPDATE ON monitoring_jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_monitoring_updated_at();

CREATE TRIGGER monitoring_alerts_updated_at
    BEFORE UPDATE ON monitoring_alerts
    FOR EACH ROW
    EXECUTE FUNCTION update_monitoring_updated_at();

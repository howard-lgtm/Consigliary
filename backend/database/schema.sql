-- Consigliary Database Schema
-- PostgreSQL 14+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    artist_name VARCHAR(255),
    profile_image_url TEXT,
    subscription_plan VARCHAR(50) DEFAULT 'free', -- free, pro, enterprise
    subscription_status VARCHAR(50) DEFAULT 'active', -- active, cancelled, expired
    subscription_expires_at TIMESTAMP,
    stripe_customer_id VARCHAR(255),
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tracks Table
CREATE TABLE tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    artist_name VARCHAR(255) NOT NULL,
    duration VARCHAR(10), -- MM:SS format
    release_date VARCHAR(4), -- YYYY
    
    -- Metadata
    isrc_code VARCHAR(12),
    upc_code VARCHAR(13),
    copyright_owner VARCHAR(255),
    copyright_year VARCHAR(4),
    publisher VARCHAR(255),
    copyright_reg_number VARCHAR(100),
    pro_affiliation VARCHAR(50), -- ASCAP, BMI, SESAC, GMR, Not Registered
    
    -- Platform Links
    spotify_url TEXT,
    apple_music_url TEXT,
    soundcloud_url TEXT,
    spotify_track_id VARCHAR(100),
    apple_music_track_id VARCHAR(100),
    
    -- DRM & Licensing
    drm_status VARCHAR(50) DEFAULT 'Protected', -- Protected, Unprotected, Watermarked
    license_type VARCHAR(100) DEFAULT 'All Rights Reserved',
    territory VARCHAR(100) DEFAULT 'Worldwide',
    
    -- Master File
    master_file_location VARCHAR(100), -- Cloud Storage, Personal Archive, etc.
    master_file_url TEXT,
    copyright_certificate_url TEXT,
    
    -- ACRCloud Integration
    acrcloud_fingerprint_id VARCHAR(255),
    audio_file_url TEXT,
    
    -- Analytics
    streams INTEGER DEFAULT 0,
    revenue DECIMAL(10, 2) DEFAULT 0.00,
    last_synced_at TIMESTAMP,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contributors Table (for split sheets)
CREATE TABLE contributors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    track_id UUID NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100), -- Producer, Writer, Featured Artist, etc.
    split_percentage DECIMAL(5, 2) NOT NULL, -- 0.00 to 100.00
    email VARCHAR(255),
    pro_affiliation VARCHAR(50),
    signed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verifications Table (URL verification results)
CREATE TABLE verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID REFERENCES tracks(id) ON DELETE SET NULL,
    
    -- Input
    platform VARCHAR(50) NOT NULL, -- YouTube, TikTok, Instagram
    video_url TEXT NOT NULL,
    video_id VARCHAR(255),
    
    -- ACR Results
    match_found BOOLEAN DEFAULT false,
    confidence_score DECIMAL(5, 4), -- 0.0000 to 1.0000
    matched_track_title VARCHAR(255),
    matched_artist VARCHAR(255),
    
    -- Video Metadata
    video_title VARCHAR(500),
    channel_name VARCHAR(255),
    channel_url TEXT,
    view_count INTEGER,
    upload_date TIMESTAMP,
    
    -- Evidence
    audio_sample_url TEXT, -- S3 URL of extracted audio
    
    -- Status
    status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, disputed, dismissed
    reviewed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Licenses Table (generated license agreements)
CREATE TABLE licenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    verification_id UUID REFERENCES verifications(id) ON DELETE SET NULL,
    
    -- Licensee Information
    licensee_name VARCHAR(255),
    licensee_email VARCHAR(255) NOT NULL,
    licensee_platform VARCHAR(50), -- YouTube, TikTok, Instagram
    licensee_channel_url TEXT,
    
    -- License Terms
    license_fee DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    territory VARCHAR(100) DEFAULT 'Worldwide',
    duration VARCHAR(100), -- Perpetual, 1 Year, etc.
    exclusivity VARCHAR(50) DEFAULT 'non-exclusive',
    
    -- Payment
    stripe_invoice_id VARCHAR(255),
    stripe_payment_intent_id VARCHAR(255),
    payment_status VARCHAR(50) DEFAULT 'pending', -- pending, paid, failed, refunded
    paid_at TIMESTAMP,
    
    -- Documents
    pdf_url TEXT,
    
    -- Status
    status VARCHAR(50) DEFAULT 'draft', -- draft, sent, signed, expired, cancelled
    sent_at TIMESTAMP,
    signed_at TIMESTAMP,
    expires_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Revenue Events Table
CREATE TABLE revenue_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID REFERENCES tracks(id) ON DELETE SET NULL,
    license_id UUID REFERENCES licenses(id) ON DELETE SET NULL,
    
    source VARCHAR(50) NOT NULL, -- streaming, syncLicense, performanceRights, mechanicalRights
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    date TIMESTAMP NOT NULL,
    description TEXT,
    platform VARCHAR(100),
    
    payment_status VARCHAR(50) DEFAULT 'pending', -- pending, paid, processing
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Split Sheets Table
CREATE TABLE split_sheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID REFERENCES tracks(id) ON DELETE SET NULL,
    track_title VARCHAR(255) NOT NULL,
    
    pdf_url TEXT,
    status VARCHAR(50) DEFAULT 'draft', -- draft, pending_signatures, completed
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Refresh Tokens Table (for JWT refresh)
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- API Keys Table (for future API access)
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    key_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    last_used_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_tracks_user_id ON tracks(user_id);
CREATE INDEX idx_tracks_acrcloud_fingerprint ON tracks(acrcloud_fingerprint_id);
CREATE INDEX idx_verifications_user_id ON verifications(user_id);
CREATE INDEX idx_verifications_track_id ON verifications(track_id);
CREATE INDEX idx_verifications_status ON verifications(status);
CREATE INDEX idx_licenses_user_id ON licenses(user_id);
CREATE INDEX idx_licenses_track_id ON licenses(track_id);
CREATE INDEX idx_licenses_payment_status ON licenses(payment_status);
CREATE INDEX idx_revenue_events_user_id ON revenue_events(user_id);
CREATE INDEX idx_contributors_track_id ON contributors(track_id);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tracks_updated_at BEFORE UPDATE ON tracks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_licenses_updated_at BEFORE UPDATE ON licenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_split_sheets_updated_at BEFORE UPDATE ON split_sheets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

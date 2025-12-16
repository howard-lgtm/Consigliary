const axios = require('axios');

class URLExtractor {
    // Extract video ID from various platform URLs
    extractVideoId(url, platform) {
        const patterns = {
            youtube: [
                /(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/,
                /youtube\.com\/embed\/([a-zA-Z0-9_-]{11})/,
                /youtube\.com\/v\/([a-zA-Z0-9_-]{11})/
            ],
            tiktok: [
                /tiktok\.com\/@[\w.-]+\/video\/(\d+)/,
                /vm\.tiktok\.com\/([a-zA-Z0-9]+)/
            ],
            instagram: [
                /instagram\.com\/(?:p|reel)\/([a-zA-Z0-9_-]+)/,
                /instagr\.am\/(?:p|reel)\/([a-zA-Z0-9_-]+)/
            ]
        };

        const platformPatterns = patterns[platform.toLowerCase()];
        if (!platformPatterns) {
            throw new Error(`Unsupported platform: ${platform}`);
        }

        for (const pattern of platformPatterns) {
            const match = url.match(pattern);
            if (match) {
                return match[1];
            }
        }

        throw new Error(`Could not extract video ID from URL: ${url}`);
    }

    // Detect platform from URL
    detectPlatform(url) {
        const urlLower = url.toLowerCase();
        
        if (urlLower.includes('youtube.com') || urlLower.includes('youtu.be')) {
            return 'YouTube';
        }
        if (urlLower.includes('tiktok.com')) {
            return 'TikTok';
        }
        if (urlLower.includes('instagram.com') || urlLower.includes('instagr.am')) {
            return 'Instagram';
        }

        throw new Error('Unsupported platform. Please use YouTube, TikTok, or Instagram URLs.');
    }

    // Extract metadata from YouTube (using oEmbed API - no API key required)
    async extractYouTubeMetadata(videoId) {
        try {
            const oembedUrl = `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${videoId}&format=json`;
            const response = await axios.get(oembedUrl);
            
            return {
                videoTitle: response.data.title,
                channelName: response.data.author_name,
                channelUrl: response.data.author_url,
                thumbnailUrl: response.data.thumbnail_url
            };
        } catch (error) {
            console.error('Error fetching YouTube metadata:', error.message);
            // Return partial data if oEmbed fails
            return {
                videoTitle: null,
                channelName: null,
                channelUrl: `https://www.youtube.com/watch?v=${videoId}`,
                thumbnailUrl: null
            };
        }
    }

    // Extract metadata from TikTok (using oEmbed API)
    async extractTikTokMetadata(videoId, url) {
        try {
            const oembedUrl = `https://www.tiktok.com/oembed?url=${encodeURIComponent(url)}`;
            const response = await axios.get(oembedUrl);
            
            return {
                videoTitle: response.data.title,
                channelName: response.data.author_name,
                channelUrl: response.data.author_url,
                thumbnailUrl: response.data.thumbnail_url
            };
        } catch (error) {
            console.error('Error fetching TikTok metadata:', error.message);
            return {
                videoTitle: null,
                channelName: null,
                channelUrl: url,
                thumbnailUrl: null
            };
        }
    }

    // Extract metadata from Instagram (using oEmbed API)
    async extractInstagramMetadata(videoId, url) {
        try {
            const oembedUrl = `https://graph.facebook.com/v12.0/instagram_oembed?url=${encodeURIComponent(url)}&access_token=public`;
            const response = await axios.get(oembedUrl);
            
            return {
                videoTitle: response.data.title || null,
                channelName: response.data.author_name,
                channelUrl: response.data.author_url || url,
                thumbnailUrl: response.data.thumbnail_url
            };
        } catch (error) {
            console.error('Error fetching Instagram metadata:', error.message);
            return {
                videoTitle: null,
                channelName: null,
                channelUrl: url,
                thumbnailUrl: null
            };
        }
    }

    // Main extraction method
    async extractMetadata(url) {
        const platform = this.detectPlatform(url);
        const videoId = this.extractVideoId(url, platform);

        let metadata;
        switch (platform) {
            case 'YouTube':
                metadata = await this.extractYouTubeMetadata(videoId);
                break;
            case 'TikTok':
                metadata = await this.extractTikTokMetadata(videoId, url);
                break;
            case 'Instagram':
                metadata = await this.extractInstagramMetadata(videoId, url);
                break;
            default:
                throw new Error(`Unsupported platform: ${platform}`);
        }

        return {
            platform,
            videoId,
            videoUrl: url,
            ...metadata
        };
    }

    // Validate URL format
    isValidUrl(url) {
        try {
            new URL(url);
            return true;
        } catch {
            return false;
        }
    }
}

module.exports = new URLExtractor();

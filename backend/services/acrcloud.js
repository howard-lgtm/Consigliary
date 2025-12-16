const crypto = require('crypto');
const axios = require('axios');

class ACRCloudService {
    constructor() {
        this.host = process.env.ACRCLOUD_HOST;
        this.accessKey = process.env.ACRCLOUD_ACCESS_KEY;
        this.accessSecret = process.env.ACRCLOUD_ACCESS_SECRET;
        this.endpoint = '/v1/identify';
    }

    /**
     * Generate fingerprint for audio file
     * @param {Buffer} audioBuffer - Audio file buffer
     * @returns {Promise<Object>} ACRCloud fingerprint result
     */
    async generateFingerprint(audioBuffer) {
        try {
            const timestamp = new Date().getTime();
            const stringToSign = `POST\n${this.endpoint}\n${this.accessKey}\naudio\n1\n${timestamp}`;
            const signature = crypto
                .createHmac('sha1', this.accessSecret)
                .update(Buffer.from(stringToSign, 'utf-8'))
                .digest()
                .toString('base64');

            const formData = {
                access_key: this.accessKey,
                sample_bytes: audioBuffer.length,
                sample: audioBuffer.toString('base64'),
                timestamp: timestamp,
                signature: signature,
                data_type: 'audio',
                signature_version: '1'
            };

            const response = await axios.post(
                `https://${this.host}${this.endpoint}`,
                new URLSearchParams(formData),
                {
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    }
                }
            );

            return response.data;
        } catch (error) {
            console.error('ACRCloud fingerprint error:', error);
            throw new Error('Failed to generate audio fingerprint');
        }
    }

    /**
     * Identify audio from buffer
     * @param {Buffer} audioBuffer - Audio file buffer
     * @returns {Promise<Object>} Recognition result
     */
    async identifyAudio(audioBuffer) {
        try {
            const result = await this.generateFingerprint(audioBuffer);
            
            if (result.status.code === 0) {
                // Match found
                return {
                    matched: true,
                    confidence: result.metadata?.music?.[0]?.score || 0,
                    title: result.metadata?.music?.[0]?.title,
                    artist: result.metadata?.music?.[0]?.artists?.[0]?.name,
                    album: result.metadata?.music?.[0]?.album?.name,
                    releaseDate: result.metadata?.music?.[0]?.release_date,
                    externalIds: result.metadata?.music?.[0]?.external_ids,
                    acrid: result.metadata?.music?.[0]?.acrid
                };
            } else if (result.status.code === 1001) {
                // No match found
                return {
                    matched: false,
                    message: 'No match found in ACRCloud database'
                };
            } else {
                // Error
                throw new Error(result.status.msg || 'ACRCloud identification failed');
            }
        } catch (error) {
            console.error('ACRCloud identify error:', error);
            throw error;
        }
    }

    /**
     * Add audio to ACRCloud bucket for future matching
     * @param {Buffer} audioBuffer - Audio file buffer
     * @param {Object} metadata - Track metadata
     * @returns {Promise<Object>} Upload result
     */
    async addAudioToLibrary(audioBuffer, metadata) {
        // Note: This requires ACRCloud's bucket API
        // For MVP, we'll just generate fingerprint and store the ID
        try {
            const result = await this.generateFingerprint(audioBuffer);
            
            return {
                success: true,
                fingerprintId: result.metadata?.music?.[0]?.acrid || null,
                message: 'Audio fingerprint generated'
            };
        } catch (error) {
            console.error('ACRCloud add to library error:', error);
            throw error;
        }
    }
}

module.exports = new ACRCloudService();

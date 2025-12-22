#!/usr/bin/env node

/**
 * Direct ACRCloud Test
 * Tests ACRCloud matching with a local audio file, bypassing YouTube download
 */

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const acrcloudService = require('../services/acrcloud');

async function testACRCloud() {
  console.log('🧪 ACRCloud Direct Test');
  console.log('======================\n');

  // Check if test audio file exists
  const testAudioPath = path.join(__dirname, '../../test-audio.mp3');
  
  if (!fs.existsSync(testAudioPath)) {
    console.log('❌ Test audio file not found at:', testAudioPath);
    console.log('\nTo test ACRCloud, you need an audio file.');
    console.log('Options:');
    console.log('  1. Download any MP3 and save it as: test-audio.mp3 in the Consigliary folder');
    console.log('  2. Use ffmpeg to create a test file from any video');
    console.log('\nExample:');
    console.log('  ffmpeg -i input.mp4 -t 30 -vn -acodec libmp3lame test-audio.mp3');
    process.exit(1);
  }

  console.log('✅ Found test audio file');
  const stats = fs.statSync(testAudioPath);
  console.log(`   Size: ${(stats.size / 1024).toFixed(2)} KB\n`);

  // Read audio file
  console.log('📖 Reading audio file...');
  const audioBuffer = fs.readFileSync(testAudioPath);
  console.log(`✅ Loaded ${audioBuffer.length} bytes\n`);

  // Test ACRCloud identification
  console.log('🎵 Sending to ACRCloud for identification...');
  console.log('   This may take 5-10 seconds...\n');

  try {
    const result = await acrcloudService.identifyAudio(audioBuffer);
    
    console.log('✅ ACRCloud Response Received!\n');
    console.log('======================');
    console.log('Match Found:', result.found ? '✅ YES' : '❌ NO');
    
    if (result.found) {
      console.log('Confidence:', result.confidence + '%');
      console.log('Track Title:', result.trackTitle);
      console.log('Artist:', result.artist);
      console.log('Album:', result.album || 'N/A');
      console.log('Release Date:', result.releaseDate || 'N/A');
      console.log('Label:', result.label || 'N/A');
      console.log('\n🎉 SUCCESS! ACRCloud matching is working!');
    } else {
      console.log('\n⚠️  No match found in ACRCloud database');
      console.log('This is normal if the audio is not in their database.');
      console.log('Try with a popular song to test matching.');
    }

    console.log('\n======================');
    console.log('Raw Response:');
    console.log(JSON.stringify(result, null, 2));

    process.exit(0);

  } catch (error) {
    console.error('\n❌ ACRCloud Error:', error.message);
    console.error('\nFull error:', error);
    process.exit(1);
  }
}

testACRCloud();

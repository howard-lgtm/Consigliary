// Test authentication endpoints
const baseURL = 'https://consigliary-production.up.railway.app/api/v1';

async function testAuth() {
  console.log('🧪 Testing Consigliary Authentication Endpoints\n');
  
  // Test 1: Register
  console.log('1️⃣ Testing REGISTER...');
  const registerResponse = await fetch(`${baseURL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: `test${Date.now()}@consigliary.com`,
      password: 'SecurePass123!',
      name: 'Test User',
      artistName: 'Test Artist'
    })
  });
  const registerData = await registerResponse.json();
  console.log('✅ Register:', registerData.success ? 'SUCCESS' : 'FAILED');
  
  if (!registerData.success) {
    console.error('❌ Registration failed:', registerData);
    return;
  }
  
  const { accessToken, refreshToken } = registerData.data;
  const { email } = registerData.data.user;
  console.log(`   User: ${email}\n`);
  
  // Test 2: Login
  console.log('2️⃣ Testing LOGIN...');
  const loginResponse = await fetch(`${baseURL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: email,
      password: 'SecurePass123!'
    })
  });
  const loginData = await loginResponse.json();
  console.log('✅ Login:', loginData.success ? 'SUCCESS' : 'FAILED\n');
  
  // Test 3: Get User Profile
  console.log('3️⃣ Testing GET PROFILE...');
  const profileResponse = await fetch(`${baseURL}/auth/me`, {
    headers: { 'Authorization': `Bearer ${accessToken}` }
  });
  const profileData = await profileResponse.json();
  console.log('✅ Profile:', profileData.success ? 'SUCCESS' : 'FAILED');
  console.log(`   Name: ${profileData.data?.name}\n`);
  
  // Test 4: Refresh Token
  console.log('4️⃣ Testing REFRESH TOKEN...');
  const refreshResponse = await fetch(`${baseURL}/auth/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken })
  });
  const refreshData = await refreshResponse.json();
  console.log('✅ Refresh:', refreshData.success ? 'SUCCESS' : 'FAILED\n');
  
  // Test 5: Logout
  console.log('5️⃣ Testing LOGOUT...');
  const logoutResponse = await fetch(`${baseURL}/auth/logout`, {
    method: 'POST',
    headers: { 
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ refreshToken })
  });
  const logoutData = await logoutResponse.json();
  console.log('✅ Logout:', logoutData.success ? 'SUCCESS' : 'FAILED\n');
  
  console.log('🎉 All authentication tests completed!\n');
}

testAuth().catch(console.error);

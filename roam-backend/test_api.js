const axios = require('axios');

const API_URL = 'http://localhost:3000/api';
let token1, token2, userId1, userId2, groupId, carpoolId;

const registerOrLoginUser = async (email, password, name) => {
  try {
    // First, try to log in
    const loginResponse = await axios.post(`${API_URL}/users/login`, { email, password });
    console.log(`User logged in: ${email}`);
    return loginResponse.data.token;
  } catch (loginError) {
    // If login fails, try to register
    if (loginError.response && loginError.response.status === 400) {
      try {
        await axios.post(`${API_URL}/users/register`, { email, password, name });
        console.log(`User registered: ${email}`);
        // Now login with the newly registered user
        const loginResponse = await axios.post(`${API_URL}/users/login`, { email, password });
        console.log(`User logged in after registration: ${email}`);
        return loginResponse.data.token;
      } catch (registerError) {
        console.error(`Error registering user ${email}:`, registerError.response?.data || registerError.message);
        throw registerError;
      }
    } else {
      console.error(`Error logging in user ${email}:`, loginError.response?.data || loginError.message);
      throw loginError;
    }
  }
};

const createGroup = async (token, name, description, is_public) => {
  try {
    const response = await axios.post(`${API_URL}/groups`, 
      { name, description, is_public },
      { headers: { 'x-auth-token': token } }
    );
    console.log(`Group created: ${name}`);
    return response.data.id;
  } catch (error) {
    console.error(`Error creating group ${name}:`, error.response?.data || error.message);
    throw error;
  }
};

const joinGroup = async (token, groupId) => {
  try {
    await axios.post(`${API_URL}/groups/join/${groupId}`, {}, 
      { headers: { 'x-auth-token': token } }
    );
    console.log(`Joined group: ${groupId}`);
  } catch (error) {
    console.error(`Error joining group ${groupId}:`, error.response?.data || error.message);
    throw error;
  }
};

const createCarpool = async (token, groupId, title, description, origin, destination, date_time, is_anonymous) => {
  try {
    const response = await axios.post(`${API_URL}/carpools`, 
      { group_id: groupId, title, description, origin, destination, date_time, is_anonymous },
      { headers: { 'x-auth-token': token } }
    );
    console.log(`Carpool created: ${title}`);
    return response.data.id;
  } catch (error) {
    console.error(`Error creating carpool ${title}:`, error.response?.data || error.message);
    throw error;
  }
};

const joinCarpool = async (token, carpoolId) => {
  try {
    await axios.post(`${API_URL}/carpools/${carpoolId}/join`, {}, 
      { headers: { 'x-auth-token': token } }
    );
    console.log(`Joined carpool: ${carpoolId}`);
  } catch (error) {
    console.error(`Error joining carpool ${carpoolId}:`, error.response?.data || error.message);
    throw error;
  }
};

const getCarpoolDetails = async (token, carpoolId) => {
  try {
    const response = await axios.get(`${API_URL}/carpools/${carpoolId}`, 
      { headers: { 'x-auth-token': token } }
    );
    console.log(`Retrieved carpool details: ${carpoolId}`);
    return response.data;
  } catch (error) {
    console.error(`Error getting carpool details ${carpoolId}:`, error.response?.data || error.message);
    throw error;
  }
};

const getUserRides = async (token) => {
  try {
    const response = await axios.get(`${API_URL}/carpools/my/rides`, 
      { headers: { 'x-auth-token': token } }
    );
    console.log(`Retrieved user rides`);
    return response.data;
  } catch (error) {
    console.error(`Error getting user rides:`, error.response?.data || error.message);
    throw error;
  }
};

const testAPI = async () => {
  try {
    // Register or login users
    token1 = await registerOrLoginUser('user1@stanford.edu', 'password123', 'User One');
    token2 = await registerOrLoginUser('user2@stanford.edu', 'password123', 'User Two');

    // Create a group
    groupId = await createGroup(token1, 'Test Group', 'A group for testing', true);

    // User 2 joins the group
    await joinGroup(token2, groupId);

    // User 1 creates a carpool request
    carpoolId = await createCarpool(token1, groupId, 'Trip to San Francisco', 'Weekend getaway to SF', 'Stanford', 'San Francisco', '2023-06-15T10:00:00Z', false);

    // User 2 joins the carpool
    await joinCarpool(token2, carpoolId);

    // Get carpool details
    const carpoolDetails = await getCarpoolDetails(token1, carpoolId);
    console.log('Carpool details:', carpoolDetails);

    // Get User 1's rides
    const user1Rides = await getUserRides(token1);
    console.log('User 1 rides:', user1Rides);

    // Get User 2's rides
    const user2Rides = await getUserRides(token2);
    console.log('User 2 rides:', user2Rides);

    console.log('All tests completed successfully!');
  } catch (error) {
    console.error('Test failed:', error.message);
  }
};

testAPI();

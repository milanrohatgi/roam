const jwt = require('jsonwebtoken');

module.exports = function(req, res, next) {
  console.log('Auth middleware triggered');
  console.log('Request headers:', req.headers);

  // Get token from header
  const token = req.header('Authorization') || req.header('x-auth-token');

  console.log('Received token:', token);

  // Check if no token
  if (!token) {
    console.log('No token provided');
    return res.status(401).json({ msg: 'No token, authorization denied' });
  }

  try {
    // Extract token without Bearer prefix (if present)
    const tokenWithoutBearer = token.startsWith('Bearer ') ? token.slice(7) : token;
    console.log('Token without Bearer:', tokenWithoutBearer);

    // Verify token
    const decoded = jwt.verify(tokenWithoutBearer, process.env.JWT_SECRET);
    console.log('Token verified successfully. Decoded payload:', decoded);
    
    // Add user from payload
    req.user = decoded;
    next();
  } catch (err) {
    console.log('Token verification failed:', err);
    res.status(401).json({ msg: 'Token is not valid', error: err.message });
  }
};

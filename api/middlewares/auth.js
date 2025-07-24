// api/middleware/auth.js
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();

/**
 * Middleware de vérification du token JWT
 * Cherche dans le header 'Authorization: Bearer <token>' OU 'x-auth-token'
 */
const verifyToken = (req, res, next) => {
    let token = null;

    // Standard : Authorization: Bearer <token>
    if (req.header('Authorization')) {
        const authHeader = req.header('Authorization');
        if (authHeader.startsWith('Bearer ')) {
            token = authHeader.split(' ')[1];
        }
    }
    // Support legacy : x-auth-token
    if (!token && req.header('x-auth-token')) {
        token = req.header('x-auth-token');
    }

    if (!token) {
        return res.status(401).json({ msg: "No token, authorization denied" });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'votre_jwt_secret');
        req.user = decoded;
        next();
    } catch (e) {
        return res.status(401).json({ msg: "Token is not valid" });
    }
};

/**
 * Middleware : vérifie si le user est admin
 */
const isAdmin = (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({ msg: "Access denied: admin only" });
    }
    next();
};

module.exports = { verifyToken, isAdmin };

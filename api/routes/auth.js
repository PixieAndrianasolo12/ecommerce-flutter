const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { verifyToken, isAdmin } = require('../middlewares/auth');
const dotenv = require('dotenv');
dotenv.config();

const router = express.Router();

// Inscription
router.post('/register', async (req, res) => {
    const { username, password, role } = req.body;
    
    try {
        // Validation des champs
        if (!username || !password) {
            return res.status(400).json({ msg: 'Please provide username and password' });
        }

        let user = await User.findOne({ username });
        if (user) return res.status(400).json({ msg: 'User already exists' });

        const hashedPassword = await bcrypt.hash(password, 10);
        user = new User({ 
            username, 
            password: hashedPassword, 
            role: role || 'user' // Valeur par défaut
        });
        
        await user.save();

        res.status(201).json({ msg: 'User registered successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server error', error: err.message });
    }
});

// Connexion
router.post('/login', async (req, res) => {
    const { username, password } = req.body;
    
    try {
        // Validation des champs
        if (!username || !password) {
            return res.status(400).json({ msg: 'Please provide username and password' });
        }

        const user = await User.findOne({ username });
        if (!user) return res.status(400).json({ msg: 'Invalid credentials' });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ msg: 'Invalid credentials' });

        const payload = { 
            id: user._id, 
            username: user.username, 
            role: user.role 
        };
        
        const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '12h' });

        res.json({ 
            token,
            user: payload,
            expiresIn: 43200 // 12h en secondes
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server error', error: err.message });
    }
});

// Route protégée User
router.get('/profile', verifyToken, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('-password');
        if (!user) return res.status(404).json({ msg: 'User not found' });
        res.json(user);
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server error', error: err.message });
    }
});

// Route protégée Admin
router.get('/admin', verifyToken, isAdmin, (req, res) => {
    res.json({ 
        msg: 'Welcome, Admin!',
        user: req.user 
    });
});

module.exports = router;
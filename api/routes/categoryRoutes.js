// api/routes/categoryRoutes.js
const express = require('express');
const router = express.Router();
const categoryCtrl = require('../controllers/categoryController');
const { verifyToken, isAdmin } = require('../middlewares/auth');

// Routes admin sécurisées
router.post('/', verifyToken, isAdmin, categoryCtrl.create);
router.put('/:id', verifyToken, isAdmin, categoryCtrl.update);
router.delete('/:id', verifyToken, isAdmin, categoryCtrl.delete);

// Public
router.get('/', categoryCtrl.getAll);
router.get('/:id', categoryCtrl.getOne);

module.exports = router;

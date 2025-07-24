const express = require('express');
const router = express.Router();
const productCtrl = require('../controllers/productController');
const { verifyToken, isAdmin } = require('../middlewares/auth');
const multer = require('multer');

// Multer config
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage });

router.post('/', verifyToken, isAdmin, upload.array('images'), productCtrl.create);
router.put('/:id', verifyToken, isAdmin, upload.array('images'), productCtrl.update);
router.delete('/:id', verifyToken, isAdmin, productCtrl.delete);

router.get('/', productCtrl.getAll);
router.get('/:id', productCtrl.getOne);

module.exports = router;

const Product = require('../models/Product');
const Category = require('../models/Category');

// Créer un produit
exports.create = async (req, res) => {
    try {
        const { name, description, price, stock, category } = req.body;
        // Gestion images (array de fichiers)
        const images = req.files ? req.files.map(file => file.filename) : [];
        // Vérification de la catégorie
        const cat = await Category.findById(category);
        if (!cat) return res.status(400).json({ message: 'Catégorie invalide' });

        const prod = await Product.create({
            name, description, price, stock, images, category
        });
        res.status(201).json(prod);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

// Lister tous les produits
exports.getAll = async (req, res) => {
    try {
        const prods = await Product.find().populate('category');
        res.json(prods);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Récupérer un produit par ID
exports.getOne = async (req, res) => {
    try {
        const prod = await Product.findById(req.params.id).populate('category');
        if (!prod) return res.status(404).json({ message: 'Produit non trouvé' });
        res.json(prod);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Mettre à jour un produit
exports.update = async (req, res) => {
    try {
        const update = {};
        const fields = ['name', 'description', 'price', 'stock', 'category'];
        fields.forEach(field => {
            if (req.body[field] !== undefined) update[field] = req.body[field];
        });
        if (req.files && req.files.length > 0) {
            update.images = req.files.map(file => file.filename);
        }
        // Vérifie la catégorie si elle est changée
        if (update.category) {
            const cat = await Category.findById(update.category);
            if (!cat) return res.status(400).json({ message: 'Catégorie invalide' });
        }
        const prod = await Product.findByIdAndUpdate(req.params.id, update, { new: true });
        if (!prod) return res.status(404).json({ message: 'Produit non trouvé' });
        res.json(prod);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

// Supprimer un produit
exports.delete = async (req, res) => {
    try {
        const prod = await Product.findByIdAndDelete(req.params.id);
        if (!prod) return res.status(404).json({ message: 'Produit non trouvé' });
        res.json({ message: 'Produit supprimé' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

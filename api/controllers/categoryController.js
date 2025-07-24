const Category = require('../models/Category');

exports.create = async (req, res) => {
    try {
        const cat = await Category.create(req.body);
        res.status(201).json(cat);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

exports.getAll = async (req, res) => {
    const cats = await Category.find();
    res.json(cats);
};

exports.getOne = async (req, res) => {
    const cat = await Category.findById(req.params.id);
    if (!cat) return res.status(404).json({ message: 'Catégorie non trouvée' });
    res.json(cat);
};

exports.update = async (req, res) => {
    try {
        const cat = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(cat);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

exports.delete = async (req, res) => {
    await Category.findByIdAndDelete(req.params.id);
    res.json({ message: 'Catégorie supprimée' });
};

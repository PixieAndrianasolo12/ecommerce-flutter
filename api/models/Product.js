const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
    name: { type: String, required: true },
    description: String,
    price: { type: Number, required: true },
    stock: { type: Number, default: 0 },
    images: [String], 
    category: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true }
});

module.exports = mongoose.model('Product', ProductSchema);

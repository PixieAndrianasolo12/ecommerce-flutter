import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'add_category_form.dart' show AddCategoryFormPage;
import 'add_product_form.dart' show AddProductFormPage;

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List categories = [];
  List products = [];
  String? error;
  bool loading = false;
  String selectedCategory = 'Toutes';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    setState(() { loading = true; });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final res = await http.get(
        Uri.parse('http://localhost:5000/api/categories'),
        headers: {
          "Authorization": "Bearer ${auth.token}"
        }
      );
      if (res.statusCode == 200) {
        categories = jsonDecode(res.body);
        setState(() {});
      } else {
        setState(() { error = "Erreur catégories: ${res.body}"; });
      }
    } catch (e) {
      setState(() { error = "Erreur réseau: $e"; });
    } finally { setState(() { loading = false; }); }
  }

  Future<void> fetchProducts() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final res = await http.get(
        Uri.parse('http://192.168.137.250:5000/api/products'),
        headers: {
          "Authorization": "Bearer ${auth.token}"
        }
      );
      if (res.statusCode == 200) {
        products = jsonDecode(res.body);
        setState(() {});
      } else {
        setState(() { error = "Erreur produits: ${res.body}"; });
      }
    } catch (e) {
      setState(() { error = "Erreur réseau: $e"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    List<String> allCats = ['Toutes', ...categories.map((c) => c['name'] as String)];
    var filteredProducts = selectedCategory == 'Toutes'
        ? products
        : products.where((p) => p['category']?['name'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
        title: Text('Admin Dashboard', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: "Se déconnecter",
            onPressed: () async {
              await auth.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres Catégories
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
              child: Row(
                children: allCats.map((cat) {
                  bool selected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: Color(0xFF3498DB),
                      backgroundColor: Color(0xFFECF0F1),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Color(0xFF2C3E50),
                        fontSize: isMobile ? 12 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (_) => setState(() => selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (loading)
            Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
            ),
          if (error != null)
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(error!, 
                style: TextStyle(
                  color: Color(0xFFE74C3C),
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
          // GRID DES PRODUITS
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 16,
                vertical: 8,
              ),
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 3,
                  mainAxisExtent: isMobile ? 220 : 260,
                  crossAxisSpacing: isMobile ? 8 : 16,
                  mainAxisSpacing: isMobile ? 8 : 16,
                ),
                itemBuilder: (context, index) {
                  var prod = filteredProducts[index];
                  String imageUrl = prod['image'] ??
                      "https://via.placeholder.com/120";
                  String name = prod['name'] ?? "";
                  String cat = prod['category']?['name'] ?? "-";
                  double price = (prod['price'] ?? 0).toDouble();
                  int stock = (prod['stock'] ?? 0);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 10 : 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_not_supported, 
                                  size: 50, 
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 5 : 8),
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                              color: Color(0xFF2C3E50),
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          Text(
                            cat,
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          SizedBox(height: isMobile ? 4 : 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("\$${price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Color(0xFFE74C3C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 14 : 16,
                                  )),
                              Text('Stock: $stock',
                                  style: TextStyle(
                                    color: Color(0xFF7F8C8D), 
                                    fontSize: isMobile ? 12 : 14,
                                  )),
                              Icon(
                                Icons.favorite_border, 
                                color: Color(0xFFE74C3C),
                                size: isMobile ? 18 : 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              heroTag: 'addCat',
              backgroundColor: Color(0xFF3498DB),
              icon: Icon(Icons.add, size: isMobile ? 20 : 24),
              label: Text(
                'Ajouter Catégorie',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCategoryFormPage(),
                  ),
                );
                if (result == true) fetchCategories();
              },
            ),
            if (!isMobile) SizedBox(width: 20),
            FloatingActionButton.extended(
              heroTag: 'addProd',
              backgroundColor: Color(0xFF2ECC71),
              icon: Icon(Icons.add_shopping_cart, size: isMobile ? 20 : 24),
              label: Text(
                'Ajouter Produit',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProductFormPage(categories: categories),
                  ),
                );
                if (result == true) fetchProducts();
              },
            ),
          ],
        ),
      ),
    );
  }
}
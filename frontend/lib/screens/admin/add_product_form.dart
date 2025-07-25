import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/auth_provider.dart';

class AddProductFormPage extends StatefulWidget {
  final List categories;
  const AddProductFormPage({required this.categories, Key? key}) : super(key: key);

  @override
  State<AddProductFormPage> createState() => _AddProductFormPageState();
}

class _AddProductFormPageState extends State<AddProductFormPage> with SingleTickerProviderStateMixin {
  final _prodNameCtrl = TextEditingController();
  final _prodDescCtrl = TextEditingController();
  final _prodPriceCtrl = TextEditingController();
  final _prodStockCtrl = TextEditingController();
  String? selectedCatId;
  XFile? _selectedImageX;
  File? _selectedImageFile;
  Uint8List? _imageBytes;
  bool loading = false;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String get baseUrl {
    String? url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      url = 'http://localhost:5000/api';
    }
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _prodNameCtrl.dispose();
    _prodDescCtrl.dispose();
    _prodPriceCtrl.dispose();
    _prodStockCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _selectedImageX = pickedFile;
        if (kIsWeb) {
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _imageBytes = bytes;
            });
          });
        } else {
          _selectedImageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> addProduct() async {
    if (_prodNameCtrl.text.isEmpty) {
      setState(() { error = "Le nom du produit est requis"; });
      return;
    }
    if (_prodPriceCtrl.text.isEmpty) {
      setState(() { error = "Le prix est requis"; });
      return;
    }
    if (_prodStockCtrl.text.isEmpty) {
      setState(() { error = "Le stock est requis"; });
      return;
    }
    if (selectedCatId == null) {
      setState(() { error = "Veuillez sélectionner une catégorie"; });
      return;
    }
    if (_selectedImageX == null) {
      setState(() { error = "Veuillez sélectionner une image produit"; });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (kIsWeb) {
        // FLUTTER WEB
        String? base64Image;
        if (_imageBytes != null) {
          base64Image = base64Encode(_imageBytes!);
        }
        final data = {
          "name": _prodNameCtrl.text,
          "description": _prodDescCtrl.text,
          "price": double.tryParse(_prodPriceCtrl.text) ?? 0,
          "stock": int.tryParse(_prodStockCtrl.text) ?? 0,
          "category": selectedCatId,
          if (base64Image != null) "image_base64": base64Image,
        };
        final res = await http.post(
          Uri.parse('$baseUrl/products'),
          headers: {
            "Authorization": "Bearer ${auth.token}",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
        );
        if (res.statusCode == 201) {
          await _animationController.reverse();
          Navigator.pop(context, true);
        } else {
          String err;
          try {
            err = jsonDecode(res.body)['message'] ?? res.body;
          } catch (_) {
            err = res.body;
          }
          setState(() {
            error = err;
            _shakeError();
          });
        }
      } else {
        // MOBILE (Android/iOS)
        var uri = Uri.parse('$baseUrl/products');
        var request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer ${auth.token}';
        request.fields['name'] = _prodNameCtrl.text;
        request.fields['description'] = _prodDescCtrl.text;
        request.fields['price'] = _prodPriceCtrl.text;
        request.fields['stock'] = _prodStockCtrl.text;
        request.fields['category'] = selectedCatId!;
        if (_selectedImageFile != null) {
          request.files.add(await http.MultipartFile.fromPath('image', _selectedImageFile!.path));
        }
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 201) {
          await _animationController.reverse();
          Navigator.pop(context, true);
        } else {
          String err;
          try {
            err = jsonDecode(response.body)['message'] ?? response.body;
          } catch (_) {
            err = response.body;
          }
          setState(() {
            error = err;
            _shakeError();
          });
        }
      }
    } catch (e) {
      setState(() {
        error = "Erreur réseau: $e";
        _shakeError();
      });
    } finally {
      setState(() { loading = false; });
    }
  }

  void _shakeError() {
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_bag, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Nouveau Produit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF2E5A88),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E5A88).withOpacity(0.1),
                  Color(0xFF2E5A88).withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // IMAGE PICKER
                    Center(
                      child: InkWell(
                        onTap: loading ? null : pickImage,
                        borderRadius: BorderRadius.circular(60),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Color(0xFF2E5A88).withOpacity(0.08),
                              backgroundImage: kIsWeb
                                  ? (_imageBytes != null
                                      ? MemoryImage(_imageBytes!)
                                      : null)
                                  : (_selectedImageFile != null
                                      ? FileImage(_selectedImageFile!)
                                      : null),
                              child: (_selectedImageX == null)
                                  ? Icon(Icons.add_a_photo,
                                      size: 38,
                                      color: Color(0xFF2E5A88).withOpacity(0.65))
                                  : null,
                            ),
                            if (_selectedImageX != null)
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.edit, color: Color(0xFF2E5A88), size: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        _selectedImageX == null
                            ? "Ajouter une image"
                            : "Image sélectionnée",
                        style: TextStyle(
                          color: Color(0xFF2E5A88),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 26),
                    _buildAnimatedInputField(
                      icon: Icons.label_important,
                      label: "Nom du produit",
                      controller: _prodNameCtrl,
                    ),
                    SizedBox(height: 20),
                    _buildAnimatedInputField(
                      icon: Icons.description_outlined,
                      label: "Description",
                      controller: _prodDescCtrl,
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnimatedInputField(
                            icon: Icons.attach_money,
                            label: "Prix",
                            controller: _prodPriceCtrl,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildAnimatedInputField(
                            icon: Icons.inventory_2,
                            label: "Stock",
                            controller: _prodStockCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildCategoryDropdown(),
                    SizedBox(height: 30),
                    if (error != null)
                      _buildErrorWidget(error!),
                    SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black54),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Color(0xFF2E5A88)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2E5A88), width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: selectedCatId,
          items: widget.categories.map<DropdownMenuItem<String>>((cat) => DropdownMenuItem(
            value: cat['_id'],
            child: Row(
              children: [
                Icon(Icons.category_outlined, color: Color(0xFF2E5A88)),
                SizedBox(width: 8),
                Text(cat['name']),
              ],
            ),
          )).toList(),
          onChanged: (val) => setState(() => selectedCatId = val),
          decoration: InputDecoration(
            labelText: "Catégorie",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.category, color: Color(0xFF2E5A88)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2E5A88), width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Container(
        key: ValueKey<String>(error),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFFDEDED),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE74C3C)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Color(0xFFE74C3C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Color(0xFF2E5A88),
            Color(0xFF4A90E2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E5A88).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: loading ? null : addProduct,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(Icons.add_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  loading ? "Ajout en cours..." : "Créer le produit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

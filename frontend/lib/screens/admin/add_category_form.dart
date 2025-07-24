import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AddCategoryFormPage extends StatefulWidget {
  @override
  State<AddCategoryFormPage> createState() => _AddCategoryFormPageState();
}

class _AddCategoryFormPageState extends State<AddCategoryFormPage> with SingleTickerProviderStateMixin {
  final _catCtrl = TextEditingController();
  final _catDescCtrl = TextEditingController();
  bool loading = false;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    _catCtrl.dispose();
    _catDescCtrl.dispose();
    super.dispose();
  }

  Future<void> addCategory() async {
    if (_catCtrl.text.isEmpty) {
      setState(() {
        error = "Le nom de la catégorie est requis";
      });
      return;
    }

    setState(() { 
      loading = true;
      error = null;
    });
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final res = await http.post(
        Uri.parse('http://localhost:5000/api/categories'),
        headers: {
          "Authorization": "Bearer ${auth.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "name": _catCtrl.text,
          "description": _catDescCtrl.text,
        })
      );
      
      if (res.statusCode == 201) {
        await _animationController.reverse();
        Navigator.pop(context, true);
      } else {
        setState(() { 
          error = jsonDecode(res.body)['message'] ?? "Erreur inconnue";
          _shakeError();
        });
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
            Icon(Icons.category, color: Colors.white),
            SizedBox(width: 10),
            Text('Nouvelle Catégorie', 
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF2E5A88), // Bleu professionnel
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
                    _buildAnimatedInputField(
                      icon: Icons.label_important_outline,
                      label: "Nom de la catégorie",
                      controller: _catCtrl,
                    ),
                    SizedBox(height: 20),
                    _buildAnimatedInputField(
                      icon: Icons.description_outlined,
                      label: "Description",
                      controller: _catDescCtrl,
                      maxLines: 3,
                    ),
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
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black54),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Color(0xFF2E5A88)), // Bleu professionnel
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2E5A88), width: 2), // Bleu professionnel
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
            Color(0xFF2E5A88), // Bleu professionnel foncé
            Color(0xFF4A90E2), // Bleu professionnel clair
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
          onTap: loading ? null : addCategory,
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
                  loading ? "Création en cours..." : "Créer la catégorie",
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:ui';

class RegisterScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'user';
  String error = "";
  String success = "";

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00B4D8), Color(0xFF90E0EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.network(
              "https://static.vecteezy.com/system/resources/thumbnails/054/970/775/small/tiny-shopping-cart-on-computer-keyboard-symbolizes-online-shopping-and-e-commerce-vibrant-background-adds-modern-touch-to-concept-photo.jpeg",
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.white.withOpacity(0.18),
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxWidth: 380),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00B4D8).withOpacity(0.14),
                            blurRadius: 36,
                            spreadRadius: 6,
                            offset: Offset(6, 18),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.19),
                          width: 1,
                        ),
                      ),
                      child: _formContent(context, authProvider),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF00B4D8), size: 28),
                onPressed: () => Navigator.pop(context),
                tooltip: "Retour",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formContent(BuildContext context, AuthProvider authProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFFC300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF9800).withOpacity(0.20),
                blurRadius: 22,
                offset: Offset(2, 10),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.shopping_cart_outlined, // ou Icons.shopping_bag_rounded si tu préfères le sac
              color: Colors.white,
              size: 36,
              shadows: [
                Shadow(
                  blurRadius: 12,
                  color: Color(0xFF00B4D8).withOpacity(0.20),
                  offset: Offset(2, 3),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 22),
        Text(
          "Créer un compte",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF023E8A),
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Inscription rapide et sécurisée",
          style: TextStyle(
            color: Color(0xFF0096C7),
            fontSize: 15,
          ),
        ),
        SizedBox(height: 24),
        _glassTextField(
          controller: usernameController,
          labelText: "Nom d'utilisateur",
          icon: Icons.person_outline,
          obscure: false,
        ),
        SizedBox(height: 14),
        _glassTextField(
          controller: passwordController,
          labelText: "Mot de passe",
          icon: Icons.lock_outline,
          obscure: true,
        ),
        SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.80),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00B4D8).withOpacity(0.07),
                offset: Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: DropdownButton<String>(
            value: role,
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF00B4D8)),
            underline: SizedBox(),
            borderRadius: BorderRadius.circular(14),
            style: TextStyle(color: Color(0xFF023E8A), fontSize: 16),
            items: ['user', 'admin']
                .map((r) => DropdownMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            r == 'admin' ? Icons.admin_panel_settings : Icons.person,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(r[0].toUpperCase() + r.substring(1)),
                        ],
                      ),
                      value: r,
                    ))
                .toList(),
            onChanged: (val) => setState(() => role = val ?? 'user'),
          ),
        ),
        SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              bool res = await authProvider.register(
                usernameController.text,
                passwordController.text,
                role,
              );
              if (res) {
                setState(() {
                  success = "Inscription réussie, connectez-vous !";
                  error = "";
                });
              } else {
                setState(() {
                  error = "Erreur d'inscription";
                  success = "";
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "S'inscrire",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00B4D8),
              foregroundColor: Colors.white,
              shadowColor: Color(0xFF0096C7),
              elevation: 7,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        if (success.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text(
              success,
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        if (error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
      ],
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00B4D8).withOpacity(0.07),
            offset: Offset(0, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Color(0xFF00B4D8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00B4D8), width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          fillColor: Colors.transparent,
          filled: true,
        ),
      ),
    );
  }
}

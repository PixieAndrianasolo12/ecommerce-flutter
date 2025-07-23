import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/register_screen.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String error = "";
  bool isLoading = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showError() {
    setState(() {
      error = "Identifiants invalides";
    });
    _shakeController.forward(from: 0);
  }

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
              color: Colors.white.withOpacity(0.20),
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
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  double shake = error.isNotEmpty
                      ? (8 * (1 - _shakeController.value) * ((_shakeController.value * 10) % 2 < 1 ? 1 : -1))
                      : 0;
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFFC300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF9800).withOpacity(0.21),
                blurRadius: 24,
                offset: Offset(2, 10),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.shopping_cart_rounded, // ou Icons.shopping_bag_rounded
              color: Colors.white,
              size: 38,
              shadows: [
                Shadow(
                  blurRadius: 14,
                  color: Color(0xFF00B4D8).withOpacity(0.22),
                  offset: Offset(2, 3),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 22),
        Text(
          "Connexion E-commerce",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF023E8A),
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Accédez à votre espace d'achat",
          style: TextStyle(
            color: Color(0xFF0096C7),
            fontSize: 15,
          ),
        ),
        SizedBox(height: 28),
        _glassTextField(
          controller: usernameController,
          labelText: "Nom d'utilisateur",
          icon: Icons.person_outline,
          obscure: false,
        ),
        SizedBox(height: 16),
        _glassTextField(
          controller: passwordController,
          labelText: "Mot de passe",
          icon: Icons.lock_outline,
          obscure: true,
        ),
        SizedBox(height: 28),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: CircularProgressIndicator(
                    color: Color(0xFF00B4D8),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    key: ValueKey("login_btn"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                      shadowColor: Color(0xFF0096C7),
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                        error = "";
                      });
                      bool success = await authProvider.login(
                        usernameController.text,
                        passwordController.text,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      } else {
                        showError();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Se connecter",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.1),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            icon: Icon(Icons.person_add_alt_1_rounded, color: Color(0xFFFF9800)),
            label: Text(
              "Créer un compte",
              style: TextStyle(fontSize: 16, color: Color(0xFFFF9800), fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFFFF9800), width: 1.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: Colors.white.withOpacity(0.92),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              );
            },
          ),
        ),
        if (error.isNotEmpty) ...[
          SizedBox(height: 16),
          AnimatedOpacity(
            opacity: error.isNotEmpty ? 1 : 0,
            duration: Duration(milliseconds: 350),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFFFFE5B4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

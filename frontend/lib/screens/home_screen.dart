import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      // Dégradé en fond, comme login/register
      body: Stack(
        children: [
          // Dégradé + image e-commerce en background
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
              "https://images.unsplash.com/photo-1542831371-d531d36971e6?auto=format&fit=crop&w=800&q=80",
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.12),
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.white.withOpacity(0.09)),
            ),
          ),
          // AppBar glassmorphism
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 18, left: 10, right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00B4D8).withOpacity(0.09),
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Icon(Icons.dashboard_rounded, color: Color(0xFF00B4D8), size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Accueil  ${auth.role == "admin" ? "(ADMIN)" : ""}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF023E8A),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Color(0xFFFF9800), size: 26),
                        tooltip: "Se déconnecter",
                        onPressed: () async {
                          await auth.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Contenu principal en glassmorphism card
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.74),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00B4D8).withOpacity(0.13),
                          blurRadius: 32,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFFC300)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF9800).withOpacity(0.16),
                                blurRadius: 18,
                                offset: Offset(2, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              auth.role == 'admin'
                                  ? Icons.verified_user_rounded
                                  : Icons.person_rounded,
                              color: Colors.white,
                              size: 40,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Color(0xFF00B4D8).withOpacity(0.16),
                                  offset: Offset(2, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          auth.role == 'admin'
                              ? 'Bienvenue ADMIN'
                              : 'Bienvenue UTILISATEUR',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF023E8A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nom : ${auth.username ?? ""}',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF0096C7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        if (auth.role == 'admin')
                          Card(
                            elevation: 0,
                            color: Colors.white.withOpacity(0.86),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.settings, color: Color(0xFF00B4D8), size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Espace administrateur",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF023E8A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (auth.role != 'admin')
                          Card(
                            elevation: 0,
                            color: Colors.white.withOpacity(0.86),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_bag, color: Color(0xFF00B4D8), size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Espace client",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF023E8A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
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
}

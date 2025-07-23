import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Dégradé + image e-commerce en background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF90E0EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1515169273891-1e2b235662de?auto=format&fit=crop&w=800&q=80",
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.14),
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
              child: Container(color: Colors.white.withOpacity(0.10)),
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
                    color: Colors.white.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1DB954).withOpacity(0.10),
                        blurRadius: 22,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Icon(Icons.admin_panel_settings, color: Color(0xFF1DB954), size: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF232F3E),
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
              constraints: BoxConstraints(maxWidth: 420),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                  child: Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.80),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1DB954).withOpacity(0.16),
                          blurRadius: 30,
                          offset: Offset(0, 10),
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
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF1DB954), Color(0xFF90E0EF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1DB954).withOpacity(0.18),
                                blurRadius: 18,
                                offset: Offset(2, 7),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 44,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Color(0xFF1DB954).withOpacity(0.18),
                                  offset: Offset(2, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Bienvenue ADMIN',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF232F3E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Nom : ${auth.username ?? ""}',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF1DB954),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: Colors.white.withOpacity(0.92),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.dashboard_customize, color: Color(0xFF1DB954), size: 22),
                                SizedBox(width: 10),
                                Text(
                                  "Espace administrateur",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF232F3E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.logout, color: Colors.white, size: 20),
                          label: Text("Déconnexion", style: TextStyle(fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1DB954),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await auth.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                              (route) => false,
                            );
                          },
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

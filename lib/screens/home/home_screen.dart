import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:gast_on_track/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  final List<Widget> _screens = [
    const PlaceholderWidget(title: 'Inicio'),
    const PlaceholderWidget(title: 'Ruleta'),
    const PlaceholderWidget(title: 'Escáner'),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Text(
          'Welcome!',
          style: TextStyle(
            color: AppTheme.darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppTheme.darkGreen),
          onPressed: () => _showCompactMenu(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: AppTheme.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: AppTheme.primaryGreen),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        showUnselectedLabels: true,
        elevation: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_carousel),
            label: 'Ruleta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Escanear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  void _showCompactMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          const Offset(16, kToolbarHeight),
          const Offset(16, kToolbarHeight + 40), 
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 20, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Configuración',
                style: TextStyle(color: AppTheme.darkGreen),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'password',
          child: Row(
            children: [
              Icon(Icons.lock, size: 20, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Cambiar contraseña',
                style: TextStyle(color: AppTheme.darkGreen),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Cerrar sesión',
                style: TextStyle(color: AppTheme.darkGreen),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'logout') {
        FirebaseAuth.instance.signOut();
      } else if (value == 'settings') {

      } else if (value == 'password') {

      }
    });
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;

  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: AppTheme.darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Contenido en desarrollo',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
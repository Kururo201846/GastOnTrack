import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gast_on_track/screens/roulette/roulette_screen.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:gast_on_track/screens/profile/profile_screen.dart';
import 'package:gast_on_track/cards/home_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  final List<Widget> _screens = [
    const HomeContent(),
    const RouletteScreen(),
    const PlaceholderWidget(title: 'Escáner'),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: _buildAppBar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Gast On Track',
        style: TextStyle(
          color: AppTheme.primaryBlue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppTheme.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: AppTheme.primaryBlue),
        onPressed: () => _showCompactMenu(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: AppTheme.primaryBlue),
          onPressed: () {},
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.white,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: AppTheme.textSecondary,
      selectedLabelStyle: TextStyle(color: AppTheme.primaryBlue),
      unselectedLabelStyle: TextStyle(color: AppTheme.textSecondary),
      showUnselectedLabels: true,
      elevation: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_carousel),
          label: 'Ruleta',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Escanear',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
      onTap: (index) => setState(() => _currentIndex = index),
    );
  }

  void _showCompactMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
        _buildPopupMenuItem(
          icon: Icons.settings,
          text: 'Configuración',
          value: 'settings',
        ),
        _buildPopupMenuItem(
          icon: Icons.lock,
          text: 'Cambiar contraseña',
          value: 'password',
        ),
        _buildPopupMenuItem(
          icon: Icons.logout,
          text: 'Cerrar sesión',
          value: 'logout',
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

  PopupMenuItem<String> _buildPopupMenuItem({
    required IconData icon,
    required String text,
    required String value,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String userName = 'Usuario';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final firstName = doc.data()?['firstName'] ?? 'Usuario';
          setState(() {
            userName = firstName;
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Usuario');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 24,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          _isLoading
              ? const CircularProgressIndicator()
              : Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
          
          const SizedBox(height: 30),
          const TotalExpensesCard(amount: 100000),
          const SizedBox(height: 20),
          const CategoriesCard(),
          const SizedBox(height: 20),
          ActionCard(
            icon: Icons.receipt,
            title: 'Historial De Boletas',
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          ActionCard(
            icon: Icons.edit_document,
            title: 'Registrar Boleta Manualmente',
            onPressed: () {},
          ),
        ],
      ),
    );
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
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Contenido en desarrollo',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
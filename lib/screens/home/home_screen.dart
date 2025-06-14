import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gast_on_track/screens/history/history_screen.dart';
import 'package:gast_on_track/screens/roulette/roulette_screen.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:gast_on_track/screens/profile/profile_screen.dart';
import 'package:gast_on_track/cards/home_cards.dart';
import 'package:gast_on_track/screens/scanner/scanner_screen.dart';
import 'package:gast_on_track/screens/manual/invoice_history_screen.dart';
import 'package:gast_on_track/screens/manual/manual_invoice_screen.dart';
import 'package:gast_on_track/screens/notifications/notification_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    const ScannerScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notification = message.notification!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification.title ?? ''}\n${notification.body ?? ''}'),
          ),
        );
      }
    });
  }

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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
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
      } else if (value == 'notifications') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationScreen(),
          ),
        );
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
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          final firstName = doc.data()?['firstName'] ?? 'Usuario';
          setState(() {
            userName = firstName;
          });
        }
      }
    } catch (e) {
      debugPrint('Usuario');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, double>> _getGastosPorCategoriaDelMes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {};

      final now = DateTime.now();
      final primerDiaMes = DateTime(now.year, now.month, 1);

      final query = await FirebaseFirestore.instance
          .collection('boletas')
          .where('uid', isEqualTo: user.uid)
          .where('fecha', isGreaterThanOrEqualTo: primerDiaMes)
          .get();

      final Map<String, double> acumulado = {};

      for (var doc in query.docs) {
        final data = doc.data();
        final categoria = _normalizarCategoria(data['categoria'] ?? 'otros');
        final productos = (data['productos'] is List)
            ? data['productos'] as List
            : [];

        for (var p in productos) {
          if (p is Map && p.containsKey('precio')) {
            final precio = double.tryParse(p['precio'].toString()) ?? 0.0;
            if (precio > 0) {
              acumulado[categoria] = (acumulado[categoria] ?? 0) + precio;
            }
          }
        }
      }
      return acumulado;
    } catch (e, st) {
      print('Error al obtener gastos por categoría: $e');
      print(st);
      return {};
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
                style: TextStyle(fontSize: 20, color: AppTheme.textPrimary),
              ),
          const SizedBox(height: 30),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('boletas')
                    .where(
                      'uid',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              double total = 0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final productos = data.containsKey('productos') && data['productos'] is List
                    ? data['productos'] as List<dynamic>
                    : [];
                for (var p in productos) {
                  total += double.tryParse(p['precio'].toString()) ?? 0;
                }
              }

              return TotalExpensesCard(
                amount: total,
                onHistoryPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, double>>(
            future: _getGastosPorCategoriaDelMes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final gastos = snapshot.data ?? {};
              if (gastos.isEmpty) {
                return CategoriesCard(
                  gastosPorCategoria: {},
                  totalMes: 0,
                );
              }
              return CategoriesCard(
                gastosPorCategoria: gastos,
                totalMes: gastos.values.fold(0.0, (a, b) => a + b),
              );
            },
          ),
          const SizedBox(height: 20),
          ActionCard(
            icon: Icons.receipt,
            title: 'Historial De Boletas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoiceHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ActionCard(
            icon: Icons.edit_document,
            title: 'Registrar Boleta Manualmente',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManualInvoiceScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _normalizarCategoria(String cat) {
  return cat
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();
}


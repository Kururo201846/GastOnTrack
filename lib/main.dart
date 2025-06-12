import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gast_on_track/firebaseoption/firebase_options.dart';
import 'package:gast_on_track/screens/auth/login_screen.dart';
import 'package:gast_on_track/screens/auth/create_user_screen.dart';
import 'package:gast_on_track/screens/auth/recover_password_screen.dart';
import 'package:gast_on_track/screens/history/history_screen.dart';
import 'package:gast_on_track/screens/home/home_screen.dart';
import 'package:gast_on_track/screens/profile/settings_screen.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MainApp(initialDarkMode: isDarkMode));
}

class MainApp extends StatefulWidget {
  final bool initialDarkMode;

  const MainApp({super.key, required this.initialDarkMode});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gast On Track',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthWrapper(isDarkMode: _isDarkMode, toggleTheme: _toggleTheme),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/recover_password': (context) => const RecoverPasswordScreen(),
        '/signup': (context) => const CreateUserScreen(),
        '/home':
            (context) =>
                HomeScreen(isDarkMode: _isDarkMode, toggleTheme: _toggleTheme),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const AuthWrapper({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        return HomeScreen(isDarkMode: isDarkMode, toggleTheme: toggleTheme);
      },
    );
  }
}

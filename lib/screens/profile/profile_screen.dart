import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gast_on_track/models/user_profile.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'profile_edit_screen.dart';
import 'graph_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfile?> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!snapshot.exists) return null;

    return UserProfile.fromMap(snapshot.data()!);
  }

  Future<void> _navigateToEditScreen(
    BuildContext context,
    UserProfile profile,
  ) async {
    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(profile: profile),
      ),
    );

    if (updatedProfile != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserProfile?>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No se pudo cargar el perfil."));
          }

          final profile = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryBlue,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profile.firstName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 16, color: AppTheme.white),
                  label: Text(
                    'Editar perfil',
                    style: TextStyle(color: AppTheme.white, fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                  onPressed: () => _navigateToEditScreen(context, profile),
                ),
                const SizedBox(height: 20),

                // BOTÓN DE GRÁFICAS
                ElevatedButton.icon(
                  icon: const Icon(Icons.bar_chart, color: AppTheme.white),
                  label: const Text(
                    'Gráficas',
                    style: TextStyle(color: AppTheme.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GraphScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: profile.email,
                ),
                const SizedBox(height: 15),
                _buildInfoCard(
                  icon: Icons.phone,
                  title: 'Contacto',
                  value: profile.phone,
                ),
                const SizedBox(height: 15),
                _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'País',
                  value: profile.country,
                ),
                const SizedBox(height: 15),
                _buildInfoCard(
                  icon: Icons.savings,
                  title: 'Total ahorrado',
                  value: '\$400,000 CLP',
                  isAmount: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isAmount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadows,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
                  color: isAmount ? AppTheme.primaryBlue : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


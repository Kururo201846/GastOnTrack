import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gast_on_track/models/user_profile.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No se pudo cargar el perfil."));
        }

        final profile = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Icon(Icons.person, size: 100, color: AppTheme.primaryBlue),
              const SizedBox(height: 20),
              _buildField('Nombre', profile.firstName),
              _buildField('Apellido', profile.lastName),
              _buildField('Correo', profile.email),
              _buildField('Teléfono', profile.phone),
              _buildField('País', profile.country),
              _buildField(
                'Fecha de registro',
                profile.createdAt?.toLocal().toString().split(' ').first ?? '-',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.primaryBlue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:gast_on_track/models/user_profile.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> countries = [
    'Argentina',
    'Brasil',
    'Chile',
    'Colombia',
    'México'
  ];
  String _selectedCountry = 'Chile';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Map<String, IconData> fieldIcons = {
    'firstName': Icons.person_outline,
    'lastName': Icons.person_outline,
    'phone': Icons.phone_outlined,
    'email': Icons.email_outlined,
    'country': Icons.location_on_outlined,
    'password': Icons.lock_outline,
  };

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = credential.user;
      if (user != null) {
        final userProfile = UserProfile(
          uid: user.uid,
          email: user.email!,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          country: _selectedCountry,
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userProfile.toMap());

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'El correo ya está registrado';
          break;
        case 'invalid-email':
          errorMessage = 'Correo electrónico no válido';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es muy débil (mínimo 6 caracteres)';
          break;
        default:
          errorMessage = 'Error al crear la cuenta: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'GastOnTrack',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/cerdito.png',
                  height: 140,
                  width: 140,
                ),
                const SizedBox(height: 40),

                _buildTextField(_firstNameController, 'Nombre', fieldName: 'firstName'),
                _buildTextField(_lastNameController, 'Apellido', fieldName: 'lastName'),
                _buildTextField(
                  _phoneController,
                  'Teléfono',
                  fieldName: 'phone',
                  keyboardType: TextInputType.phone,
                ),

                _buildCountryDropdown(),
                
                _buildTextField(
                  _emailController, 
                  'Email', 
                  fieldName: 'email', 
                  isEmail: true
                ),

                const SizedBox(height: 16),
                _buildPasswordField(
                  _passwordController,
                  'Password',
                  _obscurePassword,
                  () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  _confirmPasswordController,
                  'Confirmar Password',
                  _obscureConfirmPassword,
                  () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: 170,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppTheme.white,
                          )
                        : const Text('Crear Cuenta'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 170,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    required String fieldName,
    TextInputType keyboardType = TextInputType.text,
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(fieldIcons[fieldName], color: AppTheme.primaryBlue),
          border: const UnderlineInputBorder(),
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textSecondary),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
          if (isEmail &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Email inválido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedCountry,
        icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
        decoration: InputDecoration(
          prefixIcon: Icon(fieldIcons['country'], color: AppTheme.primaryBlue),
          border: const UnderlineInputBorder(),
          hintText: 'País',
          hintStyle: TextStyle(color: AppTheme.textSecondary),
        ),
        items: countries.map((String country) {
          return DropdownMenuItem<String>(
            value: country,
            child: Text(country),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCountry = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor selecciona un país';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(fieldIcons['password'], color: AppTheme.primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.primaryBlue,
          ),
          onPressed: toggle,
        ),
        border: const UnderlineInputBorder(),
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textSecondary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio';
        if (value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
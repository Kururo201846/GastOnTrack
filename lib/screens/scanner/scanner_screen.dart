import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Center(
            child: Text(
              'Vista previa de la cámara irá aquí',
              style: TextStyle(color: AppTheme.white),
            ),
          ),
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton(
                  color: AppTheme.textSecondary,
                  icon: Icons.close,
                  onPressed: () {},
                ),
  
                _buildCircleButton(
                  color: AppTheme.primaryBlue,
                  icon: Icons.check,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
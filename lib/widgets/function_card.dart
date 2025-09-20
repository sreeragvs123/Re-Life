import 'package:flutter/material.dart';

class FunctionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color; // optional color
  final Widget? badge; // optional badge widget

  const FunctionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color, 
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            color: color ?? Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 40, color: Colors.blue),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: 6,
              right: 6,
              child: badge!,
            ),
        ],
      ),
    );
  }
}

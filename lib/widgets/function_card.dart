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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SizedBox(
                width: 68,
                height: 68,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 24, color: Colors.blue),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                        // bodySmall replaces the old caption style
                      ),
                    ),
                  ],
                ),
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

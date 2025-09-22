import 'package:flutter/material.dart';

class FunctionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color; // optional color
  final Widget? badge;
  final double? textSize; // optional badge widget

  const FunctionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
    this.badge,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            color: color ?? Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19),
            ),
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 45, color: Colors.blue),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: textSize ?? 16, // use textSize if provided
                            ),
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

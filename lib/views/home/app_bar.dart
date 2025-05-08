import 'package:flutter/material.dart';

class ModernAppBar extends StatefulWidget {
  final String title;

  const ModernAppBar(BuildContext context, {Key? key, required this.title}) : super(key: key);

  @override
  _ModernAppBarState createState() => _ModernAppBarState();
}

class _ModernAppBarState extends State<ModernAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _logoColorAnimation;
  late Animation<Color?> _titleColorAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller with looping effect
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Repeat animation in reverse for pulsating effect

    // Animation for logo color (light effect)
    _logoColorAnimation = ColorTween(
      begin: Colors.black87,
      end: Colors.blueAccent.withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Animation for title color (light effect)
    _titleColorAnimation = ColorTween(
      begin: Colors.black87,
      end: Colors.blueAccent.withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.8,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo with animated color effect
          AnimatedBuilder(
            animation: _logoColorAnimation,
            builder: (context, child) {
              return Image.asset(
                'assets/logo.png', // 🔁 Ton logo local
                height: 28,
                color: _logoColorAnimation.value,
              );
            },
          ),
          const SizedBox(width: 10),
          // Title with animated color effect
          AnimatedBuilder(
            animation: _titleColorAnimation,
            builder: (context, child) {
              return Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  color: _titleColorAnimation.value,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              );
            },
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key, required this.isLoggedIn}) : super(key: key);

  final bool isLoggedIn;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _loadingController;
  late AnimationController _colorShiftController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _colorShiftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 4), () {
      widget.isLoggedIn
          ? Navigator.of(context).pushReplacementNamed('/colorDetect')
          : Navigator.of(context).pushReplacementNamed('/WelcomeScreen');
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    _colorShiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            ..._buildFloatingOrbs(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    "Colourhear",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Discover colors in your world",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildLoadingBar(),
                  const SizedBox(height: 8),
                  const Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.05).animate(_pulseController),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildRotatingRing(120, [
            Color(0xFFFF6B6B),
            Colors.transparent,
            Color(0xFF4ECDC4),
            Colors.transparent,
          ], 0),
          _buildRotatingRing(
            100,
            [
              Colors.transparent,
              Color(0xFF45B7D1),
              Colors.transparent,
              Color(0xFF96CEB4),
            ],
            -1,
            reverse: true,
          ),
          _buildRotatingRing(80, [
            Color(0xFFEEC757),
            Colors.transparent,
            Color(0xFFFF9FF3),
            Colors.transparent,
          ], -2),
          AnimatedBuilder(
            animation: _colorShiftController,
            builder: (_, __) {
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFF4ECDC4),
                      Color(0xFF45B7D1),
                      Color(0xFFEEC757),
                    ],
                    transform: GradientRotation(
                      _colorShiftController.value * pi,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingRing(
    double size,
    List<Color> colors,
    double delay, {
    bool reverse = false,
  }) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (_, __) {
        double rotationValue = _rotationController.value + (delay / 6);
        if (reverse) rotationValue = 1 - rotationValue;
        return Transform.rotate(
          angle: rotationValue * 2 * pi,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 4, color: Colors.transparent),
              gradient: SweepGradient(colors: colors),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBar() {
    return Container(
      width: 200,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: _loadingController,
        builder: (context, child) {
          return Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _loadingController.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFF4ECDC4),
                      Color(0xFF45B7D1),
                      Color(0xFFEEC757),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      _orb(60, const Offset(-0.60, -0.50), [
        Color(0xFFFF6B6B),
        Color(0xFFFF8E8E),
      ], 0),
      _orb(40, const Offset(0.8, 0), [
        Color(0xFF4ECDC4),
        Color(0xFF7ED6CC),
      ], -2),
      _orb(50, const Offset(-0.60, 0.30), [
        Color(0xFF45B7D1),
        Color(0xFF74C7E3),
      ], -4),
      _orb(35, const Offset(0.75, -0.65), [
        Color(0xFFEEC757),
        Color(0xFFFEE481),
      ], -1),
      _orb(45, const Offset(0.9, -0.2), [
        Color(0xFFFF9FF3),
        Color(0xFFFFB3F7),
      ], -3),
    ];
  }

  Widget _orb(double size, Offset alignment, List<Color> colors, int delay) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (_, __) {
          double animValue =
              sin((_rotationController.value + delay / 6) * 2 * pi) * 20;
          return Align(
            alignment: Alignment(alignment.dx, alignment.dy + animValue / 100),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: colors),
              ),
            ),
          );
        },
      ),
    );
  }
}

// [premium_loading_screen.dart] - PANTALLA DE CARGA EXTRAÍDA
// 📁 Ubicación: /lib/widgets/layout/components/premium_loading_screen.dart
// 🎯 WIDGET PANTALLA DE CARGA PREMIUM

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class PremiumLoadingScreen extends StatelessWidget {
  const PremiumLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kBrandPurple.withValues(alpha: 0.005),
              kAccentBlue.withValues(alpha: 0.002),
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PremiumLoadingLogo(),
              SizedBox(height: 32),
              Text(
                'Cargando Fisio Spa KYM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'CRM Premium Enterprise',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 48),
              PremiumProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumLoadingLogo extends StatefulWidget {
  const PremiumLoadingLogo({super.key});

  @override
  State<PremiumLoadingLogo> createState() => _PremiumLoadingLogoState();
}

class _PremiumLoadingLogoState extends State<PremiumLoadingLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _scaleController,
        _glowController,
      ]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    kBrandPurple,
                    kAccentBlue,
                    kAccentGreen,
                    kBrandPurple
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kBrandPurple.withOpacity(_glowAnimation.value * 0.8),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: kAccentBlue.withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 40,
                    spreadRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const Icon(Icons.spa, color: Colors.white, size: 50),
            ),
          ),
        );
      },
    );
  }
}

class PremiumProgressIndicator extends StatefulWidget {
  const PremiumProgressIndicator({super.key});

  @override
  State<PremiumProgressIndicator> createState() =>
      _PremiumProgressIndicatorState();
}

class _PremiumProgressIndicatorState extends State<PremiumProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kBrandPurple, kAccentBlue, kAccentGreen],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: kBrandPurple.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final percentage = (_progressAnimation.value * 100).toInt();
              return Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kBrandPurple,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
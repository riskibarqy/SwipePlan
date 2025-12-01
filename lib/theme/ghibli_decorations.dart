import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Decorative Retro-Ghibli inspired background used on the home experience.
class GhibliBackdrop extends StatelessWidget {
  const GhibliBackdrop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        fit: StackFit.expand,
        children: [const _BackdropElements(), if (child != null) child!],
      ),
    );
  }
}

class _BackdropElements extends StatelessWidget {
  const _BackdropElements();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(child: _HillLayer(heightFactor: 0.62, amplitude: 80)),
          Positioned.fill(
            child: _HillLayer(
              heightFactor: 0.7,
              amplitude: 110,
              color: Color(0xFFC9DECD),
            ),
          ),
          Positioned.fill(
            child: _HillLayer(
              heightFactor: 0.78,
              amplitude: 90,
              color: Color(0xFFB0C9B8),
            ),
          ),
          Positioned(top: 90, right: -40, child: _Sun()),
          Positioned(
            top: 80,
            left: 30,
            child: _Cloud(width: 180, height: 70, opacity: 0.32),
          ),
          Positioned(
            top: 160,
            left: 150,
            child: _Cloud(width: 130, height: 50, opacity: 0.2),
          ),
          Positioned(
            top: 220,
            right: 60,
            child: _Cloud(width: 120, height: 48, opacity: 0.22),
          ),
          Positioned(
            top: 140,
            right: 160,
            child: _Cloud(width: 90, height: 36, opacity: 0.15),
          ),
        ],
      ),
    );
  }
}

class _HillLayer extends StatelessWidget {
  const _HillLayer({
    this.color = const Color(0xFFDCEAD9),
    required this.heightFactor,
    required this.amplitude,
  });

  final Color color;
  final double heightFactor;
  final double amplitude;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 360,
        child: CustomPaint(
          painter: _HillPainter(
            color: color,
            heightFactor: heightFactor,
            amplitude: amplitude,
          ),
        ),
      ),
    );
  }
}

class _HillPainter extends CustomPainter {
  _HillPainter({
    required this.color,
    required this.heightFactor,
    required this.amplitude,
  });

  final Color color;
  final double heightFactor;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height * heightFactor)
          ..quadraticBezierTo(
            size.width * 0.2,
            size.height * (heightFactor - 0.1) - amplitude,
            size.width * 0.4,
            size.height * heightFactor - amplitude / 4,
          )
          ..quadraticBezierTo(
            size.width * 0.7,
            size.height * (heightFactor + 0.04) + amplitude / 2,
            size.width,
            size.height * heightFactor,
          )
          ..lineTo(size.width, size.height)
          ..close();

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HillPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.heightFactor != heightFactor ||
        oldDelegate.amplitude != amplitude;
  }
}

class _Sun extends StatelessWidget {
  const _Sun();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFF4C7), Color(0xFFF5C682)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.35),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.width, required this.height, this.opacity = 0.2});

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CloudClipper(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: AppGradients.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: opacity * 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path =
        Path()
          ..moveTo(0, size.height)
          ..quadraticBezierTo(
            0,
            size.height * 0.4,
            size.width * 0.2,
            size.height * 0.45,
          )
          ..quadraticBezierTo(
            size.width * 0.35,
            size.height * 0.1,
            size.width * 0.55,
            size.height * 0.35,
          )
          ..quadraticBezierTo(
            size.width * 0.75,
            size.height * 0.05,
            size.width * 0.85,
            size.height * 0.4,
          )
          ..quadraticBezierTo(
            size.width,
            size.height * 0.45,
            size.width,
            size.height,
          )
          ..close();
    return path;
  }

  @override
  bool shouldReclip(_CloudClipper oldClipper) => false;
}

/// Soft glass layer used to mimic hazy highlights.
class AuroraGlass extends StatelessWidget {
  const AuroraGlass({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

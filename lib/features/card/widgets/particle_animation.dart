import 'dart:math';
import 'package:creatoo/resources/color.dart';
import 'package:flutter/material.dart';

class ParticleAnimation extends StatefulWidget {
  const ParticleAnimation({super.key});

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _createParticles(Size size) {
    if (_particles.isNotEmpty) return;
    int numberOfParticles = 50;
    for (int i = 0; i < numberOfParticles; i++) {
      _particles.add(_Particle(size, _random));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _createParticles(size);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            for (var particle in _particles) {
              particle.move();
              if (particle.isOutOfBounds(size)) {
                particle.reset(size);
              }
            }
            return CustomPaint(
              size: size,
              painter: _ParticlePainter(_particles),
            );
          },
        );
      },
    );
  }
}

class _Particle {
  late double x, y, size, speed, angle;
  late Color color;
  final Random _random;

  _Particle(Size area, this._random) {
    reset(area);
  }

  void reset(Size area) {
    x = _random.nextDouble() * area.width;
    y = _random.nextDouble() * area.height;
    size = _random.nextDouble() * 2.0 + 1.0;
    color = AppColor.white.withOpacity(_random.nextDouble() * 0.3 + 0.1);
    speed = _random.nextDouble() * 0.5 + 0.2;
    angle = _random.nextDouble() * 2 * pi;
  }

  void move() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
  }

  bool isOutOfBounds(Size area) {
    return x < 0 || x > area.width || y < 0 || y > area.height;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Paint _paint = Paint();

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      _paint.color = particle.color;
      _paint.style = PaintingStyle.fill;

      final path = Path();
      double outerRadius = particle.size * 1.5;
      double innerRadius = particle.size * 0.75;
      int points = 5;
      double angle = pi / points;

      path.moveTo(
        particle.x + outerRadius * cos(-pi / 2),
        particle.y + outerRadius * sin(-pi / 2),
      );

      for (int i = 1; i <= 2 * points; i++) {
        double radius = i.isEven ? outerRadius : innerRadius;
        double currentAngle = angle * i - (pi / 2);
        path.lineTo(
          particle.x + radius * cos(currentAngle),
          particle.y + radius * sin(currentAngle),
        );
      }
      path.close();
      canvas.drawPath(path, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

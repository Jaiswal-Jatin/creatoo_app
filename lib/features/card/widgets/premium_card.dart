import 'dart:ui';
import 'dart:math';
import 'package:creatoo/resources/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:creatoo/features/card/widgets/activate_card.dart'; // Import ActivateCardModal

// App Colors - Same as your original
// class AppColor {
//   static const Color white = Colors.white;
//   static const Color black = Colors.black;
//   static const Color transparent = Colors.transparent;
//   static const List<Color> premiumCardGradient = [
//     Color(0xFF1a1a2e),
//     Color(0xFF16213e),
//     Color(0xFF0f3460),
//   ];
// }

class PremiumGlassCard extends StatefulWidget {
  final String? initialUserName;
  final String? initialCardNumber;
  final bool initialIsCardActive;

  const PremiumGlassCard({
    super.key,
    this.initialUserName,
    this.initialCardNumber,
    this.initialIsCardActive = false,
  });

  @override
  State<PremiumGlassCard> createState() => _PremiumGlassCardState();
}

class _PremiumGlassCardState extends State<PremiumGlassCard>
    with SingleTickerProviderStateMixin {
  bool _isCardCodeVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // State variables for card data
  bool _isCardActive = false;
  String? _userName;
  String? _cardNumber;

  @override
  void initState() {
    super.initState();
    _isCardActive = widget.initialIsCardActive;
    _userName = widget.initialUserName;
    _cardNumber = widget.initialCardNumber;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant PremiumGlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsCardActive != oldWidget.initialIsCardActive ||
        widget.initialUserName != oldWidget.initialUserName ||
        widget.initialCardNumber != oldWidget.initialCardNumber) {
      setState(() {
        _isCardActive = widget.initialIsCardActive;
        _userName = widget.initialUserName;
        _cardNumber = widget.initialCardNumber;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCardCodeVisibility() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCardCodeVisible = !_isCardCodeVisible;
      if (_isCardCodeVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 220,
      width: screenWidth * 0.9,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: AppColor.premiumCardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF0f3460).withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Particle Animation Background
            const ParticleAnimation(),

            // Glassmorphism Effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColor.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Shimmer Effect Overlay
            // Positioned.fill(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(24),
            //       gradient: LinearGradient(
            //         begin: Alignment.topLeft,
            //         end: Alignment.bottomRight,
            //         colors: [
            //           AppColor.white.withOpacity(0.1),
            //           AppColor.transparent,
            //           AppColor.white.withOpacity(0.05),
            //         ],
            //         stops: const [0.0, 0.5, 1.0],
            //       ),
            //     ),
            //   ),
            // ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row - Brand Name & Verified Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColor.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.credit_card_rounded,
                              color: AppColor.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "CREATOO",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColor.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.greenAccent,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Card Number Section
                  if (_isCardActive &&
                      _cardNumber != null &&
                      _cardNumber!.isNotEmpty) ...[
                    // Show/Hide Card Number with Animation
                    Center(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              if (_isCardCodeVisible)
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColor.white.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        _cardNumber!,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.white,
                                          letterSpacing: 4,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  "•••• •••• •••• ••••",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.white.withOpacity(0.7),
                                    letterSpacing: 3,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // Inactive Card - Masked Number
                    Center(
                      child: Text(
                        "•••• •••• •••• ••••",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColor.white.withOpacity(0.7),
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Bottom Row - User Name & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // User Name Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CARD HOLDER",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColor.white.withOpacity(0.5),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userName?.toUpperCase() ?? "YOUR NAME",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColor.white.withOpacity(0.95),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),

                      // Action Button
                      if (_isCardActive)
                        _buildTapToViewButton()
                      else
                        _buildActivateButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tap to View Card Code Button
  Widget _buildTapToViewButton() {
    return GestureDetector(
      onTap: _toggleCardCodeVisibility,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isCardCodeVisible
              ? AppColor.white.withOpacity(0.25)
              : AppColor.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColor.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCardCodeVisible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColor.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _isCardCodeVisible ? "Hide Code" : "View Code",
              style: const TextStyle(
                color: AppColor.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Activate Button for inactive card
  Widget _buildActivateButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showActivateCardModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_rounded,
              color: Color(0xFF1a1a2e),
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              "Activate",
              style: TextStyle(
                color: Color(0xFF1a1a2e),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivateCardModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColor.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: AppColor.black.withOpacity(0.5), // Full-screen translucent background
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: const QRScannerScreen(),
            ),
          ),
        );
      },
    );
  }
}

// Particle Animation Widget
class ParticleAnimation extends StatefulWidget {
  const ParticleAnimation({super.key});

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Generate particles
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speedX: (_random.nextDouble() - 0.5) * 0.02,
        speedY: (_random.nextDouble() - 0.5) * 0.02,
        opacity: _random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update particle positions
        for (var particle in _particles) {
          particle.x += particle.speedX;
          particle.y += particle.speedY;

          if (particle.x < 0 || particle.x > 1) particle.speedX *= -1;
          if (particle.y < 0 || particle.y > 1) particle.speedY *= -1;
        }

        return CustomPaint(
          painter: ParticlePainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// // Example Usage Widget
// class CardExample extends StatelessWidget {
//   const CardExample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0a0a0f),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Active Card with hidden code initially
//             const PremiumGlassCard(
//               userName: "John Doe",
//               cardNumber: "1234 5678 9012",
//               isCardActive: true,
//             ),
//             const SizedBox(height: 20),
//             // Inactive Card
//             const PremiumGlassCard(
//               userName: "Jane Smith",
//               isCardActive: false,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

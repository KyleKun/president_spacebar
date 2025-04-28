import 'package:flutter/material.dart';
import '../game/president_spacebar_game.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuOverlay extends StatelessWidget {
  final PresidentSpacebarGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Define a consistent color palette
    final primaryColor = const Color(0xFF1A237E); // Deep indigo
    final accentColor = const Color(0xFFD32F2F); // Patriotic red
    final buttonColor = const Color(0xFF43A047); // Green for start
    final secondaryButtonColor = const Color(0xFFE65100); // Orange for secondary

    return Material(
      child: Container(
        decoration: BoxDecoration(
          // More polished gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              const Color(0xFF283593), // Mid indigo
              const Color(0xFF1565C0), // Deep blue
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Stars background effect (subtle patriotic theme)
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [Colors.white.withAlpha(30), Colors.white.withAlpha(5)],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  decoration: BoxDecoration(
                    // Use a gradient fallback instead of the stars image
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade900.withAlpha(50),
                        Colors.indigo.shade900.withAlpha(30),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),

                    // Title with improved styling
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor.withAlpha(230), accentColor.withAlpha(170)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                        border: Border.all(color: Colors.white.withAlpha(50), width: 1.5),
                      ),
                      child: Text(
                        'PRESIDENT SPACEBAR',
                        style: GoogleFonts.orbitron(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                          height: 1.2,
                          shadows: [
                            Shadow(color: Colors.black.withAlpha(200), blurRadius: 4, offset: const Offset(2, 2)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Logo image with improved container
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: 260,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(40), width: 1),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/debate.png',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Icon(Icons.space_bar, size: 100, color: Colors.white.withAlpha(200)),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Button container with glass effect
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: Column(
                        children: [
                          // Play button with improved styling
                          SizedBox(
                            width: 250,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                game.playClickSound();
                                game.overlays.remove('MenuOverlay');
                                game.playIntro();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'START GAME',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Credits button with improved styling
                          SizedBox(
                            width: 250,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                game.openCredits();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryButtonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 3,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.stars, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CREDITS',
                                    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),

            // Help button with improved styling
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(200),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(60), width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 4)],
                ),
                child: IconButton(
                  onPressed: () => game.openControls(),
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  tooltip: 'Controls',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

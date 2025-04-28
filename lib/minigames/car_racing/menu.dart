import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:president_spacebar/game/game_colors.dart';
import 'package:president_spacebar/minigames/car_racing/racing_game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

class Menu extends StatelessWidget {
  const Menu(this.game, {super.key});

  final RacingGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade800.withAlpha(200), Colors.indigo.shade900.withAlpha(200)],
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: min(500, MediaQuery.of(context).size.width * 0.9),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(210),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Game title with racing-themed styling
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade700, Colors.red.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      'Car Racing',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(color: Colors.black.withAlpha(150), blurRadius: 4, offset: const Offset(2, 2)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Game description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Text(
                          'First to 3 laps wins!',
                          style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          RacingGame.description,
                          style: GoogleFonts.raleway(fontSize: 16, height: 1.4, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Single player button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 1);
                      },
                      child: Text(
                        'Start Race',
                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Controls info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100.withAlpha(180),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.keyboard, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Controls: Arrow Keys',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

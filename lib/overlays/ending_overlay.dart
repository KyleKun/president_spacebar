import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:president_spacebar/game/president_spacebar_game.dart';

class EndingOverlay extends StatefulWidget {
  final PresidentSpacebarGame game;
  const EndingOverlay({super.key, required this.game});

  @override
  State<EndingOverlay> createState() => _EndingOverlayState();
}

class _EndingOverlayState extends State<EndingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late String _endingText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    
    // Stop any previous music
    FlameAudio.bgm.stop();
    
    // Determine ending based on approval rating and play appropriate sound
    final approval = widget.game.gameState.approval;
    final won = approval >= 50;
    
    if (won) {
      widget.game.playPositiveSound();
    } else {
      widget.game.playNegativeSound();
    }

    if (won) {
      if (approval >= 80) {
        _endingText =
            'LANDSLIDE VICTORY! President Spacebar wins with an overwhelming ${approval.toStringAsFixed(0)}% approval rating! Your campaign will go down in keyboard history as one of the most successful ever, with both Key A and Key E fully supporting your presidency.';
      } else if (approval >= 65) {
        _endingText =
            'SOLID VICTORY! President Spacebar secures a solid win with ${approval.toStringAsFixed(0)}% approval! Your balanced approach and strategic campaigning have earned you the respect of the keyboard community.';
      } else {
        _endingText =
            'NARROW VICTORY! President Spacebar squeaks by with ${approval.toStringAsFixed(0)}% approval. It was a close election, but your perseverance paid off in the end!';
      }
    } else {
      if (approval <= 30) {
        _endingText =
            'CRUSHING DEFEAT! With only ${approval.toStringAsFixed(0)}% approval, President Enter wins by a landslide. Your campaign failed to connect with key voters, and both Key A and Key E publicly supported your opponent.';
      } else {
        _endingText =
            'NARROW DEFEAT! With ${approval.toStringAsFixed(0)}% approval, you narrowly lose to President Enter. So close, yet so far - perhaps with a few different decisions, the outcome might have been different.';
      }
    }

    _controller.forward();
    // Play victory/defeat audio (placeholder)
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approval = widget.game.gameState.approval;
    final won = approval >= 50;

    // Choose background colors based on victory or defeat
    final gradientColors =
        won ? [Colors.blue.shade900, Colors.indigo.shade900] : [Colors.red.shade900, Colors.brown.shade900];

    final accentColor = won ? Colors.blue.shade500 : Colors.red.shade500;

    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
            stops: const [0.3, 0.9],
          ),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Winner announcement
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 8)],
                          border: Border.all(color: accentColor.withAlpha(150), width: 2),
                        ),
                        child: Column(
                          children: [
                            // Victory or Defeat banner
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(200),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                won ? 'VICTORY' : 'DEFEAT',
                                style: GoogleFonts.montserrat(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Approval rating display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Final Approval:',
                                  style: GoogleFonts.raleway(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color:
                                        won ? Colors.green.shade600.withAlpha(200) : Colors.red.shade600.withAlpha(200),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${approval.toStringAsFixed(0)}%',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Ending text description
                            Text(
                              _endingText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(fontSize: 18, height: 1.5, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Back to main menu button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.game.overlays.remove('EndingOverlay');
                          widget.game.gameState.approval = 50; // Reset state
                          widget.game.gameState.completedMinigames.clear();
                          widget.game.gameState.minigameResults.clear();
                          widget.game.overlays.add('MenuOverlay'); // Back to menu
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          'Return to Main Menu',
                          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

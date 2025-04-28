import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:president_spacebar/minigames/car_racing/racing_game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

class GameOver extends StatelessWidget {
  const GameOver(this.game, {super.key, this.onFinish});

  final RacingGame game;
  final Function(bool didWin)? onFinish;

  @override
  Widget build(BuildContext context) {
    // Determine winner name and color
    final bool playerWon = game.winner?.isPlayer ?? false;
    final String winnerName = playerWon ? 'You Win!' : 'CPU Wins!';
    final Color winnerColor = playerWon ? Colors.green.shade700 : Colors.red.shade700;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(220),
            winnerColor.withAlpha(180),
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy icon for visual appeal
                  Icon(
                    Icons.emoji_events,
                    size: 70,
                    color: winnerColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // Winner announcement
                  Text(
                    winnerName,
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: winnerColor,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Race details
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(
                              'Time: ${game.timePassed}',
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${playerWon ? 'Congratulations!' : 'Better luck next time!'}',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Restart button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        // If a callback is provided, call it with the result
                        if (onFinish != null) {
                          onFinish!(playerWon);
                        }
                        // Reset the game state
                        game.reset();
                      },
                      child: Text(
                        'Race Again',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

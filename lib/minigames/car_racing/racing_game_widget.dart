import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';
import 'package:president_spacebar/minigames/car_racing/game_over.dart';
import 'package:president_spacebar/minigames/car_racing/menu.dart';
import 'package:president_spacebar/minigames/car_racing/racing_game.dart';

// Widget to be used from MinigameOverlay
class RacingGameWidget extends StatelessWidget {
  final Function(bool didWin) onGameOver;
  
  const RacingGameWidget({super.key, required this.onGameOver});

  @override
  Widget build(BuildContext context) {
    // Create a racing game instance
    final racingGame = RacingGame();
    
    return GameWidget<RacingGame>(
      game: racingGame,
      loadingBuilder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.indigo.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinner animation
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 5,
              ),
              const SizedBox(height: 24),
              // Loading text with custom font
              Text(
                'Loading Race...',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      overlayBuilderMap: {
        'menu': (_, game) => Menu(game),
        'game_over': (_, game) => GameOver(
          game,
          onFinish: (didWin) {
            // Call the callback with the game result
            onGameOver(didWin);
          },
        ),
      },
      initialActiveOverlays: const ['menu'],
    );
  }
}

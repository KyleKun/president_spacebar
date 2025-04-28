import 'package:flutter/material.dart';
import '../game/president_spacebar_game.dart';
import '../minigames/hurdles/hurdles_game_widget.dart';
import '../minigames/car_racing/racing_game_widget.dart';

class MinigameOverlay extends StatelessWidget {
  final PresidentSpacebarGame game;
  const MinigameOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final minigameName = game.currentMinigame ?? 'Unknown';

    // Check which minigame to launch
    if (minigameName.toLowerCase() == 'hurdles') {
      // Launch the hurdles game
      return HurdlesGameWidget(
        onGameOver: (didWin) {
          // When the game is over, call the finishMinigame method with the result
          game.finishMinigame(didWin);
        },
      );
    } else if (minigameName.toLowerCase() == 'car_racing') {
      // Launch the car racing game
      return RacingGameWidget(
        onGameOver: (didWin) {
          game.finishMinigame(didWin);
        },
      );
    }

    // Fallback for other minigames not yet implemented
    return Material(
      color: Colors.black.withAlpha(127), // Using withAlpha instead of withOpacity as per user preference
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Minigame: ${minigameName.replaceAll('_', ' ').toUpperCase()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('This minigame is not yet implemented!'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => game.finishMinigame(true), // Simulate win
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Win'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => game.finishMinigame(false), // Simulate loss
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Lose'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

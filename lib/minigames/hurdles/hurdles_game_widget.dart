import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'hurdles_game.dart';

// This widget will be pushed onto the Navigator stack
class HurdlesGameWidget extends StatefulWidget {
  // Callback function to be executed when the game ends
  final Function(bool didWin) onGameOver;

  const HurdlesGameWidget({super.key, required this.onGameOver});

  @override
  State<HurdlesGameWidget> createState() => _HurdlesGameWidgetState();
}

class _HurdlesGameWidgetState extends State<HurdlesGameWidget> {
  late HurdlesGame _game;

  @override
  void initState() {
    super.initState();
    _game = HurdlesGame(widget.onGameOver);

    // Show the goal popup after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGoalPopup();
    });
  }

  void _showGoalPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hurdles Challenge'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Jump over the hurdles and reach 1000 points to win!', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Press SPACE or tap the screen to jump.', style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              Text(
                'If you score less than 1000 points, you lose the minigame.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('START'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        // Use the game instance created in initState
        game: _game,
        loadingBuilder: (_) => const Center(child: Text('Loading Hurdles...')),
        // Define overlays if your game needs them (e.g., pause menu)
        // overlayBuilderMap: { ... },
      ),
    );
  }
}

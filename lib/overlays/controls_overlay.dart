import 'package:flutter/material.dart';
import '../game/president_spacebar_game.dart';

class ControlsOverlay extends StatelessWidget {
  final PresidentSpacebarGame game;
  const ControlsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Controls', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            const Text('Tap or click to select options.'),
            const SizedBox(height: 12),
            const Text('Press spacebar to jump.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.playClickSound();
                game.overlays.remove('ControlsOverlay');
                game.overlays.add('MenuOverlay');
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

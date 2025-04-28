import 'package:flutter/material.dart';
import '../game/president_spacebar_game.dart';

class CreditsOverlay extends StatelessWidget {
  final PresidentSpacebarGame game;
  const CreditsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Credits', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 12),
              const Text(
                'Programming, Music, Story and Design:\nCaio Pedroso (KyleKun)\n',
                textAlign: TextAlign.center,
              ),
              const Text('Sfx: Freesound.org', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  game.playClickSound();
                  game.overlays.remove('CreditsOverlay');
                  game.overlays.add('MenuOverlay');
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

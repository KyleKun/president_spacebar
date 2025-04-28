import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../game/president_spacebar_game.dart';

class CutsceneOverlay extends StatefulWidget {
  final PresidentSpacebarGame game;
  const CutsceneOverlay({super.key, required this.game});

  @override
  State<CutsceneOverlay> createState() => _CutsceneOverlayState();
}

class _CutsceneOverlayState extends State<CutsceneOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _textIndex = 0;
  final List<String> _texts = [
    'Once every 4 years, there is a very important event for all keyboards around the world...',
    'Yes, just like humans have their presidential race, so does the keyboard nation...',
    'And you, the mighty Spacebar, announced your candidacy for the highest office!',
    'With promises of making the keyboard nation a better place, you must prove your worth!',
    'You will face debates, challenges, and try to get the support of iconic keys to succeed!',
    'Can you beat your arch rival, the Enter key, and become the ruler all keys will adore?',
    'Good luck, Space! This is the race of your life!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 3600), vsync: this);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Fade out current text and fade in the next one
        Future.delayed(const Duration(milliseconds: 1550), () {
          if (mounted) {
            setState(() {
              _textIndex++;

              if (_textIndex >= _texts.length) {
                // Cutscene complete, return to the game
                // Stop intro music and restart menu music
                FlameAudio.bgm.stop();
                FlameAudio.bgm.play('mainmenu.mp3');

                widget.game.overlays.remove('CutsceneOverlay');
                widget.game.overlays.add('HQOverlay');
              } else {
                // Reset the animation to fade in the next text
                _controller.reset();
                _controller.forward();
              }
            });
          }
        });
      }
    });
    _controller.forward();
    // Play intro audio (placeholder)
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_textIndex >= _texts.length) {
      return const SizedBox.shrink(); // Scene ended
    }
    return Material(
      color: Colors.black.withAlpha(220), // Dark overlay
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            _texts[_textIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

// Corrected relative imports
import 'background/horizon.dart';
import 'game_over.dart'; // Assuming GameOverDisplay is defined here or imported
import 'player.dart';
// import 'hurdle/hurdle_manager.dart'; // Temporarily commented out

enum GameState { playing, intro, gameOver }

class HurdlesGame extends FlameGame with KeyboardEvents, TapCallbacks, HasCollisionDetection {
  // Callback to execute when game ends (win/loss)
  final Function(bool didWin) onGameOver;

  static const String description = '''
    A game similar to the game in chrome that you get to play while offline.
    Press space or tap/click the screen to jump, the more obstacles you manage
    to survive, the more points you get.
  ''';

  late final Image spriteImage;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  late final player = Player();
  late final horizon = Horizon();
  late final gameOverDisplay = GameOverDisplay(onGameOver: onGameOver);
  late final TextComponent scoreText;

  int _score = 0;
  int _highScore = 0;
  int get score => _score;
  set score(int newScore) {
    _score = newScore;
    scoreText.text = '${scoreString(_score)}  HI ${scoreString(_highScore)}';
  }

  String scoreString(int score) => score.toString().padLeft(5, '0');

  /// Used for score calculation
  double _distanceTraveled = 0;

  @override
  Future<void> onLoad() async {
    spriteImage = await Flame.images.load('trex.png');
    add(horizon);
    add(player);
    add(gameOverDisplay);

    const chars = '0123456789HI ';
    final renderer = SpriteFontRenderer.fromFont(
      SpriteFont(
        source: spriteImage,
        size: 23,
        ascent: 23,
        glyphs: [for (var i = 0; i < chars.length; i++) Glyph(chars[i], left: 954.0 + 20 * i, top: 0, width: 20)],
      ),
      letterSpacing: 2,
    );
    add(scoreText = TextComponent(position: Vector2(20, 20), textRenderer: renderer));
    score = 0;
  }

  GameState state = GameState.intro;
  double currentSpeed = 0.0;
  double timePlaying = 0.0;

  final double acceleration = 10;
  final double maxSpeed = 2500.0;
  final double startSpeed = 600;

  HurdlesGame(this.onGameOver);

  bool get isPlaying => state == GameState.playing;
  bool get isGameOver => state == GameState.gameOver;
  bool get isIntro => state == GameState.intro;

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.enter) || keysPressed.contains(LogicalKeyboardKey.space)) {
      onAction();
    }
    return KeyEventResult.handled;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onAction();
  }

  void onAction() {
    if (isGameOver || isIntro) {
      restart();
      return;
    }
    player.jump(currentSpeed);
  }

  void gameOver() {
    // Set the game over display to visible
    gameOverDisplay.visible = true;
    // Update game state
    state = GameState.gameOver;
    player.current = PlayerState.crashed;
    currentSpeed = 0.0;
    
    // Check win status based on score (1000 or greater to win)
    gameOverDisplay.checkWinStatus();
  }

  void restart() {
    state = GameState.playing;
    player.reset();
    horizon.reset();
    currentSpeed = startSpeed;
    gameOverDisplay.visible = false;
    timePlaying = 0.0;
    if (score > _highScore) {
      _highScore = score;
    }
    score = 0;
    _distanceTraveled = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }

    if (isPlaying) {
      timePlaying += dt;
      _distanceTraveled += dt * currentSpeed;
      score = _distanceTraveled ~/ 50;

      if (currentSpeed < maxSpeed) {
        currentSpeed += acceleration * dt;
      }
    }
  }
}

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' hide Image;
import 'hurdles_game.dart';

class GameOverDisplay extends Component with HasGameReference<HurdlesGame> {
  final Function(bool didWin) onGameOver; // Callback

  bool visible = false;
  bool win = false;

  late final GameOverText _text;
  late final GameOverRestart _restartButton;

  // Accept the callback
  GameOverDisplay({required this.onGameOver});

  @override
  Future<void> onLoad() async {
    _text = GameOverText();
    // Pass the callback down to the button
    _restartButton = GameOverRestart(onGameOver: onGameOver);
    add(_text);
    add(_restartButton);
  }
  
  // Check if player won based on score
  void checkWinStatus() {
    // Win if score is 1000 or greater
    win = game.score >= 1000;
  }

  @override
  void renderTree(Canvas canvas) {
    if (visible) {
      // Check win status based on score before rendering
      checkWinStatus();
      _text.updateWinStatus(win);
      super.renderTree(canvas);
    }
  }
}

class GameOverText extends TextComponent with HasGameReference<HurdlesGame> {
  bool _isWin = false;

  GameOverText() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Initialize with default text
    text = 'GAME OVER';
    textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  void updateWinStatus(bool didWin) {
    if (_isWin == didWin) return;
    _isWin = didWin;
    
    // Update text based on win status
    text = _isWin ? 'YOU WIN! Score: ${game.score}' : 'GAME OVER! Score: ${game.score}';
    
    // Update text color based on win status
    final textColor = _isWin ? Colors.green : Colors.red;
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    x = size.x / 2;
    y = size.y * 0.25;
  }
}

class GameOverRestart extends SpriteComponent with HasGameReference<HurdlesGame>, TapCallbacks {
  // Store the callback
  final Function(bool didWin) onGameOver;

  GameOverRestart({required this.onGameOver}) : super(size: Vector2(72, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.spriteImage, srcPosition: Vector2.all(2.0), srcSize: size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    x = size.x / 2;
    y = size.y * 0.75;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Get the win status from the parent display component
    final result = (parent as GameOverDisplay).win;
    // Call the callback function, which should trigger Navigator.pop
    onGameOver(result);
  }
}

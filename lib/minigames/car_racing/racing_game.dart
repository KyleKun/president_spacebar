import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:president_spacebar/minigames/car_racing/car.dart';
import 'package:president_spacebar/minigames/car_racing/lap_line.dart';
import 'package:president_spacebar/minigames/car_racing/lap_text.dart';
import 'package:president_spacebar/minigames/car_racing/wall.dart';

final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> playersKeys = [
  {
    LogicalKeyboardKey.arrowUp: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight: LogicalKeyboardKey.arrowRight,
  },
  {
    LogicalKeyboardKey.keyW: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyS: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyA: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyD: LogicalKeyboardKey.arrowRight,
  },
];

class RacingGame extends Forge2DGame with KeyboardEvents {
  static const String description = '''
     Race around the track and try to beat the CPU opponent!
     Finish 3 laps before the opponent to win.
     Use arrow keys to control your car.
  ''';

  RacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  @override
  Color backgroundColor() => Colors.black;

  static final Vector2 trackSize = Vector2.all(500);
  static const double playZoom = 8.0;
  static const int numberOfLaps = 3;
  late CameraComponent startCamera;
  late List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late List<Set<LogicalKeyboardKey>> pressedKeySets;
  bool isGameOver = false;
  List<Car> cars = [];
  Car? winner;
  double _timePassed = 0;

  // Define lap line vectors
  static final lapLineEnd = Vector2(70, 0);
  static final lapLineStart = Vector2(-70, 0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    camera.removeFromParent();
    children.register<CameraComponent>();

    final walls = createWalls(trackSize);

    // Track center
    final trackCenter = Vector2(trackSize.x / 2, trackSize.y / 2);

    // Create lap lines for square track - position close to start position (top-left corner)
    // Starting line at the top-left corner near car starting point
    final finishLine = LapLine(
      1,
      Vector2(trackCenter.x - 120, trackCenter.y - 120), // Position at top-left of track near cars
      Vector2(40, 5), // Horizontal line
      isFinish: true,
    );

    // Checkpoint at the top-right corner
    final checkpoint1 = LapLine(
      2,
      Vector2(trackCenter.x + 120, trackCenter.y - 120), // Position at top-right corner
      Vector2(5, 40), // Vertical line
      isFinish: false,
    );

    // Checkpoint at the bottom-right corner
    final checkpoint2 = LapLine(
      3,
      Vector2(trackCenter.x + 120, trackCenter.y + 120), // Position at bottom-right corner
      Vector2(40, 5), // Horizontal line
      isFinish: false,
    );

    // Checkpoint at the bottom-left corner
    final checkpoint3 = LapLine(
      4,
      Vector2(trackCenter.x - 120, trackCenter.y + 120), // Position at bottom-left corner
      Vector2(5, 40), // Vertical line
      isFinish: false,
    );

    world.addAll([finishLine, checkpoint1, checkpoint2, checkpoint3, ...walls]);

    openMenu();
  }

  void openMenu() {
    overlays.add('menu');
    final zoomLevel = min(canvasSize.x / trackSize.x, canvasSize.y / trackSize.y);
    startCamera =
        CameraComponent(world: world)
          ..viewfinder.position = trackSize / 2
          ..viewfinder.anchor = Anchor.center
          ..viewfinder.zoom = zoomLevel - 0.2;
    add(startCamera);
  }

  void prepareStart({required int numberOfPlayers}) {
    startCamera.viewfinder
      ..add(
        ScaleEffect.to(
          Vector2.all(playZoom),
          EffectController(duration: 1.0),
          onComplete: () => start(numberOfPlayers: numberOfPlayers),
        ),
      )
      ..add(MoveEffect.to(Vector2.all(20), EffectController(duration: 1.0)));
  }

  // Define track parameters as class members to reuse them
  Vector2 get trackCenter => Vector2(trackSize.x / 2, trackSize.y / 2);
  double get trackRadius => 150.0; // Middle of the racing lane

  void start({int numberOfPlayers = 1}) {
    // Always use single player mode with CPU opponent
    isGameOver = false;
    overlays.remove('menu');
    startCamera.removeFromParent();

    // Create a single full-screen viewport for the player
    final viewportSize = Vector2(canvasSize.x, canvasSize.y);

    // Create player camera
    final playerCamera =
        CameraComponent(world: world, viewport: FixedSizeViewport(viewportSize.x, viewportSize.y))
          ..viewfinder.anchor = Anchor.center
          ..viewfinder.zoom = playZoom;

    // Removed minimap as requested

    // Add cameras to game
    add(playerCamera);

    // Create player car (green)
    final playerCar = Car(
      playerNumber: 0, // Player is always 0
      cameraComponent: playerCamera,
      isPlayer: true,
    );

    // Create CPU opponent car (red)
    final cpuCar = Car(
      playerNumber: 1, // CPU is always 1
      cameraComponent: playerCamera,
      isPlayer: false,
    );

    // Add lap text for player
    final playerLapText = LapText(car: playerCar, position: Vector2(120, 50))..add(
      TextComponent(
        text: 'Player: ',
        position: Vector2(-60, 0),
        anchor: Anchor.centerLeft,
        textRenderer: TextPaint(style: const TextStyle(color: Colors.green, fontSize: 16)),
      ),
    );

    // Add lap text for CPU
    final cpuLapText = LapText(car: cpuCar, position: Vector2(120, 100))..add(
      TextComponent(
        text: 'CPU: ',
        position: Vector2(-60, 0),
        anchor: Anchor.centerLeft,
        textRenderer: TextPaint(style: const TextStyle(color: Colors.red, fontSize: 16)),
      ),
    );

    // Set up lap completion listeners
    playerCar.lapNotifier.addListener(() {
      if (playerCar.lapNotifier.value > numberOfLaps) {
        isGameOver = true;
        winner = playerCar;
        overlays.add('game_over');
        playerLapText.addAll([
          ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.2, alternate: true, repeatCount: 3)),
          RotateEffect.by(pi * 2, EffectController(duration: 0.5)),
        ]);
      } else {
        playerLapText.add(ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.2, alternate: true)));
      }
    });

    cpuCar.lapNotifier.addListener(() {
      if (cpuCar.lapNotifier.value > numberOfLaps) {
        isGameOver = true;
        winner = cpuCar;
        overlays.add('game_over');
        cpuLapText.addAll([
          ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.2, alternate: true, repeatCount: 3)),
          RotateEffect.by(pi * 2, EffectController(duration: 0.5)),
        ]);
      } else {
        cpuLapText.add(ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.2, alternate: true)));
      }
    });

    // Add cars to the game
    cars.add(playerCar);
    cars.add(cpuCar);
    world.add(playerCar);
    world.add(cpuCar);

    // Add UI elements to viewport
    playerCamera.viewport.addAll([playerLapText, cpuLapText]);

    // Set up keyboard controls for player
    pressedKeySets = [{}]; // Only one set for the player
    activeKeyMaps = [playersKeys[0]]; // Only use first control scheme
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    _timePassed += dt;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    if (!isLoaded || isGameOver) {
      return KeyEventResult.ignored;
    }

    _clearPressedKeys();
    for (final key in keysPressed) {
      activeKeyMaps.forEachIndexed((i, keyMap) {
        if (keyMap.containsKey(key)) {
          pressedKeySets[i].add(keyMap[key]!);
        }
      });
    }
    return KeyEventResult.handled;
  }

  void _clearPressedKeys() {
    for (final pressedKeySet in pressedKeySets) {
      pressedKeySet.clear();
    }
  }

  void reset() {
    _clearPressedKeys();
    activeKeyMaps.clear();
    _timePassed = 0;
    overlays.remove('game_over');
    openMenu();
    for (final car in cars) {
      car.removeFromParent();
    }
    for (final camera in children.query<CameraComponent>()) {
      camera.removeFromParent();
    }
  }

  String _maybePrefixZero(int number) {
    if (number < 10) {
      return '0$number';
    }
    return number.toString();
  }

  String get timePassed {
    final minutes = _maybePrefixZero((_timePassed / 60).floor());
    final seconds = _maybePrefixZero((_timePassed % 60).floor());
    final ms = _maybePrefixZero(((_timePassed % 1) * 100).floor());
    return [minutes, seconds, ms].join(':');
  }
}

import 'package:flame/components.dart';
import 'package:president_spacebar/minigames/hurdles/hurdle/hurdle_type.dart';
import 'package:president_spacebar/minigames/hurdles/hurdles_game.dart';
import 'package:president_spacebar/minigames/hurdles/random_extension.dart';

class Obstacle extends SpriteComponent with HasGameReference<HurdlesGame> {
  Obstacle({required this.settings, required this.groupIndex}) : super(size: settings.size);

  final double _gapCoefficient = 0.6;
  final double _maxGapCoefficient = 1.5;

  bool followingObstacleCreated = false;
  late double gap;
  final ObstacleTypeSettings settings;
  final int groupIndex;

  bool get isVisible => (x + width) > 0;

  @override
  Future<void> onLoad() async {
    sprite = settings.sprite(game.spriteImage);
    x = game.size.x + width * groupIndex;
    y = settings.y;
    gap = computeGap(_gapCoefficient, game.currentSpeed);
    addAll(settings.generateHitboxes());
  }

  double computeGap(double gapCoefficient, double speed) {
    final minGap = (width * speed * settings.minGap * gapCoefficient).roundToDouble();
    final maxGap = (minGap * _maxGapCoefficient).roundToDouble();
    return random.fromRange(minGap, maxGap);
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= game.currentSpeed * dt;

    if (!isVisible) {
      removeFromParent();
    }
  }
}

import 'package:flame/components.dart';
import 'package:president_spacebar/minigames/hurdles/background/cloud.dart';
import 'package:president_spacebar/minigames/hurdles/hurdles_game.dart';
import 'package:president_spacebar/minigames/hurdles/random_extension.dart';

class CloudManager extends PositionComponent with HasGameReference<HurdlesGame> {
  final double cloudFrequency = 0.5;
  final int maxClouds = 20;
  final double bgCloudSpeed = 0.2;

  void addCloud() {
    final cloudPosition = Vector2(
      game.size.x + Cloud.initialSize.x + 10,
      ((absolutePosition.y / 2 - (Cloud.maxSkyLevel - Cloud.minSkyLevel)) +
              random.fromRange(Cloud.minSkyLevel, Cloud.maxSkyLevel)) -
          absolutePosition.y,
    );
    add(Cloud(position: cloudPosition));
  }

  double get cloudSpeed => bgCloudSpeed / 1000 * game.currentSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    final numClouds = children.length;
    if (numClouds > 0) {
      final lastCloud = children.last as Cloud;
      if (numClouds < maxClouds && (game.size.x / 2 - lastCloud.x) > lastCloud.cloudGap) {
        addCloud();
      }
    } else {
      addCloud();
    }
  }

  void reset() {
    removeAll(children);
  }
}

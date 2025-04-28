import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:president_spacebar/minigames/car_racing/racing_game.dart';

List<Wall> createWalls(Vector2 size) {
  // Track creation simplified - removed unused boundary variables
  
  // Create a square track
  final trackCenter = Vector2(size.x / 2, size.y / 2);
  
  // Square track dimensions
  final outerSize = 300.0; // Size of outer square
  final innerSize = 150.0; // Size of inner square
  final halfOuterSize = outerSize / 2;
  final halfInnerSize = innerSize / 2;
  
  // Calculate the corners of the track (inner and outer square)
  final outerTopLeft = Vector2(trackCenter.x - halfOuterSize, trackCenter.y - halfOuterSize);
  final outerTopRight = Vector2(trackCenter.x + halfOuterSize, trackCenter.y - halfOuterSize);
  final outerBottomLeft = Vector2(trackCenter.x - halfOuterSize, trackCenter.y + halfOuterSize);
  // outerBottomRight is not needed but calculated for completeness

  final innerTopLeft = Vector2(trackCenter.x - halfInnerSize, trackCenter.y - halfInnerSize);
  final innerTopRight = Vector2(trackCenter.x + halfInnerSize, trackCenter.y - halfInnerSize);
  final innerBottomLeft = Vector2(trackCenter.x - halfInnerSize, trackCenter.y + halfInnerSize);
  // innerBottomRight is not needed but calculated for completeness

  final walls = <Wall>[
    // Boundary walls removed as requested

    
    // Outer square walls
    // Top wall
    Wall(
      Vector2(trackCenter.x, outerTopLeft.y),
      Vector2(outerSize, 5)
    ),
    // Right wall
    Wall(
      Vector2(outerTopRight.x, trackCenter.y),
      Vector2(5, outerSize)
    ),
    // Bottom wall
    Wall(
      Vector2(trackCenter.x, outerBottomLeft.y),
      Vector2(outerSize, 5)
    ),
    // Left wall
    Wall(
      Vector2(outerTopLeft.x, trackCenter.y),
      Vector2(5, outerSize)
    ),
    
    // Inner square walls
    // Top wall
    Wall(
      Vector2(trackCenter.x, innerTopLeft.y),
      Vector2(innerSize, 5)
    ),
    // Right wall
    Wall(
      Vector2(innerTopRight.x, trackCenter.y),
      Vector2(5, innerSize)
    ),
    // Bottom wall
    Wall(
      Vector2(trackCenter.x, innerBottomLeft.y),
      Vector2(innerSize, 5)
    ),
    // Left wall
    Wall(
      Vector2(innerTopLeft.x, trackCenter.y),
      Vector2(5, innerSize)
    ),
  ];
  
  return walls;
}

class Wall extends BodyComponent<RacingGame> {
  Wall(this._position, this.size, {this.angle = 0.0}) : super(priority: 3);

  final Vector2 _position;
  final Vector2 size;
  final double angle; // Rotation angle for the wall

  final Random rng = Random();
  late final Image _image;

  final scale = 10.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _scaledRect = (size * scale).toRect();
  late final _renderRect = _renderPosition & size.toSize();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    paint.color = ColorExtension.fromRGBHexString('#14F596');

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final drawSize = _scaledRect.size.toVector2();
    final center = (drawSize / 2).toOffset();
    const step = 1.0;

    canvas.drawRect(Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y), BasicPalette.black.paint());
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = step;
    for (var x = 0; x < 30; x++) {
      canvas.drawRect(Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y), paint);
      paint.color = paint.color.darken(0.07);
      drawSize.x -= step;
      drawSize.y -= step;
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(_scaledRect.width.toInt(), _scaledRect.height.toInt());
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(_image, _scaledRect, _renderRect, paint);
  }

  @override
  Body createBody() {
    final def =
        BodyDef()
          ..type = BodyType.static
          ..position = _position
          ..angle = angle; // Apply rotation angle
    final body =
        world.createBody(def)
          ..userData = this
          ..angularDamping = 3.0;

    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape)..restitution = 0.5;
    return body..createFixture(fixtureDef);
  }

  late Rect asRect = Rect.fromCenter(center: _position.toOffset(), width: size.x, height: size.y);
}

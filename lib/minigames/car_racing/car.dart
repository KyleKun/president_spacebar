import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:president_spacebar/minigames/car_racing/lap_line.dart';
import 'package:president_spacebar/minigames/car_racing/racing_game.dart';
import 'package:president_spacebar/minigames/car_racing/tire.dart';

class Car extends BodyComponent<RacingGame> {
  Car({
    required this.playerNumber, 
    required this.cameraComponent, 
    this.isPlayer = true
  }) : super(priority: 3, paint: Paint()..color = isPlayer ? Colors.green : Colors.red);

  // Different colors for player (green) and CPU (red)
  final bool isPlayer; // Whether this car is controlled by the player

  late final List<Tire> tires;
  final ValueNotifier<int> lapNotifier = ValueNotifier<int>(1);
  final int playerNumber;
  final Set<LapLine> passedStartControl = {};
  final CameraComponent cameraComponent;
  late final Image _image;
  final size = const Size(6, 10);
  final scale = 10.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _scaledRect = (size * scale).toRect();
  late final _renderRect = _renderPosition & size;

  final vertices = <Vector2>[
    Vector2(1.5, -5.0),
    Vector2(3.0, -2.5),
    Vector2(2.8, 0.5),
    Vector2(1.0, 5.0),
    Vector2(-1.0, 5.0),
    Vector2(-2.8, 0.5),
    Vector2(-3.0, -2.5),
    Vector2(-1.5, -5.0),
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final path = Path();
    final bodyPaint = Paint()..color = paint.color;
    for (var i = 0.0; i < _scaledRect.width / 4; i++) {
      bodyPaint.color = bodyPaint.color.darken(0.1);
      path.reset();
      final offsetVertices =
          vertices
              .map((v) => v.toOffset() * scale - Offset(i * v.x.sign, i * v.y.sign) + _scaledRect.bottomRight / 2)
              .toList();
      path.addPolygon(offsetVertices, true);
      canvas.drawPath(path, bodyPaint);
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(_scaledRect.width.toInt(), _scaledRect.height.toInt());
  }

  @override
  Body createBody() {
    // Position both cars properly on the square track
    final trackCenter = Vector2(250, 250);
    
    // For square track, start cars at top-left corner
    // Player car starts slightly ahead of CPU car
    final startPosition = Vector2(
      trackCenter.x - 120, // Left side of track, near outer wall
      trackCenter.y - 120  // Top side of track, near outer wall
    );
    
    // Offset CPU car slightly behind player
    if (!isPlayer) {
      startPosition.add(Vector2(15, 15));
    }
    
    // Face right along the top edge of the track
    final startAngle = 0.0; // 0 degrees = facing right
    
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = startPosition
      ..angle = startAngle;
      
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = PolygonShape()..set(vertices);
    final fixtureDef =
        FixtureDef(shape)
          ..density = 0.2
          ..restitution = 2.0;
    body.createFixture(fixtureDef);

    final jointDef =
        RevoluteJointDef()
          ..bodyA = body
          ..enableLimit = true
          ..lowerAngle = 0.0
          ..upperAngle = 0.0
          ..localAnchorB.setZero();

    tires = List.generate(4, (i) {
      final isFrontTire = i <= 1;
      final isLeftTire = i.isEven;
      return Tire(
        car: this,
        // Always use pressedKeySets[0] for player, empty set for CPU
        pressedKeys: isPlayer ? game.pressedKeySets[0] : {},
        isFrontTire: isFrontTire,
        isLeftTire: isLeftTire,
        jointDef: jointDef,
        isTurnableTire: isFrontTire,
      );
    });

    game.world.addAll(tires);
    return body;
  }

  // Get track center from main game to ensure consistency
  Vector2 get trackCenter => Vector2(250, 250);
  
  // Track parameters for square path
  double get trackSize => 225.0; // Distance from center to follow (between inner and outer walls)
  
  // Current waypoint for CPU car (1-4)
  int _currentWaypoint = 1;
  // Distance threshold to consider a waypoint reached
  final double _waypointThreshold = 30.0;
  
  @override
  void update(double dt) {
    // Update camera position for player car
    if (isPlayer) {
      cameraComponent.viewfinder.position = body.position;
    }
    
    // Handle tire controls for player car
    if (isPlayer) {
      // Let tire physics handle movement via key presses
      // The pressedKeySets already contains the keyboard input
    }
    // CPU car movement logic
    else if (!game.isGameOver) {
      // Following a square track in clockwise order: right->down->left->up
      
      // Distance from center to follow
      final pathOffset = 120.0; // Use direct value for path offset
      
      // Define the four corners of the square path as waypoints
      final List<Vector2> waypoints = [
        Vector2(trackCenter.x - pathOffset, trackCenter.y - pathOffset), // Top-left (Start)
        Vector2(trackCenter.x + pathOffset, trackCenter.y - pathOffset), // Top-right
        Vector2(trackCenter.x + pathOffset, trackCenter.y + pathOffset), // Bottom-right
        Vector2(trackCenter.x - pathOffset, trackCenter.y + pathOffset), // Bottom-left
      ];
      
      // Define the angles to face at each waypoint segment
      final List<double> waypointAngles = [
        0.0,      // Top-left to Top-right: face right
        pi/2,     // Top-right to Bottom-right: face down
        pi,       // Bottom-right to Bottom-left: face left
        3*pi/2,   // Bottom-left to Top-left: face up
      ];
      
      // Get current target waypoint
      final currentTarget = waypoints[_currentWaypoint % 4];
      
      // Calculate distance to current waypoint
      final distanceToWaypoint = body.position.distanceTo(currentTarget);
      
      // Check if we've reached the waypoint
      if (distanceToWaypoint < _waypointThreshold) {
        // Move to next waypoint
        _currentWaypoint = (_currentWaypoint + 1) % 4;
      }
      
      // Target the next waypoint
      final targetPoint = waypoints[_currentWaypoint % 4];
      
      // Set angle based on which segment we're on
      final targetAngle = waypointAngles[_currentWaypoint % 4];
      
      // Calculate direction to target
      final direction = targetPoint - body.position;
      
      // Apply a gentler force toward target point - slowed down to give player a better chance
      body.applyLinearImpulse(direction.normalized() * 50.0); // Reduced force for easier gameplay
      
      // Keep car properly oriented for the current segment
      final angleDiff = targetAngle - body.angle;
      
      // Normalize angle difference to [-π, π]
      final normalizedDiff = (angleDiff + pi) % (2 * pi) - pi;
      
      // Apply reduced torque to align with direction
      body.applyAngularImpulse(normalizedDiff * 1.2); // Reduced torque for slower turning
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(_image, _scaledRect, _renderRect, paint);
  }

  @override
  void onRemove() {
    for (final tire in tires) {
      tire.removeFromParent();
    }
  }
}

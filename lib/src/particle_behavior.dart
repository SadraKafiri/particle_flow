import 'package:flutter/widgets.dart';

/// Defines where particles can spawn from.
enum ParticleSpawnOrigin {
  /// Anywhere inside the widget area.
  full,

  /// From above the top edge, moving downward (snow, rain).
  top,

  /// From below the bottom edge, moving upward.
  bottom,

  /// From the left edge, moving right.
  left,

  /// From the right edge, moving left.
  right,

  /// Randomly from left or right edges.
  sides,
}

/// Configuration for spawning particles.
class ParticleSpawnConfig {
  const ParticleSpawnConfig({
    this.origin = ParticleSpawnOrigin.top,
    this.customArea,
    this.spawnPadding = EdgeInsets.zero,
  });

  /// Where particles initially appear.
  final ParticleSpawnOrigin origin;

  /// Optional custom spawn rectangle within the widget.
  ///
  /// If provided, this overrides the default full-size area.
  /// Can be used to restrict particles to left/right/center etc.
  final Rect? customArea;

  /// Extra padding around the spawn area.
  ///
  /// Useful when you want particles to start slightly outside the visible
  /// area and move in.
  final EdgeInsets spawnPadding;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticleSpawnConfig &&
        other.origin == origin &&
        other.customArea == customArea &&
        other.spawnPadding == spawnPadding;
  }

  @override
  int get hashCode => Object.hash(origin, customArea, spawnPadding);
}

/// Behavior configuration: motion, lifetime, opacity, scale.
///
/// You can either use the named constructors like [ParticleBehavior.snow]
/// or create a custom configuration.
class ParticleBehavior {
  const ParticleBehavior({
    this.minSpeed = 10.0,
    this.maxSpeed = 30.0,
    this.minHorizontalSpeed = -10.0,
    this.maxHorizontalSpeed = 10.0,
    this.gravity = 8.0,
    this.horizontalDriftAmplitude = 14.0,
    this.horizontalDriftFrequency = 0.6,
    this.minScale = 0.7,
    this.maxScale = 1.3,
    this.minOpacity = 0.4,
    this.maxOpacity = 1.0,
    this.minLifetime = const Duration(seconds: 12),
    this.maxLifetime = const Duration(seconds: 22),
    this.fadeInFraction = 0.18,
    this.fadeOutFraction = 0.32,
    this.rotationSpeed = 0.28,
  }) : assert(minSpeed >= 0),
       assert(maxSpeed >= minSpeed),
       assert(minHorizontalSpeed <= maxHorizontalSpeed),
       assert(minScale > 0),
       assert(maxScale >= minScale),
       assert(minOpacity >= 0 && minOpacity <= 1),
       assert(maxOpacity >= minOpacity && maxOpacity <= 1),
       assert(fadeInFraction >= 0 && fadeInFraction <= 1),
       assert(fadeOutFraction >= 0 && fadeOutFraction <= 1);

  /// Minimum initial vertical speed (pixels/sec).
  final double minSpeed;

  /// Maximum initial vertical speed (pixels/sec).
  final double maxSpeed;

  /// Minimum initial horizontal speed (pixels/sec).
  final double minHorizontalSpeed;

  /// Maximum initial horizontal speed (pixels/sec).
  final double maxHorizontalSpeed;

  /// Vertical acceleration (pixels/sec^2).
  ///
  /// Positive values push particles downward (gravity).
  final double gravity;

  /// Horizontal drift amplitude in pixels (for sine-based wobble).
  final double horizontalDriftAmplitude;

  /// Horizontal drift frequency (cycles per second).
  final double horizontalDriftFrequency;

  /// Min visual scale factor.
  final double minScale;

  /// Max visual scale factor.
  final double maxScale;

  /// Minimum base opacity.
  final double minOpacity;

  /// Maximum base opacity.
  final double maxOpacity;

  /// Minimum lifetime of a particle.
  final Duration minLifetime;

  /// Maximum lifetime of a particle.
  final Duration maxLifetime;

  /// Fraction of lifetime used for fade-in from 0 to full opacity.
  final double fadeInFraction;

  /// Fraction of lifetime used for fade-out to 0 opacity.
  final double fadeOutFraction;

  /// Base rotation speed in radians per second.
  final double rotationSpeed;

  /// Simple copy-with helper for customization from examples.
  ParticleBehavior copyWith({
    double? minSpeed,
    double? maxSpeed,
    double? minHorizontalSpeed,
    double? maxHorizontalSpeed,
    double? gravity,
    double? horizontalDriftAmplitude,
    double? horizontalDriftFrequency,
    double? minScale,
    double? maxScale,
    double? minOpacity,
    double? maxOpacity,
    Duration? minLifetime,
    Duration? maxLifetime,
    double? fadeInFraction,
    double? fadeOutFraction,
    double? rotationSpeed,
  }) {
    return ParticleBehavior(
      minSpeed: minSpeed ?? this.minSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      minHorizontalSpeed: minHorizontalSpeed ?? this.minHorizontalSpeed,
      maxHorizontalSpeed: maxHorizontalSpeed ?? this.maxHorizontalSpeed,
      gravity: gravity ?? this.gravity,
      horizontalDriftAmplitude:
          horizontalDriftAmplitude ?? this.horizontalDriftAmplitude,
      horizontalDriftFrequency:
          horizontalDriftFrequency ?? this.horizontalDriftFrequency,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      minOpacity: minOpacity ?? this.minOpacity,
      maxOpacity: maxOpacity ?? this.maxOpacity,
      minLifetime: minLifetime ?? this.minLifetime,
      maxLifetime: maxLifetime ?? this.maxLifetime,
      fadeInFraction: fadeInFraction ?? this.fadeInFraction,
      fadeOutFraction: fadeOutFraction ?? this.fadeOutFraction,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
    );
  }

  /// Preset tuned for “soft snow” style motion.
  ///
  /// These defaults are intentionally **slow and gentle**, so even if
  /// the user just calls `ParticleFlow.emoji` without custom behavior,
  /// the result looks like calm snow, not a storm.
  const ParticleBehavior.snow({
    double minSpeed = 6,
    double maxSpeed = 18,
    double minHorizontalSpeed = -8,
    double maxHorizontalSpeed = 8,
    double gravity = 6,
    double horizontalDriftAmplitude = 18,
    double horizontalDriftFrequency = 0.55,
    double minScale = 0.7,
    double maxScale = 1.3,
    double minOpacity = 0.4,
    double maxOpacity = 0.9,
    Duration minLifetime = const Duration(seconds: 14),
    Duration maxLifetime = const Duration(seconds: 26),
    double fadeInFraction = 0.18,
    double fadeOutFraction = 0.32,
    double rotationSpeed = 0.25,
  }) : this(
         minSpeed: minSpeed,
         maxSpeed: maxSpeed,
         minHorizontalSpeed: minHorizontalSpeed,
         maxHorizontalSpeed: maxHorizontalSpeed,
         gravity: gravity,
         horizontalDriftAmplitude: horizontalDriftAmplitude,
         horizontalDriftFrequency: horizontalDriftFrequency,
         minScale: minScale,
         maxScale: maxScale,
         minOpacity: minOpacity,
         maxOpacity: maxOpacity,
         minLifetime: minLifetime,
         maxLifetime: maxLifetime,
         fadeInFraction: fadeInFraction,
         fadeOutFraction: fadeOutFraction,
         rotationSpeed: rotationSpeed,
       );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ParticleBehavior) return false;
    return other.minSpeed == minSpeed &&
        other.maxSpeed == maxSpeed &&
        other.minHorizontalSpeed == minHorizontalSpeed &&
        other.maxHorizontalSpeed == maxHorizontalSpeed &&
        other.gravity == gravity &&
        other.horizontalDriftAmplitude == horizontalDriftAmplitude &&
        other.horizontalDriftFrequency == horizontalDriftFrequency &&
        other.minScale == minScale &&
        other.maxScale == maxScale &&
        other.minOpacity == minOpacity &&
        other.maxOpacity == maxOpacity &&
        other.minLifetime == minLifetime &&
        other.maxLifetime == maxLifetime &&
        other.fadeInFraction == fadeInFraction &&
        other.fadeOutFraction == fadeOutFraction &&
        other.rotationSpeed == rotationSpeed;
  }

  @override
  int get hashCode => Object.hash(
    minSpeed,
    maxSpeed,
    minHorizontalSpeed,
    maxHorizontalSpeed,
    gravity,
    horizontalDriftAmplitude,
    horizontalDriftFrequency,
    minScale,
    maxScale,
    minOpacity,
    maxOpacity,
    minLifetime,
    maxLifetime,
    fadeInFraction,
    fadeOutFraction,
    rotationSpeed,
  );
}

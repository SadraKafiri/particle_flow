// lib/particle_flow/particle_model.dart
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Internal mutable particle model.
///
/// Instances are reused and updated every frame to avoid allocations
/// and reduce GC pressure.
class Particle {
  Particle({
    required this.position,
    required this.velocity,
    required this.scale,
    required this.opacity,
    required this.baseOpacity,
    required this.rotation,
    required this.age,
    required this.lifetime,
    required this.driftPhase,
    required this.driftFrequency,
    required this.driftAmplitude,
  });

  /// Current position in logical pixels.
  Offset position;

  /// Current velocity in logical pixels / second.
  Offset velocity;

  /// Visual scale factor (multiplies base size).
  double scale;

  /// Current visual opacity in [0, 1].
  double opacity;

  /// Base opacity for this particle (random between min/max).
  final double baseOpacity;

  /// Rotation angle in radians.
  double rotation;

  /// Current age in seconds.
  double age;

  /// Total lifetime in seconds.
  final double lifetime;

  /// Phase offset for horizontal drift.
  final double driftPhase;

  /// Frequency (cycles per second) for horizontal drift.
  final double driftFrequency;

  /// Amplitude in logical pixels for horizontal drift.
  final double driftAmplitude;

  /// Normalized lifetime progress in [0, 1].
  double get progress => lifetime <= 0 ? 0 : (age / lifetime).clamp(0.0, 1.0);
}

/// Signature for canvas-based particle painting.
///
/// The [particle] instance is mutable and reused. Do **not** modify it here.
typedef ParticleCanvasPainter =
    void Function(Canvas canvas, Size size, Particle particle);

/// Signature for widget-based particles.
///
/// The [particle] instance is mutable and reused. Treat it as read-only.
typedef ParticleWidgetBuilder =
    Widget Function(BuildContext context, Particle particle);

/// Helper to choose a stable random index for a particle based on its driftPhase.
///
/// This is useful when you want each particle to pick one of several
/// appearances and keep it stable across frames.
int stableIndexForParticle(Particle p, int length) {
  if (length <= 1) return 0;
  const twoPi = math.pi * 2;
  final normalized = ((p.driftPhase % twoPi) / twoPi).clamp(0.0, 1.0);
  var idx = (normalized * length).floor();
  if (idx < 0) idx = 0;
  if (idx >= length) idx = length - 1;
  return idx;
}

/// Helper wrapper to randomly choose between multiple widget builders,
/// keeping the selection stable per-particle.
///
/// This allows mixing multiple widget styles within a single [ParticleFlow].
class MultiWidgetParticleBuilder {
  MultiWidgetParticleBuilder({required List<ParticleWidgetBuilder> builders})
    : assert(builders.isNotEmpty),
      _builders = List<ParticleWidgetBuilder>.unmodifiable(builders);

  final List<ParticleWidgetBuilder> _builders;

  Widget build(BuildContext context, Particle p) {
    final idx = stableIndexForParticle(p, _builders.length);
    return _builders[idx](context, p);
  }
}

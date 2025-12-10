import 'package:flutter/widgets.dart';

import 'particle_behavior.dart';
import 'particle_flow_widget.dart';
import 'particle_model.dart';

/// Configuration for a single particle system inside [MultiParticleFlow].
///
/// Each system can have its own:
/// - count
/// - behavior (speed, gravity, scale, opacity, ...)
//  - spawn configuration (origin, custom area)
//  - render method (canvas OR widgets)
class ParticleSystemConfig {
  const ParticleSystemConfig._({
    required this.count,
    required this.behavior,
    required this.spawnConfig,
    this.paintParticle,
    this.buildParticle,
  }) : assert(
         (paintParticle != null) ^ (buildParticle != null),
         'Provide either paintParticle or buildParticle, not both.',
       );

  /// Number of particles for this system.
  final int count;

  /// Behavior for this system.
  final ParticleBehavior behavior;

  /// Spawn configuration for this system.
  final ParticleSpawnConfig spawnConfig;

  /// Canvas-based painter for this system, if used.
  final ParticleCanvasPainter? paintParticle;

  /// Widget-based builder for this system, if used.
  final ParticleWidgetBuilder? buildParticle;

  /// Canvas-based system configuration.
  const ParticleSystemConfig.canvas({
    required int count,
    ParticleBehavior behavior = const ParticleBehavior.snow(),
    ParticleSpawnConfig spawnConfig = const ParticleSpawnConfig(),
    required ParticleCanvasPainter paint,
  }) : this._(
         count: count,
         behavior: behavior,
         spawnConfig: spawnConfig,
         paintParticle: paint,
       );

  /// Widget-based system configuration.
  const ParticleSystemConfig.widgets({
    required int count,
    ParticleBehavior behavior = const ParticleBehavior.snow(),
    ParticleSpawnConfig spawnConfig = const ParticleSpawnConfig(),
    required ParticleWidgetBuilder build,
  }) : this._(
         count: count,
         behavior: behavior,
         spawnConfig: spawnConfig,
         buildParticle: build,
       );
}

/// A convenience widget that combines multiple [ParticleFlow] systems
/// into a single overlay.
///
/// Typical usage:
///
/// ```dart
/// MultiParticleFlow(
///   child: MyScaffold(),
///   systems: [
///     ParticleSystemConfig.canvas(...),
///     ParticleSystemConfig.widgets(...),
///   ],
/// )
/// ```
///
/// Pointer events are **not** captured by the particle overlay; they go to
/// [child] (or below), thanks to [IgnorePointer].
class MultiParticleFlow extends StatelessWidget {
  const MultiParticleFlow({
    super.key,
    required this.systems,
    this.isPaused = false,
    this.seed,
    this.child,
  });

  /// List of particle systems to render.
  final List<ParticleSystemConfig> systems;

  /// Global pause flag applied to all systems.
  final bool isPaused;

  /// Optional base seed used to derive per-system seeds.
  final int? seed;

  /// Optional child rendered behind all particle systems.
  ///
  /// Example:
  /// ```dart
  /// MultiParticleFlow(
  ///   systems: [...],
  ///   child: MaterialApp(home: MyHome()),
  /// )
  /// ```
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (systems.isEmpty) {
      return child ?? const SizedBox.shrink();
    }

    // Build all particle systems.
    final flows = <Widget>[
      for (var i = 0; i < systems.length; i++)
        ParticleFlow(
          key: ValueKey('particle_system_$i'),
          count: systems[i].count,
          behavior: systems[i].behavior,
          spawnConfig: systems[i].spawnConfig,
          paintParticle: systems[i].paintParticle,
          buildParticle: systems[i].buildParticle,
          isPaused: isPaused,
          seed: seed == null ? null : seed! + i,
        ),
    ];

    // Particle overlay should not intercept pointer events.
    final overlay = IgnorePointer(
      ignoring: true,
      child: Stack(fit: StackFit.expand, children: flows),
    );

    // If there is no child, just show the (non-interactive) overlay itself.
    if (child == null) {
      return overlay;
    }

    // Normal case: background [child] + particle overlay on top.
    return Stack(fit: StackFit.expand, children: [child!, overlay]);
  }
}

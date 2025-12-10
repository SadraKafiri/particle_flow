import 'package:flutter/widgets.dart';

import 'particle_behavior.dart';
import 'particle_flow_widget.dart';
import 'particle_model.dart';

/// Configuration for a single particle system inside [MultiParticleFlow].
///
/// Each system can have its own:
/// - count
/// - behavior (speed, gravity, scale, opacity, ...)
/// - spawn configuration (origin, custom area)
/// - render method (canvas OR widgets)
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
/// into a single overlay using a [Stack].
///
/// This lets you do things like:
/// - center area: emoji snow
/// - left side: images drifting in
/// - right side: custom widgets
/// - or fully mixed setups, each with its own origin and behavior.
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
  /// Typical usage:
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

    if (child == null) {
      return Stack(fit: StackFit.expand, children: flows);
    }

    return Stack(fit: StackFit.expand, children: [child!, ...flows]);
  }
}

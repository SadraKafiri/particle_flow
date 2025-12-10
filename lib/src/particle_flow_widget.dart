import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'particle_behavior.dart';
import 'particle_model.dart';
import 'particle_painters.dart';

/// High-performance configurable particle system.
///
/// - Use [ParticleFlow] for a single particle system (canvas OR widgets).
/// - Use [MultiParticleFlow] for combining multiple systems.
class ParticleFlow extends StatefulWidget {
  const ParticleFlow({
    super.key,
    required this.count,
    this.behavior = const ParticleBehavior.snow(),
    this.spawnConfig = const ParticleSpawnConfig(),
    this.paintParticle,
    this.buildParticle,
    this.isPaused = false,
    this.seed,
    this.child,
  }) : assert(
         (paintParticle != null) ^ (buildParticle != null),
         'Provide either paintParticle or buildParticle, not both.',
       );

  /// Total number of particles.
  final int count;

  /// Behavior configuration: speed, gravity, opacity, lifetime, etc.
  final ParticleBehavior behavior;

  /// Where particles spawn from (top, sides, full area, custom rect, ...).
  final ParticleSpawnConfig spawnConfig;

  /// High-performance, canvas-based rendering callback.
  ///
  /// Recommended for **many particles** (e.g. snow, confetti).
  final ParticleCanvasPainter? paintParticle;

  /// Widget-based rendering callback.
  ///
  /// Recommended for **lower counts** (e.g. gifts, pumpkins, custom UI).
  final ParticleWidgetBuilder? buildParticle;

  /// When true, animation stops updating but particles stay rendered.
  final bool isPaused;

  /// Optional random seed for deterministic behavior (useful for tests).
  final int? seed;

  /// Optional child rendered behind the particle overlay.
  ///
  /// - In canvas mode: rendered as [CustomPaint.child] while particles are
  ///   drawn by a painter or a foregroundPainter.
  /// - In widget mode: placed below the particle widgets in a [Stack].
  ///   When [child] is non-null, the overlay is wrapped in [IgnorePointer]
  ///   so the child remains fully interactive.
  final Widget? child;

  // ---------------------------------------------------------------------------
  // Convenience constructors
  // ---------------------------------------------------------------------------

  /// Convenience constructor for emoji/text-based particles (single text).
  factory ParticleFlow.emoji({
    Key? key,
    required String emoji,
    required int count,
    ParticleBehavior behavior = const ParticleBehavior.snow(),
    ParticleSpawnConfig spawnConfig = const ParticleSpawnConfig(),
    TextStyle style = const TextStyle(fontSize: 18),
    bool alignToCenter = true,
    bool isPaused = false,
    int? seed,
    Widget? child,
  }) {
    final emojiPainter = EmojiParticlePainter(
      text: emoji,
      style: style,
      alignToCenter: alignToCenter,
    );
    return ParticleFlow(
      key: key,
      count: count,
      behavior: behavior,
      spawnConfig: spawnConfig,
      paintParticle: emojiPainter.paint,
      isPaused: isPaused,
      seed: seed,
      child: child,
    );
  }

  /// Convenience constructor for **multiple** emoji / text choices.
  factory ParticleFlow.emojis({
    Key? key,
    required List<String> texts,
    required int count,
    ParticleBehavior behavior = const ParticleBehavior.snow(),
    ParticleSpawnConfig spawnConfig = const ParticleSpawnConfig(),
    TextStyle style = const TextStyle(fontSize: 18),
    bool alignToCenter = true,
    bool isPaused = false,
    int? seed,
    Widget? child,
  }) {
    assert(texts.isNotEmpty, 'texts must not be empty for ParticleFlow.emojis');
    final painter = MultiEmojiParticlePainter(
      texts: texts,
      style: style,
      alignToCenter: alignToCenter,
    );
    return ParticleFlow(
      key: key,
      count: count,
      behavior: behavior,
      spawnConfig: spawnConfig,
      paintParticle: painter.paint,
      isPaused: isPaused,
      seed: seed,
      child: child,
    );
  }

  /// Convenience constructor for simple circle particles (e.g. snow/dust).
  factory ParticleFlow.circles({
    Key? key,
    required int count,
    ParticleBehavior behavior = const ParticleBehavior.snow(),
    ParticleSpawnConfig spawnConfig = const ParticleSpawnConfig(),
    Color color = const Color(0xFFFFFFFF),
    double baseRadius = 4.0,
    bool isPaused = false,
    int? seed,
    Widget? child,
  }) {
    final circlePainter = CircleParticlePainter(
      color: color,
      baseRadius: baseRadius,
    );
    return ParticleFlow(
      key: key,
      count: count,
      behavior: behavior,
      spawnConfig: spawnConfig,
      paintParticle: circlePainter.paint,
      isPaused: isPaused,
      seed: seed,
      child: child,
    );
  }

  /// Convenience constructor for fully custom particle widgets.
  factory ParticleFlow.widgets({
    Key? key,
    required int count,
    required ParticleWidgetBuilder buildParticle,
    ParticleBehavior behavior = const ParticleBehavior.snow(),
    ParticleSpawnConfig spawnConfig = const ParticleSpawnConfig(),
    bool isPaused = false,
    int? seed,
    Widget? child,
  }) {
    return ParticleFlow(
      key: key,
      count: count,
      behavior: behavior,
      spawnConfig: spawnConfig,
      buildParticle: buildParticle,
      isPaused: isPaused,
      seed: seed,
      child: child,
    );
  }

  @override
  State<ParticleFlow> createState() => _ParticleFlowState();
}

class _ParticleFlowState extends State<ParticleFlow>
    with SingleTickerProviderStateMixin {
  late _ParticleEngine _engine;
  late final Ticker _ticker;
  late final ValueNotifier<int> _tickNotifier;

  Duration _lastElapsed = Duration.zero;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _engine = _createEngine();
    _tickNotifier = ValueNotifier<int>(0);
    _ticker = createTicker(_onTick);
    if (!widget.isPaused) {
      _ticker.start();
    }
  }

  _ParticleEngine _createEngine() {
    return _ParticleEngine(
      count: widget.count,
      behavior: widget.behavior,
      spawnConfig: widget.spawnConfig,
      seed: widget.seed,
    );
  }

  @override
  void didUpdateWidget(covariant ParticleFlow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final behaviorChanged =
        oldWidget.behavior != widget.behavior ||
        oldWidget.spawnConfig != widget.spawnConfig ||
        oldWidget.count != widget.count ||
        oldWidget.seed != widget.seed;

    if (behaviorChanged) {
      _engine = _createEngine();
      if (_lastSize != null) {
        _engine.ensureInitialized(_lastSize!);
      }
    }

    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _ticker.stop();
      } else {
        // Reset time base to avoid large initial delta.
        _lastElapsed = Duration.zero;
        _ticker.start();
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastSize == null) return;

    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;

    // Clamp dt to avoid extreme jumps when resuming from background.
    final double clampedDt = math.min(dt, 1 / 20); // max ~50ms per step.

    if (clampedDt <= 0) return;

    _engine.ensureInitialized(_lastSize!);
    _engine.update(clampedDt);
    _tickNotifier.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tickNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.isFinite || size.isEmpty) {
          return const SizedBox.shrink();
        }

        _lastSize = size;
        _engine.ensureInitialized(size);

        // Canvas-based rendering.
        if (widget.paintParticle != null) {
          final painter = _ParticlePainter(
            engine: _engine,
            repaint: _tickNotifier,
            paintParticle: widget.paintParticle!,
          );

          if (widget.child == null) {
            // Legacy behavior: full-screen CustomPaint.
            return RepaintBoundary(
              child: CustomPaint(
                painter: painter,
                child: const SizedBox.expand(),
              ),
            );
          }

          // Overlay mode: child rendered normally, particles drawn on top
          // by a foreground painter (painting does not block pointer events).
          return RepaintBoundary(
            child: CustomPaint(
              foregroundPainter: painter,
              child: widget.child!,
            ),
          );
        }

        // Widget-based rendering.
        final builder = widget.buildParticle!;
        final overlay = RepaintBoundary(
          child: ValueListenableBuilder<int>(
            valueListenable: _tickNotifier,
            builder: (context, _, _) {
              return SizedBox.expand(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final p in _engine.particles)
                      Positioned(
                        left: p.position.dx,
                        top: p.position.dy,
                        child: Opacity(
                          opacity: p.opacity.clamp(0.0, 1.0),
                          child: Transform.rotate(
                            angle: p.rotation,
                            child: Transform.scale(
                              scale: p.scale,
                              alignment: Alignment.center,
                              child: builder(context, p),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );

        // No child -> full-screen particle widget overlay.
        if (widget.child == null) {
          return overlay;
        }

        // When a [child] is provided:
        // - child stays interactive
        // - particle widgets are drawn above but do NOT capture any pointers.
        final ignoredOverlay = IgnorePointer(ignoring: true, child: overlay);

        return Stack(
          fit: StackFit.expand,
          children: [widget.child!, ignoredOverlay],
        );
      },
    );
  }
}

/// CustomPainter that delegates actual drawing to [paintParticle].
class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.engine,
    required Listenable repaint,
    required this.paintParticle,
  }) : super(repaint: repaint);

  final _ParticleEngine engine;
  final ParticleCanvasPainter paintParticle;

  @override
  void paint(Canvas canvas, Size size) {
    engine.ensureInitialized(size);

    for (final particle in engine.particles) {
      if (particle.opacity <= 0.0) continue;
      paintParticle(canvas, size, particle);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    // Repaint is driven by the Listenable; config changes recreate the painter.
    return false;
  }
}

/// Internal particle engine that updates and respawns particles.
class _ParticleEngine {
  _ParticleEngine({
    required this.count,
    required this.behavior,
    required this.spawnConfig,
    int? seed,
  }) : _random = math.Random(seed);

  final int count;
  final ParticleBehavior behavior;
  final ParticleSpawnConfig spawnConfig;
  final math.Random _random;

  final List<Particle> particles = <Particle>[];

  Size _size = Size.zero;
  bool _initialized = false;

  void ensureInitialized(Size size) {
    // Only (re)create particles when size or config changes.
    if (_initialized && size == _size && particles.length == count) return;

    _size = size;
    particles
      ..clear()
      ..addAll(
        List.generate(count, (index) => _createRandomParticle(isWarmUp: true)),
      );
    _initialized = true;
  }

  void update(double dt) {
    if (!_initialized || dt <= 0) return;

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];

      p.age += dt;
      final progress = p.progress;

      // Apply gravity.
      final vy = p.velocity.dy + behavior.gravity * dt;
      p.velocity = Offset(p.velocity.dx, vy);

      // Horizontal drift (sine wobble).
      final driftOffset =
          math.sin(p.driftPhase + p.driftFrequency * p.age) * p.driftAmplitude;

      // Integrate position.
      final newX = p.position.dx + p.velocity.dx * dt + driftOffset * dt;
      final newY = p.position.dy + vy * dt;
      p.position = Offset(newX, newY);

      // Rotation over time.
      p.rotation += behavior.rotationSpeed * dt;

      // Fade in / fade out based on normalized lifetime.
      final alphaFactor = _computeAlphaFactor(progress);
      p.opacity = (p.baseOpacity * alphaFactor).clamp(0.0, 1.0);

      final outOfBounds = _isOutOfBounds(p.position);
      final expired = p.age >= p.lifetime;

      if (outOfBounds || expired) {
        // Respawn a brand-new particle (no warm-up here).
        particles[i] = _createRandomParticle();
      }
    }
  }

  double _computeAlphaFactor(double progress) {
    final fadeInF = behavior.fadeInFraction;
    final fadeOutF = behavior.fadeOutFraction;

    var alphaFactor = 1.0;

    if (fadeInF > 0 && progress < fadeInF) {
      alphaFactor = (progress / fadeInF).clamp(0.0, 1.0);
    } else if (fadeOutF > 0 && progress > 1.0 - fadeOutF) {
      alphaFactor = ((1.0 - progress) / fadeOutF).clamp(0.0, 1.0);
    }

    return alphaFactor;
  }

  bool _isOutOfBounds(Offset position) {
    const extra = 80.0;
    final rect = spawnConfig.customArea ?? Offset.zero & _size;
    final padded = Rect.fromLTRB(
      rect.left - spawnConfig.spawnPadding.left - extra,
      rect.top - spawnConfig.spawnPadding.top - extra,
      rect.right + spawnConfig.spawnPadding.right + extra,
      rect.bottom + spawnConfig.spawnPadding.bottom + extra,
    );
    return !padded.contains(position);
  }

  Particle _createRandomParticle({bool isWarmUp = false}) {
    final lifetimeSec = _randomDouble(
      behavior.minLifetime.inMilliseconds / 1000.0,
      behavior.maxLifetime.inMilliseconds / 1000.0,
    );

    final speedY = _randomDouble(behavior.minSpeed, behavior.maxSpeed);
    final speedX = _randomDouble(
      behavior.minHorizontalSpeed,
      behavior.maxHorizontalSpeed,
    );

    final scale = _randomDouble(behavior.minScale, behavior.maxScale);

    final phase = _randomDouble(0, math.pi * 2);
    final freq = behavior.horizontalDriftFrequency * _randomDouble(0.8, 1.2);
    final amp = behavior.horizontalDriftAmplitude * _randomDouble(0.6, 1.4);

    final position = _randomSpawnPosition(isWarmUp: isWarmUp);

    final baseOpacity = _randomDouble(behavior.minOpacity, behavior.maxOpacity);

    double age;
    double initialOpacity;

    if (isWarmUp && lifetimeSec > 0) {
      age = _randomDouble(0, lifetimeSec);
      final progress = (age / lifetimeSec).clamp(0.0, 1.0);
      final alphaFactor = _computeAlphaFactor(progress);
      initialOpacity = (baseOpacity * alphaFactor).clamp(0.0, 1.0);
    } else {
      age = 0.0;
      initialOpacity = 0.0; // fade-in will happen on next update.
    }

    return Particle(
      position: position,
      velocity: Offset(speedX, speedY),
      scale: scale,
      opacity: initialOpacity,
      baseOpacity: baseOpacity,
      rotation: _randomDouble(0, math.pi * 2),
      age: age,
      lifetime: lifetimeSec,
      driftPhase: phase,
      driftFrequency: freq,
      driftAmplitude: amp,
    );
  }

  /// Spawn position, with special handling for warm-up so we don't get a
  /// "burst line" when starting from top/bottom/sides.
  Offset _randomSpawnPosition({bool isWarmUp = false}) {
    final rect = spawnConfig.customArea ?? Offset.zero & _size;
    final pad = spawnConfig.spawnPadding;

    if (!isWarmUp) {
      // Normal spawn: respect the configured origin.
      switch (spawnConfig.origin) {
        case ParticleSpawnOrigin.full:
          return Offset(
            _randomDouble(rect.left - pad.left, rect.right + pad.right),
            _randomDouble(rect.top - pad.top, rect.bottom + pad.bottom),
          );
        case ParticleSpawnOrigin.top:
          return Offset(
            _randomDouble(rect.left, rect.right),
            rect.top - pad.top - _randomDouble(0, 40),
          );
        case ParticleSpawnOrigin.bottom:
          return Offset(
            _randomDouble(rect.left, rect.right),
            rect.bottom + pad.bottom + _randomDouble(0, 40),
          );
        case ParticleSpawnOrigin.left:
          return Offset(
            rect.left - pad.left - _randomDouble(0, 40),
            _randomDouble(rect.top, rect.bottom),
          );
        case ParticleSpawnOrigin.right:
          return Offset(
            rect.right + pad.right + _randomDouble(0, 40),
            _randomDouble(rect.top, rect.bottom),
          );
        case ParticleSpawnOrigin.sides:
          final fromLeft = _random.nextBool();
          if (fromLeft) {
            return Offset(
              rect.left - pad.left - _randomDouble(0, 40),
              _randomDouble(rect.top, rect.bottom),
            );
          } else {
            return Offset(
              rect.right + pad.right + _randomDouble(0, 40),
              _randomDouble(rect.top, rect.bottom),
            );
          }
      }
    }

    // Warm-up mode: spread particles across their full motion path
    // so we do not get an initial dense burst.
    switch (spawnConfig.origin) {
      case ParticleSpawnOrigin.full:
        return Offset(
          _randomDouble(rect.left - pad.left, rect.right + pad.right),
          _randomDouble(rect.top - pad.top, rect.bottom + pad.bottom),
        );
      case ParticleSpawnOrigin.top:
      case ParticleSpawnOrigin.bottom:
        return Offset(
          _randomDouble(rect.left - pad.left, rect.right + pad.right),
          _randomDouble(rect.top - pad.top - 40, rect.bottom + pad.bottom + 40),
        );
      case ParticleSpawnOrigin.left:
      case ParticleSpawnOrigin.right:
      case ParticleSpawnOrigin.sides:
        return Offset(
          _randomDouble(rect.left - pad.left - 40, rect.right + pad.right + 40),
          _randomDouble(rect.top - pad.top, rect.bottom + pad.bottom),
        );
    }
  }

  double _randomDouble(double min, double max) =>
      min + _random.nextDouble() * (max - min);
}

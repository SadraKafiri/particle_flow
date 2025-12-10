import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

import '../widgets/particle_control_panel.dart';

class MultiSystemDemoPage extends StatefulWidget {
  const MultiSystemDemoPage({super.key});

  @override
  State<MultiSystemDemoPage> createState() => _MultiSystemDemoPageState();
}

class _MultiSystemDemoPageState extends State<MultiSystemDemoPage> {
  /// Global pause flag for all particle systems.
  bool _isPaused = false;

  /// Global motion parameters shared between systems.
  double _verticalSpeed = 40; // lower default speed (lighter feel)
  double _gravity = 18; // lower gravity
  double _driftAmplitude = 18; // softer horizontal wobble

  /// Global opacity settings.
  double _globalOpacity = 0.9;
  double _minParticleOpacity = 0.35;
  double _maxParticleOpacity = 0.9;

  // Per-system counts (lighter defaults so demo starts cheap)
  double _centerCount = 70; // center emojis
  double _sideCount = 22; // each side
  double _bottomCount = 14; // bottom stars

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-System Layout')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          // Define simple layout areas.
          final centerRect = Rect.fromLTWH(
            size.width * 0.2,
            0,
            size.width * 0.6,
            size.height,
          );
          final leftRect = Rect.fromLTWH(0, 0, size.width * 0.2, size.height);
          final rightRect = Rect.fromLTWH(
            size.width * 0.8,
            0,
            size.width * 0.2,
            size.height,
          );
          final bottomRect = Rect.fromLTWH(
            0,
            size.height * 0.65,
            size.width,
            size.height * 0.35,
          );

          // Behaviors per region (all based on shared sliders).
          final centerBehavior = _buildBehavior(isSnow: true);
          final sideBehavior = _buildBehavior(
            isSnow: false,
          ).copyWith(minScale: 0.9, maxScale: 1.5);
          final bottomBehavior = _buildBehavior(isSnow: false).copyWith(
            minSpeed: 10,
            maxSpeed: 35,
            gravity: -16, // float up
          );

          // Reusable emoji painter for the center system.
          final centerEmojiPainter = MultiEmojiParticlePainter(
            texts: const ['❄️', '🎄', '⭐'],
            style: const TextStyle(fontSize: 20),
          );

          return MultiParticleFlow(
            isPaused: _isPaused,
            systems: [
              // Center falling emojis (canvas-based)
              ParticleSystemConfig.canvas(
                count: _centerCount.round(),
                behavior: centerBehavior,
                spawnConfig: ParticleSpawnConfig(
                  origin: ParticleSpawnOrigin.top,
                  customArea: centerRect,
                ),
                paint: centerEmojiPainter.paint,
              ),

              // Left side: gifts drifting in (widgets)
              ParticleSystemConfig.widgets(
                count: _sideCount.round(),
                behavior: sideBehavior,
                spawnConfig: ParticleSpawnConfig(
                  origin: ParticleSpawnOrigin.left,
                  customArea: leftRect,
                ),
                build: (context, p) => Text(
                  '🎁',
                  style: TextStyle(
                    fontSize: 22 * p.scale,
                    color: Colors.redAccent.withValues(alpha: p.opacity * 0.9),
                  ),
                ),
              ),

              // Right side: pumpkins drifting in (widgets)
              ParticleSystemConfig.widgets(
                count: _sideCount.round(),
                behavior: sideBehavior,
                spawnConfig: ParticleSpawnConfig(
                  origin: ParticleSpawnOrigin.right,
                  customArea: rightRect,
                ),
                build: (context, p) => Text(
                  '🎃',
                  style: TextStyle(
                    fontSize: 22 * p.scale,
                    color: Colors.orange.withValues(alpha: p.opacity * 0.9),
                  ),
                ),
              ),

              // Bottom area: stars floating upwards (widgets)
              ParticleSystemConfig.widgets(
                count: _bottomCount.round(),
                behavior: bottomBehavior,
                spawnConfig: ParticleSpawnConfig(
                  origin: ParticleSpawnOrigin.bottom,
                  customArea: bottomRect,
                ),
                build: (context, p) => Icon(
                  Icons.star,
                  size: 18 * p.scale,
                  color: Colors.amber.withValues(alpha: p.opacity),
                ),
              ),
            ],

            // Control panel rendered as the child below the (ignored) overlay.
            child: ParticleControlPanel(
              isPaused: _isPaused,
              onPausedChanged: (v) => setState(() => _isPaused = v),
              showOrigin: false, // origins are fixed per system here
              origin: ParticleSpawnOrigin.top,
              onOriginChanged: (_) {},
              globalOpacity: _globalOpacity,
              onGlobalOpacityChanged: (v) => setState(() => _globalOpacity = v),
              minParticleOpacity: _minParticleOpacity,
              maxParticleOpacity: _maxParticleOpacity,
              onMinParticleOpacityChanged: (v) =>
                  setState(() => _minParticleOpacity = v),
              onMaxParticleOpacityChanged: (v) =>
                  setState(() => _maxParticleOpacity = v),
              count: _centerCount,
              minCount: 20,
              maxCount: 220,
              onCountChanged: (v) => setState(() => _centerCount = v),
              verticalSpeed: _verticalSpeed,
              onVerticalSpeedChanged: (v) => setState(() => _verticalSpeed = v),
              gravity: _gravity,
              onGravityChanged: (v) => setState(() => _gravity = v),
              driftAmplitude: _driftAmplitude,
              onDriftChanged: (v) => setState(() => _driftAmplitude = v),
              extraSection: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Per-system counts',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _LabeledSlider(
                    label: 'Center emojis: ${_centerCount.round()}',
                    value: _centerCount,
                    min: 20,
                    max: 220,
                    onChanged: (v) => setState(() => _centerCount = v),
                  ),
                  _LabeledSlider(
                    label: 'Side items (left/right): ${_sideCount.round()}',
                    value: _sideCount,
                    min: 5,
                    max: 80,
                    onChanged: (v) => setState(() => _sideCount = v),
                  ),
                  _LabeledSlider(
                    label: 'Bottom stars: ${_bottomCount.round()}',
                    value: _bottomCount,
                    min: 5,
                    max: 60,
                    onChanged: (v) => setState(() => _bottomCount = v),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a [ParticleBehavior] using the current sliders.
  ///
  /// [isSnow] toggles between a more “snow-like” center behavior and
  /// slightly livelier motion for side / bottom systems.
  ParticleBehavior _buildBehavior({required bool isSnow}) {
    final minSpeed = _verticalSpeed * 0.7;
    final maxSpeed = _verticalSpeed * 1.4;
    final double baseHorizontal = isSnow ? 14 : 26;
    final double minH = -baseHorizontal;
    final double maxH = baseHorizontal;

    const minLifetime = Duration(seconds: 8);
    const maxLifetime = Duration(seconds: 18);

    return ParticleBehavior(
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      minHorizontalSpeed: minH,
      maxHorizontalSpeed: maxH,
      gravity: _gravity,
      horizontalDriftAmplitude: _driftAmplitude,
      horizontalDriftFrequency: isSnow ? 0.7 : 0.4,
      minScale: isSnow ? 0.6 : 0.8,
      maxScale: isSnow ? 1.3 : 1.5,
      minOpacity: _minParticleOpacity.clamp(0.0, 1.0),
      maxOpacity: (_maxParticleOpacity * _globalOpacity).clamp(0.0, 1.0),
      minLifetime: minLifetime,
      maxLifetime: maxLifetime,
      fadeInFraction: 0.15,
      fadeOutFraction: 0.3,
      rotationSpeed: isSnow ? 0.4 : 0.25,
    );
  }
}

/// Small helper widget used only inside this demo for extra sliders.
class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

import '../widgets/particle_control_panel.dart';

class CustomWidgetsDemoPage extends StatefulWidget {
  const CustomWidgetsDemoPage({super.key});

  @override
  State<CustomWidgetsDemoPage> createState() => _CustomWidgetsDemoPageState();
}

class _CustomWidgetsDemoPageState extends State<CustomWidgetsDemoPage> {
  double _count = 60;
  bool _isPaused = false;
  ParticleSpawnOrigin _origin = ParticleSpawnOrigin.full;

  double _verticalSpeed = 25;
  double _gravity = 10;
  double _driftAmplitude = 26;

  double _globalOpacity = 1.0;
  double _minParticleOpacity = 0.5;
  double _maxParticleOpacity = 1.0;

  @override
  Widget build(BuildContext context) {
    final behavior = _buildBehavior();
    final spawnConfig = ParticleSpawnConfig(origin: _origin);

    // MultiWidgetParticleBuilder combines several widget styles.
    final multiBuilder = MultiWidgetParticleBuilder(
      builders: [
        // 1) Heart pill
        (context, p) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: p.opacity * _globalOpacity),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Custom',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ),

        // 2) Star emoji
        (context, p) => Text(
          '⭐',
          style: TextStyle(
            fontSize: 22 * p.scale,
            color: Colors.amber.withValues(alpha: p.opacity * _globalOpacity),
          ),
        ),

        // 3) Gift icon
        (context, p) => Icon(
          Icons.card_giftcard,
          size: 24 * p.scale,
          color: Colors.redAccent.withValues(alpha: p.opacity * _globalOpacity),
        ),
      ],
    );

    return ParticleFlow.widgets(
      count: _count.round().clamp(4, 120),
      behavior: behavior,
      spawnConfig: spawnConfig,
      isPaused: _isPaused,
      buildParticle: multiBuilder.build,
      child: Scaffold(
        appBar: AppBar(title: const Text('Custom Widgets & Mixed')),
        body: ParticleControlPanel(
          isPaused: _isPaused,
          onPausedChanged: (v) => setState(() => _isPaused = v),
          showOrigin: true,
          origin: _origin,
          onOriginChanged: (o) => setState(() => _origin = o),
          globalOpacity: _globalOpacity,
          onGlobalOpacityChanged: (v) => setState(() => _globalOpacity = v),
          minParticleOpacity: _minParticleOpacity,
          maxParticleOpacity: _maxParticleOpacity,
          onMinParticleOpacityChanged: (v) =>
              setState(() => _minParticleOpacity = v),
          onMaxParticleOpacityChanged: (v) =>
              setState(() => _maxParticleOpacity = v),
          count: _count,
          minCount: 10,
          maxCount: 120,
          onCountChanged: (v) => setState(() => _count = v),
          verticalSpeed: _verticalSpeed,
          onVerticalSpeedChanged: (v) => setState(() => _verticalSpeed = v),
          gravity: _gravity,
          onGravityChanged: (v) => setState(() => _gravity = v),
          driftAmplitude: _driftAmplitude,
          onDriftChanged: (v) => setState(() => _driftAmplitude = v),
        ),
      ),
    );
  }

  ParticleBehavior _buildBehavior() {
    final minSpeed = _verticalSpeed * 0.4;
    final maxSpeed = _verticalSpeed * 1.2;
    const minH = -35.0;
    const maxH = 35.0;

    return ParticleBehavior(
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      minHorizontalSpeed: minH,
      maxHorizontalSpeed: maxH,
      gravity: _gravity,
      horizontalDriftAmplitude: _driftAmplitude,
      horizontalDriftFrequency: 0.4,
      minScale: 0.8,
      maxScale: 1.4,
      minOpacity: _minParticleOpacity.clamp(0.0, 1.0),
      maxOpacity: (_maxParticleOpacity * _globalOpacity).clamp(0.0, 1.0),
      minLifetime: const Duration(seconds: 10),
      maxLifetime: const Duration(seconds: 20),
      fadeInFraction: 0.2,
      fadeOutFraction: 0.4,
      rotationSpeed: 0.35,
    );
  }
}

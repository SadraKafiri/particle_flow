import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

import '../widgets/particle_control_panel.dart';

class GiftWidgetsDemoPage extends StatefulWidget {
  const GiftWidgetsDemoPage({super.key});

  @override
  State<GiftWidgetsDemoPage> createState() => _GiftWidgetsDemoPageState();
}

class _GiftWidgetsDemoPageState extends State<GiftWidgetsDemoPage> {
  double _count = 60;
  bool _isPaused = false;
  ParticleSpawnOrigin _origin = ParticleSpawnOrigin.top;

  double _verticalSpeed = 40;
  double _gravity = 15;
  double _driftAmplitude = 20;

  double _globalOpacity = 1.0;
  double _minParticleOpacity = 0.6;
  double _maxParticleOpacity = 1.0;

  @override
  Widget build(BuildContext context) {
    final behavior = _buildBehavior();
    final spawnConfig = ParticleSpawnConfig(origin: _origin);

    return Scaffold(
      appBar: AppBar(title: const Text('Gift Widgets')),
      body: ParticleFlow.widgets(
        count: _count.round().clamp(4, 120),
        behavior: behavior,
        spawnConfig: spawnConfig,
        isPaused: _isPaused,
        buildParticle: (context, p) {
          return Icon(
            Icons.card_giftcard,
            size: 26 * p.scale,
            color: Colors.redAccent.withValues(
              alpha: p.opacity * _globalOpacity,
            ),
          );
        },
        child: ParticleControlPanel(
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
          maxCount: 160,
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
    final minSpeed = _verticalSpeed * 0.5;
    final maxSpeed = _verticalSpeed * 1.2;
    const minH = -25.0;
    const maxH = 25.0;

    return ParticleBehavior(
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      minHorizontalSpeed: minH,
      maxHorizontalSpeed: maxH,
      gravity: _gravity,
      horizontalDriftAmplitude: _driftAmplitude,
      horizontalDriftFrequency: 0.5,
      minScale: 0.8,
      maxScale: 1.4,
      minOpacity: _minParticleOpacity.clamp(0.0, 1.0),
      maxOpacity: (_maxParticleOpacity * _globalOpacity).clamp(0.0, 1.0),
      minLifetime: const Duration(seconds: 8),
      maxLifetime: const Duration(seconds: 18),
      fadeInFraction: 0.2,
      fadeOutFraction: 0.3,
      rotationSpeed: 0.25,
    );
  }
}

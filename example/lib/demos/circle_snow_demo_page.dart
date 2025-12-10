import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

import '../widgets/particle_control_panel.dart';

class CircleSnowDemoPage extends StatefulWidget {
  const CircleSnowDemoPage({super.key});

  @override
  State<CircleSnowDemoPage> createState() => _CircleSnowDemoPageState();
}

class _CircleSnowDemoPageState extends State<CircleSnowDemoPage> {
  double _count = 120;
  bool _isPaused = false;
  ParticleSpawnOrigin _origin = ParticleSpawnOrigin.top;

  // Gentler defaults
  double _verticalSpeed = 28; // was 60
  double _gravity = 14; // was 25
  double _driftAmplitude = 18; // was 24

  double _globalOpacity = 1.0;
  double _minParticleOpacity = 0.3;
  double _maxParticleOpacity = 0.85;

  @override
  Widget build(BuildContext context) {
    final behavior = _buildBehavior();
    final spawnConfig = ParticleSpawnConfig(origin: _origin);

    return ParticleFlow.circles(
      count: _count.round().clamp(20, 220),
      behavior: behavior,
      spawnConfig: spawnConfig,
      color: Colors.blueGrey.shade100.withValues(alpha: _globalOpacity),
      baseRadius: 3.5,
      isPaused: _isPaused,
      child: Scaffold(
        appBar: AppBar(title: const Text('Circle Snow (Canvas)')),
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
          minCount: 20,
          maxCount: 220,
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
    // Slower mapping
    final minSpeed = _verticalSpeed * 0.5;
    final maxSpeed = _verticalSpeed * 1.1;
    const minH = -10.0;
    const maxH = 10.0;

    return ParticleBehavior(
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      minHorizontalSpeed: minH,
      maxHorizontalSpeed: maxH,
      gravity: _gravity,
      horizontalDriftAmplitude: _driftAmplitude,
      horizontalDriftFrequency: 0.7,
      minScale: 0.7,
      maxScale: 1.25,
      minOpacity: _minParticleOpacity.clamp(0.0, 1.0),
      maxOpacity: (_maxParticleOpacity * _globalOpacity).clamp(0.0, 1.0),
      minLifetime: const Duration(seconds: 10),
      maxLifetime: const Duration(seconds: 18),
      fadeInFraction: 0.15,
      fadeOutFraction: 0.3,
      rotationSpeed: 0.0, // circles do not need visible rotation.
    );
  }
}

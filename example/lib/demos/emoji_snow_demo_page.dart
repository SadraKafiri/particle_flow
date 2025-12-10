// example/lib/demos/emoji_snow_demo_page.dart
// Emoji snow + multi-emoji demo (canvas-based).

import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

import '../widgets/particle_control_panel.dart';

class EmojiSnowDemoPage extends StatefulWidget {
  const EmojiSnowDemoPage({super.key});

  @override
  State<EmojiSnowDemoPage> createState() => _EmojiSnowDemoPageState();
}

class _EmojiSnowDemoPageState extends State<EmojiSnowDemoPage> {
  double _count = 100;
  bool _isPaused = false;
  ParticleSpawnOrigin _origin = ParticleSpawnOrigin.top;

  // Very gentle defaults.
  double _verticalSpeed = 16; // کاملاً پایین
  double _gravity = 8; // گراویتی کم
  double _driftAmplitude = 12; // نوسان افقی ملایم

  double _globalOpacity = 1.0;
  double _minParticleOpacity = 0.4;
  double _maxParticleOpacity = 1.0;

  // Emoji configuration
  bool _useMultiEmoji = false;
  String _emojiInput = '❄️';
  late final TextEditingController _emojiController;

  @override
  void initState() {
    super.initState();
    _emojiController = TextEditingController(text: _emojiInput);
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final behavior = _buildBehavior(isSnow: true);
    final spawnConfig = ParticleSpawnConfig(origin: _origin);

    return ParticleFlow(
      count: _count.round().clamp(10, 200),
      behavior: behavior,
      spawnConfig: spawnConfig,
      isPaused: _isPaused,
      paintParticle: _buildCanvasPainter(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Emoji Snow & Multi Emoji')),
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
          maxCount: 200,
          onCountChanged: (v) => setState(() => _count = v),
          verticalSpeed: _verticalSpeed,
          onVerticalSpeedChanged: (v) => setState(() => _verticalSpeed = v),
          gravity: _gravity,
          onGravityChanged: (v) => setState(() => _gravity = v),
          driftAmplitude: _driftAmplitude,
          onDriftChanged: (v) => setState(() => _driftAmplitude = v),
          showEmojiInput: true,
          emojiController: _emojiController,
          onEmojiSubmitted: (value) {
            if (value.trim().isEmpty) return;
            setState(() {
              _emojiInput = value.trim();
            });
          },
          showMultiEmojiToggle: true,
          useMultiEmoji: _useMultiEmoji,
          onUseMultiEmojiChanged: (v) => setState(() => _useMultiEmoji = v),
        ),
      ),
    );
  }

  /// Chooses the appropriate canvas painter based on single/multi emoji mode.
  ParticleCanvasPainter _buildCanvasPainter() {
    if (_useMultiEmoji) {
      final texts = _parseEmojiList(_emojiInput);
      if (texts.length <= 1) {
        // Fallback to single emoji mode.
        final emoji = texts.isNotEmpty ? texts.first : '❄️';
        final painter = EmojiParticlePainter(
          text: emoji,
          style: const TextStyle(fontSize: 22),
          alignToCenter: true,
        );
        return painter.paint;
      }
      final multiPainter = MultiEmojiParticlePainter(
        texts: texts,
        style: const TextStyle(fontSize: 22),
        alignToCenter: true,
      );
      return multiPainter.paint;
    } else {
      final painter = EmojiParticlePainter(
        text: _emojiInput,
        style: const TextStyle(fontSize: 22),
        alignToCenter: true,
      );
      return painter.paint;
    }
  }

  List<String> _parseEmojiList(String input) {
    return input
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  ParticleBehavior _buildBehavior({required bool isSnow}) {
    // خیلی نرم: اسلایدر ضریب خیلی کمی روی سرعت دارد.
    final minSpeed = _verticalSpeed * 0.2; // قبلاً 0.5 / 0.7
    final maxSpeed = _verticalSpeed * 0.45; // قبلاً 1.1 / 1.4

    final double baseHorizontal = isSnow ? 6 : 14;
    final double minH = -baseHorizontal;
    final double maxH = baseHorizontal;

    // طول عمر بلندتر → حرکت کندتر حس می‌شود.
    final minLifetime = const Duration(seconds: 14);
    final maxLifetime = const Duration(seconds: 24);

    return ParticleBehavior(
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      minHorizontalSpeed: minH,
      maxHorizontalSpeed: maxH,
      gravity: _gravity,
      horizontalDriftAmplitude: _driftAmplitude,
      horizontalDriftFrequency: isSnow ? 0.6 : 0.35,
      minScale: isSnow ? 0.7 : 0.8,
      maxScale: isSnow ? 1.2 : 1.4,
      minOpacity: _minParticleOpacity.clamp(0.0, 1.0),
      maxOpacity: (_maxParticleOpacity * _globalOpacity).clamp(0.0, 1.0),
      minLifetime: minLifetime,
      maxLifetime: maxLifetime,
      fadeInFraction: 0.18,
      fadeOutFraction: 0.32,
      rotationSpeed: isSnow ? 0.28 : 0.22,
    );
  }
}

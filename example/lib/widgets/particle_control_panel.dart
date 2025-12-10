// example/lib/widgets/particle_control_panel.dart
// Shared control panel widget used by most demos.

import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

/// Shared control panel used across multiple demo pages.
///
/// This is intentionally compact, but exposes:
/// - pause toggle
/// - spawn origin (optional)
/// - global overlay opacity
/// - min/max particle alpha
/// - count
/// - vertical speed
/// - gravity
/// - horizontal drift
/// - optional emoji input
/// - optional "multi emoji" toggle
/// - optional extra section for per-demo sliders.
class ParticleControlPanel extends StatelessWidget {
  const ParticleControlPanel({
    super.key,
    required this.isPaused,
    required this.onPausedChanged,
    this.showOrigin = true,
    required this.origin,
    required this.onOriginChanged,
    required this.globalOpacity,
    required this.onGlobalOpacityChanged,
    required this.minParticleOpacity,
    required this.maxParticleOpacity,
    required this.onMinParticleOpacityChanged,
    required this.onMaxParticleOpacityChanged,
    required this.count,
    required this.minCount,
    required this.maxCount,
    required this.onCountChanged,
    required this.verticalSpeed,
    required this.onVerticalSpeedChanged,
    required this.gravity,
    required this.onGravityChanged,
    required this.driftAmplitude,
    required this.onDriftChanged,
    this.showEmojiInput = false,
    this.emojiController,
    this.onEmojiSubmitted,
    this.showMultiEmojiToggle = false,
    this.useMultiEmoji = false,
    this.onUseMultiEmojiChanged,
    this.extraSection,
  });

  // Basic controls
  final bool isPaused;
  final ValueChanged<bool> onPausedChanged;

  final bool showOrigin;
  final ParticleSpawnOrigin origin;
  final ValueChanged<ParticleSpawnOrigin> onOriginChanged;

  final double globalOpacity;
  final ValueChanged<double> onGlobalOpacityChanged;

  final double minParticleOpacity;
  final double maxParticleOpacity;
  final ValueChanged<double> onMinParticleOpacityChanged;
  final ValueChanged<double> onMaxParticleOpacityChanged;

  final double count;
  final double minCount;
  final double maxCount;
  final ValueChanged<double> onCountChanged;

  final double verticalSpeed;
  final ValueChanged<double> onVerticalSpeedChanged;

  final double gravity;
  final ValueChanged<double> onGravityChanged;

  final double driftAmplitude;
  final ValueChanged<double> onDriftChanged;

  // Emoji / text input
  final bool showEmojiInput;
  final TextEditingController? emojiController;
  final ValueChanged<String>? onEmojiSubmitted;

  // Multi-emoji toggle
  final bool showMultiEmojiToggle;
  final bool useMultiEmoji;
  final ValueChanged<bool>? onUseMultiEmojiChanged;

  // Optional extra widgets for specific demos (e.g. per-system sliders).
  final Widget? extraSection;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Pause switch
                Row(
                  children: [
                    const Text(
                      'Particles',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Text('Pause'),
                    Switch(value: isPaused, onChanged: onPausedChanged),
                  ],
                ),

                const SizedBox(height: 4),

                if (showOrigin)
                  Row(
                    children: [
                      const Text(
                        'Spawn from:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<ParticleSpawnOrigin>(
                        value: origin,
                        underline: const SizedBox.shrink(),
                        onChanged: (value) {
                          if (value == null) return;
                          onOriginChanged(value);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ParticleSpawnOrigin.top,
                            child: Text('Top'),
                          ),
                          DropdownMenuItem(
                            value: ParticleSpawnOrigin.bottom,
                            child: Text('Bottom'),
                          ),
                          DropdownMenuItem(
                            value: ParticleSpawnOrigin.sides,
                            child: Text('Sides'),
                          ),
                          DropdownMenuItem(
                            value: ParticleSpawnOrigin.full,
                            child: Text('Full area'),
                          ),
                          DropdownMenuItem(
                            value: ParticleSpawnOrigin.left,
                            child: Text('Left'),
                          ),
                          DropdownMenuItem(
                            value: ParticleSpawnOrigin.right,
                            child: Text('Right'),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 6),

                _LabeledSlider(
                  label:
                      'Overlay opacity (all particles): ${globalOpacity.toStringAsFixed(2)}',
                  value: globalOpacity,
                  min: 0,
                  max: 1,
                  onChanged: onGlobalOpacityChanged,
                ),

                _LabeledSlider(
                  label:
                      'Particle min alpha: ${minParticleOpacity.toStringAsFixed(2)}',
                  value: minParticleOpacity,
                  min: 0,
                  max: maxParticleOpacity,
                  onChanged: onMinParticleOpacityChanged,
                ),
                _LabeledSlider(
                  label:
                      'Particle max alpha: ${maxParticleOpacity.toStringAsFixed(2)}',
                  value: maxParticleOpacity,
                  min: minParticleOpacity,
                  max: 1,
                  onChanged: onMaxParticleOpacityChanged,
                ),

                _LabeledSlider(
                  label: 'Count: ${count.round()}',
                  value: count,
                  min: minCount,
                  max: maxCount,
                  onChanged: onCountChanged,
                ),

                _LabeledSlider(
                  label:
                      'Vertical speed: ${verticalSpeed.toStringAsFixed(0)} px/s',
                  value: verticalSpeed,
                  min: 10,
                  max: 180,
                  onChanged: onVerticalSpeedChanged,
                ),

                _LabeledSlider(
                  label: 'Gravity: ${gravity.toStringAsFixed(0)}',
                  value: gravity,
                  min: 0,
                  max: 80,
                  onChanged: onGravityChanged,
                ),

                _LabeledSlider(
                  label:
                      'Horizontal drift: ${driftAmplitude.toStringAsFixed(0)} px',
                  value: driftAmplitude,
                  min: 0,
                  max: 60,
                  onChanged: onDriftChanged,
                ),

                if (showEmojiInput) ...[
                  const Divider(),
                  if (showMultiEmojiToggle)
                    Row(
                      children: [
                        const Text('Multi emoji (comma separated)'),
                        const Spacer(),
                        Switch(
                          value: useMultiEmoji,
                          onChanged: onUseMultiEmojiChanged,
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      const Text('Emoji / Text:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: emojiController,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Example: ❄️, 🎁, ⭐, 🎄',
                            border: UnderlineInputBorder(),
                          ),
                          onSubmitted: onEmojiSubmitted,
                        ),
                      ),
                    ],
                  ),
                ],

                if (extraSection != null) ...[const Divider(), extraSection!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple helper widget for labeled sliders.
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
    final clamped = value.clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(value: clamped, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

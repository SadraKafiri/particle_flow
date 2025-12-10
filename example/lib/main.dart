import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

void main() {
  runApp(const MainApp());
}

/// Root app widget.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Particle Flow Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const DemoHomePage(),
    );
  }
}

/// Simple model for a demo item in the home page.
class _DemoItem {
  const _DemoItem({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}

/// Home page that lists all demos.
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoItem>[
      _DemoItem(
        title: 'Emoji Snow & Multi Emoji',
        subtitle: 'Canvas-based emoji/text particles with full control.',
        builder: (_) => const EmojiSnowDemoPage(),
      ),
      _DemoItem(
        title: 'Circle Snow (Canvas)',
        subtitle: 'High-performance circle particles (snow / dust).',
        builder: (_) => const CircleSnowDemoPage(),
      ),
      _DemoItem(
        title: 'Gift Widgets',
        subtitle: 'Widget-based particles using Icons.',
        builder: (_) => const GiftWidgetsDemoPage(),
      ),
      _DemoItem(
        title: 'Custom Widgets & Mixed',
        subtitle: 'Multiple widget styles via MultiWidgetParticleBuilder.',
        builder: (_) => const CustomWidgetsDemoPage(),
      ),
      _DemoItem(
        title: 'Multi-System Layout',
        subtitle:
            'Different particles in center/left/right/bottom using MultiParticleFlow.',
        builder: (_) => const MultiSystemDemoPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Particle Flow Examples')),
      body: ListView.separated(
        itemCount: demos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final d = demos[index];
          return ListTile(
            title: Text(d.title),
            subtitle: Text(d.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: d.builder));
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared control panel
// ---------------------------------------------------------------------------

/// Shared control panel used across multiple demo pages.
///
/// All labels & controls are in English, UI is compact and ready for publishing.
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

  // Optional extra widgets for specific demos (e.g. per-system counts).
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

/// Simple helper for labeled sliders.
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

// ---------------------------------------------------------------------------
// Emoji snow + multi emoji demo
// ---------------------------------------------------------------------------

class EmojiSnowDemoPage extends StatefulWidget {
  const EmojiSnowDemoPage({super.key});

  @override
  State<EmojiSnowDemoPage> createState() => _EmojiSnowDemoPageState();
}

class _EmojiSnowDemoPageState extends State<EmojiSnowDemoPage> {
  double _count = 140;
  bool _isPaused = false;
  ParticleSpawnOrigin _origin = ParticleSpawnOrigin.top;

  double _verticalSpeed = 60;
  double _gravity = 25;
  double _driftAmplitude = 24;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Emoji Snow & Multi Emoji')),
      body: Stack(
        children: [
          _buildBackground(
            context,
            title: 'Emoji Snow',
            subtitle:
                'Single emoji/text OR multiple emojis (comma separated).\n'
                'Canvas-based, high-performance.',
          ),

          // Particles overlay
          IgnorePointer(
            child: Opacity(
              opacity: _globalOpacity.clamp(0.0, 1.0),
              child: _buildParticleLayer(behavior, spawnConfig),
            ),
          ),

          // Control panel on top
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ParticleControlPanel(
                isPaused: _isPaused,
                onPausedChanged: (v) => setState(() => _isPaused = v),
                showOrigin: true,
                origin: _origin,
                onOriginChanged: (o) => setState(() => _origin = o),
                globalOpacity: _globalOpacity,
                onGlobalOpacityChanged: (v) =>
                    setState(() => _globalOpacity = v),
                minParticleOpacity: _minParticleOpacity,
                maxParticleOpacity: _maxParticleOpacity,
                onMinParticleOpacityChanged: (v) =>
                    setState(() => _minParticleOpacity = v),
                onMaxParticleOpacityChanged: (v) =>
                    setState(() => _maxParticleOpacity = v),
                count: _count,
                minCount: 10,
                maxCount: 260,
                onCountChanged: (v) => setState(() => _count = v),
                verticalSpeed: _verticalSpeed,
                onVerticalSpeedChanged: (v) =>
                    setState(() => _verticalSpeed = v),
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
                onUseMultiEmojiChanged: (v) =>
                    setState(() => _useMultiEmoji = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticleLayer(
    ParticleBehavior behavior,
    ParticleSpawnConfig spawnConfig,
  ) {
    final count = _count.round().clamp(1, 400);

    if (_useMultiEmoji) {
      final texts = _parseEmojiList(_emojiInput);
      if (texts.length <= 1) {
        // Fallback to single emoji mode.
        return ParticleFlow.emoji(
          emoji: texts.isNotEmpty ? texts.first : '❄️',
          count: count,
          behavior: behavior,
          spawnConfig: spawnConfig,
          style: const TextStyle(fontSize: 22),
          isPaused: _isPaused,
        );
      }

      return ParticleFlow.emojis(
        texts: texts,
        count: count,
        behavior: behavior,
        spawnConfig: spawnConfig,
        style: const TextStyle(fontSize: 22),
        isPaused: _isPaused,
      );
    } else {
      return ParticleFlow.emoji(
        emoji: _emojiInput,
        count: count,
        behavior: behavior,
        spawnConfig: spawnConfig,
        style: const TextStyle(fontSize: 22),
        isPaused: _isPaused,
      );
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
    final minSpeed = _verticalSpeed * 0.7;
    final maxSpeed = _verticalSpeed * 1.4;

    final double baseHorizontal = isSnow ? 12 : 30;
    final double minH = -baseHorizontal;
    final double maxH = baseHorizontal;

    final minLifetime = isSnow
        ? const Duration(seconds: 8)
        : const Duration(seconds: 8);
    final maxLifetime = isSnow
        ? const Duration(seconds: 16)
        : const Duration(seconds: 18);

    return ParticleBehavior(
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      minHorizontalSpeed: minH,
      maxHorizontalSpeed: maxH,
      gravity: _gravity,
      horizontalDriftAmplitude: _driftAmplitude,
      horizontalDriftFrequency: isSnow ? 0.7 : 0.35,
      minScale: isSnow ? 0.6 : 0.8,
      maxScale: isSnow ? 1.3 : 1.5,
      minOpacity: _minParticleOpacity.clamp(0.0, 1.0),
      maxOpacity: _maxParticleOpacity.clamp(0.0, 1.0),
      minLifetime: minLifetime,
      maxLifetime: maxLifetime,
      fadeInFraction: 0.15,
      fadeOutFraction: 0.3,
      rotationSpeed: isSnow ? 0.4 : 0.25,
    );
  }

  Widget _buildBackground(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.ac_unit),
                label: const Text('Background button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circle snow demo (canvas circles)
// ---------------------------------------------------------------------------

class CircleSnowDemoPage extends StatefulWidget {
  const CircleSnowDemoPage({super.key});

  @override
  State<CircleSnowDemoPage> createState() => _CircleSnowDemoPageState();
}

class _CircleSnowDemoPageState extends State<CircleSnowDemoPage> {
  double _count = 160;
  bool _isPaused = false;
  ParticleSpawnOrigin _origin = ParticleSpawnOrigin.top;

  double _verticalSpeed = 60;
  double _gravity = 25;
  double _driftAmplitude = 24;

  double _globalOpacity = 1.0;
  double _minParticleOpacity = 0.3;
  double _maxParticleOpacity = 0.9;

  @override
  Widget build(BuildContext context) {
    final behavior = _buildBehavior();
    final spawnConfig = ParticleSpawnConfig(origin: _origin);

    return Scaffold(
      appBar: AppBar(title: const Text('Circle Snow (Canvas)')),
      body: Stack(
        children: [
          _buildBackground(context),
          IgnorePointer(
            child: Opacity(
              opacity: _globalOpacity.clamp(0.0, 1.0),
              child: ParticleFlow.circles(
                count: _count.round(),
                behavior: behavior,
                spawnConfig: spawnConfig,
                color: Colors.blueGrey.shade100,
                baseRadius: 3.5,
                isPaused: _isPaused,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ParticleControlPanel(
                isPaused: _isPaused,
                onPausedChanged: (v) => setState(() => _isPaused = v),
                showOrigin: true,
                origin: _origin,
                onOriginChanged: (o) => setState(() => _origin = o),
                globalOpacity: _globalOpacity,
                onGlobalOpacityChanged: (v) =>
                    setState(() => _globalOpacity = v),
                minParticleOpacity: _minParticleOpacity,
                maxParticleOpacity: _maxParticleOpacity,
                onMinParticleOpacityChanged: (v) =>
                    setState(() => _minParticleOpacity = v),
                onMaxParticleOpacityChanged: (v) =>
                    setState(() => _maxParticleOpacity = v),
                count: _count,
                minCount: 20,
                maxCount: 260,
                onCountChanged: (v) => setState(() => _count = v),
                verticalSpeed: _verticalSpeed,
                onVerticalSpeedChanged: (v) =>
                    setState(() => _verticalSpeed = v),
                gravity: _gravity,
                onGravityChanged: (v) => setState(() => _gravity = v),
                driftAmplitude: _driftAmplitude,
                onDriftChanged: (v) => setState(() => _driftAmplitude = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ParticleBehavior _buildBehavior() {
    final minSpeed = _verticalSpeed * 0.7;
    final maxSpeed = _verticalSpeed * 1.4;
    final minH = -12.0;
    final maxH = 12.0;

    return ParticleBehavior(
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      minHorizontalSpeed: minH,
      maxHorizontalSpeed: maxH,
      gravity: _gravity,
      horizontalDriftAmplitude: _driftAmplitude,
      horizontalDriftFrequency: 0.7,
      minScale: 0.7,
      maxScale: 1.3,
      minOpacity: _minParticleOpacity.clamp(0.0, 1.0),
      maxOpacity: _maxParticleOpacity.clamp(0.0, 1.0),
      minLifetime: const Duration(seconds: 8),
      maxLifetime: const Duration(seconds: 16),
      fadeInFraction: 0.15,
      fadeOutFraction: 0.3,
      rotationSpeed: 0.0, // circles do not need visible rotation.
    );
  }

  Widget _buildBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Circle Snow',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pure canvas-based circles.\nGreat for high particle counts.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gift widgets demo (simple widget-based particles)
// ---------------------------------------------------------------------------

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
      body: Stack(
        children: [
          _buildBackground(context),
          IgnorePointer(
            child: Opacity(
              opacity: _globalOpacity.clamp(0.0, 1.0),
              child: ParticleFlow.widgets(
                count: _count.round().clamp(4, 120),
                behavior: behavior,
                spawnConfig: spawnConfig,
                isPaused: _isPaused,
                buildParticle: (context, p) {
                  return Icon(
                    Icons.card_giftcard,
                    size: 26 * p.scale,
                    color: Colors.redAccent.withOpacity(p.opacity),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ParticleControlPanel(
                isPaused: _isPaused,
                onPausedChanged: (v) => setState(() => _isPaused = v),
                showOrigin: true,
                origin: _origin,
                onOriginChanged: (o) => setState(() => _origin = o),
                globalOpacity: _globalOpacity,
                onGlobalOpacityChanged: (v) =>
                    setState(() => _globalOpacity = v),
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
                onVerticalSpeedChanged: (v) =>
                    setState(() => _verticalSpeed = v),
                gravity: _gravity,
                onGravityChanged: (v) => setState(() => _gravity = v),
                driftAmplitude: _driftAmplitude,
                onDriftChanged: (v) => setState(() => _driftAmplitude = v),
              ),
            ),
          ),
        ],
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
      maxOpacity: _maxParticleOpacity.clamp(0.0, 1.0),
      minLifetime: const Duration(seconds: 8),
      maxLifetime: const Duration(seconds: 18),
      fadeInFraction: 0.2,
      fadeOutFraction: 0.3,
      rotationSpeed: 0.25,
    );
  }

  Widget _buildBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gifts',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Widget-based particles. Great for icons, images and custom UIs.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom widgets demo with MultiWidgetParticleBuilder
// ---------------------------------------------------------------------------

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
            color: Colors.purple.withOpacity(p.opacity),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
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
            color: Colors.amber.withOpacity(p.opacity),
          ),
        ),

        // 3) Gift icon
        (context, p) => Icon(
          Icons.card_giftcard,
          size: 24 * p.scale,
          color: Colors.redAccent.withOpacity(p.opacity),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Widgets & Mixed')),
      body: Stack(
        children: [
          _buildBackground(context),
          IgnorePointer(
            child: Opacity(
              opacity: _globalOpacity.clamp(0.0, 1.0),
              child: ParticleFlow.widgets(
                count: _count.round().clamp(4, 120),
                behavior: behavior,
                spawnConfig: spawnConfig,
                isPaused: _isPaused,
                buildParticle: multiBuilder.build,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ParticleControlPanel(
                isPaused: _isPaused,
                onPausedChanged: (v) => setState(() => _isPaused = v),
                showOrigin: true,
                origin: _origin,
                onOriginChanged: (o) => setState(() => _origin = o),
                globalOpacity: _globalOpacity,
                onGlobalOpacityChanged: (v) =>
                    setState(() => _globalOpacity = v),
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
                onVerticalSpeedChanged: (v) =>
                    setState(() => _verticalSpeed = v),
                gravity: _gravity,
                onGravityChanged: (v) => setState(() => _gravity = v),
                driftAmplitude: _driftAmplitude,
                onDriftChanged: (v) => setState(() => _driftAmplitude = v),
              ),
            ),
          ),
        ],
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
      maxOpacity: _maxParticleOpacity.clamp(0.0, 1.0),
      minLifetime: const Duration(seconds: 10),
      maxLifetime: const Duration(seconds: 20),
      fadeInFraction: 0.2,
      fadeOutFraction: 0.4,
      rotationSpeed: 0.35,
    );
  }

  Widget _buildBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Custom widgets',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Combines multiple widget styles using MultiWidgetParticleBuilder.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-system layout demo using MultiParticleFlow
// ---------------------------------------------------------------------------

class MultiSystemDemoPage extends StatefulWidget {
  const MultiSystemDemoPage({super.key});

  @override
  State<MultiSystemDemoPage> createState() => _MultiSystemDemoPageState();
}

class _MultiSystemDemoPageState extends State<MultiSystemDemoPage> {
  bool _isPaused = false;

  double _verticalSpeed = 55;
  double _gravity = 22;
  double _driftAmplitude = 24;

  double _globalOpacity = 1.0;
  double _minParticleOpacity = 0.4;
  double _maxParticleOpacity = 1.0;

  // Per-system counts
  double _centerCount = 120;
  double _sideCount = 40;
  double _bottomCount = 26;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-System Layout')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          // Define areas:
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

          final centerBehavior = _buildBehavior(isSnow: true);
          final sideBehavior = _buildBehavior(
            isSnow: false,
          ).copyWith(minScale: 0.9, maxScale: 1.5);
          final bottomBehavior = _buildBehavior(isSnow: false).copyWith(
            minSpeed: 10,
            maxSpeed: 40,
            gravity: -18, // float up
          );

          final centerEmojiPainter = MultiEmojiParticlePainter(
            texts: const ['❄️', '🎄', '⭐'],
            style: const TextStyle(fontSize: 20),
          );

          return Stack(
            children: [
              _buildBackground(context),

              // Control panel (global + per-system counts)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ParticleControlPanel(
                    isPaused: _isPaused,
                    onPausedChanged: (v) => setState(() => _isPaused = v),
                    showOrigin: false, // origins are fixed per-system here
                    origin: ParticleSpawnOrigin.top,
                    onOriginChanged: (_) {},
                    globalOpacity: _globalOpacity,
                    onGlobalOpacityChanged: (v) =>
                        setState(() => _globalOpacity = v),
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
                    onVerticalSpeedChanged: (v) =>
                        setState(() => _verticalSpeed = v),
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
                          label:
                              'Side items (left/right): ${_sideCount.round()}',
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
                ),
              ),
              // Multi-system particles overlay
              IgnorePointer(
                child: MultiParticleFlow(
                  isPaused: _isPaused,
                  systems: [
                    // Center falling emojis
                    ParticleSystemConfig.canvas(
                      count: _centerCount.round(),
                      behavior: centerBehavior,
                      spawnConfig: ParticleSpawnConfig(
                        origin: ParticleSpawnOrigin.top,
                        customArea: centerRect,
                      ),
                      paint: centerEmojiPainter.paint,
                    ),

                    // Left side: gifts drifting in
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
                          color: Colors.redAccent.withOpacity(p.opacity),
                        ),
                      ),
                    ),

                    // Right side: pumpkins drifting in
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
                          color: Colors.orange.withOpacity(p.opacity),
                        ),
                      ),
                    ),

                    // Bottom area: stars floating upwards
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
                        color: Colors.amber.withOpacity(p.opacity),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ParticleBehavior _buildBehavior({required bool isSnow}) {
    final minSpeed = _verticalSpeed * 0.7;
    final maxSpeed = _verticalSpeed * 1.4;
    final double baseHorizontal = isSnow ? 14 : 26;
    final double minH = -baseHorizontal;
    final double maxH = baseHorizontal;

    final minLifetime = const Duration(seconds: 8);
    final maxLifetime = const Duration(seconds: 18);

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
      maxOpacity: _maxParticleOpacity.clamp(0.0, 1.0),
      minLifetime: minLifetime,
      maxLifetime: maxLifetime,
      fadeInFraction: 0.15,
      fadeOutFraction: 0.3,
      rotationSpeed: isSnow ? 0.4 : 0.25,
    );
  }

  Widget _buildBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Multi-system layout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Different particles in center / sides / bottom.\n'
                'Each system has its own origin, area and style.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

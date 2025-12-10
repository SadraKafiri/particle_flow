# particle_flow_example

Demo application for the **`particle_flow`** Flutter package.

This example shows how to add smooth, configurable particle effects (snow, emojis, custom widgets, multiple layers, etc.) on top of normal Flutter UIs using:

- `ParticleFlow`
- `MultiParticleFlow`
- `ParticleBehavior`
- `ParticleSpawnConfig`
- Built-in painters and helpers

---

## Getting started

### 1. Install dependencies

From the root of the package (where `pubspec.yaml` of the **main package** lives):

```bash
flutter pub get
```

Then inside the `example/` folder:

```bash
cd example
flutter pub get
```

### 2. Run the example app

From inside the `example/` folder:

```bash
flutter run
```

You should see a demo app that renders different particle effects using `particle_flow` on top of a normal Flutter UI.

---

## What this example shows

The example is designed to show common and practical use cases:

1. **Snow overlay using circles**
2. **Emoji particles using canvas painters**
3. **Custom widget particles (icons)**
4. **Multiple particle systems layered together**

You can use the example as a reference and copy/paste code into your own project.

---

## 1. Simple snow overlay (circles)

This demo shows how to:

* Wrap a normal `Scaffold` with `ParticleFlow.circles`
* Use `ParticleBehavior.snow()` as a preset
* Spawn from the top edge only

```dart
import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

class SnowDemoPage extends StatelessWidget {
  const SnowDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticleFlow.circles(
      count: 180,
      behavior: const ParticleBehavior.snow(),
      spawnConfig: const ParticleSpawnConfig(
        origin: ParticleSpawnOrigin.top,
      ),
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: AppBar(
          title: const Text('Snow Demo'),
          backgroundColor: Colors.blueGrey.shade800,
        ),
        body: const Center(
          child: Text(
            'Snow overlay using circles',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
```

Key ideas:

* `child` is your normal UI.
* Particles are drawn on top using `CustomPaint.foregroundPainter`.
* Perfect for “ambient” effects like snow, dust, small lights.

---

## 2. Emoji particles (canvas mode)

This demo shows how to:

* Use `ParticleFlow.emojis` with multiple emojis
* Keep each particle’s emoji stable during its lifetime
* Still enjoy the same behavior/spawn configuration

```dart
class EmojiSnowDemoPage extends StatelessWidget {
  const EmojiSnowDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticleFlow.emojis(
      texts: ['❄️', '🎁', '⭐', '🎄'],
      count: 140,
      behavior: const ParticleBehavior.snow(
        minSpeed: 25,
        maxSpeed: 80,
      ),
      spawnConfig: const ParticleSpawnConfig(
        origin: ParticleSpawnOrigin.top,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emoji Snow Demo'),
        ),
        body: const Center(
          child: Text('Emoji particles rendered via canvas'),
        ),
      ),
    );
  }
}
```

Notes:

* Canvas mode is usually more efficient than widget mode for many particles.
* `MultiEmojiParticlePainter` internally chooses a stable emoji for each particle.

---

## 3. Custom widget particles (icons, images, UI)

This demo shows:

* `ParticleFlow.widgets` in action
* Using `ParticleWidgetBuilder` to return custom widgets
* Making the widget react to `particle.opacity` and `particle.scale`

```dart
class WidgetParticlesDemoPage extends StatelessWidget {
  const WidgetParticlesDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticleFlow.widgets(
      count: 32,
      behavior: const ParticleBehavior.snow(
        minSpeed: 40,
        maxSpeed: 120,
        minScale: 0.6,
        maxScale: 1.4,
      ),
      spawnConfig: const ParticleSpawnConfig(
        origin: ParticleSpawnOrigin.top,
      ),
      buildParticle: (context, particle) {
        return Icon(
          Icons.favorite,
          size: 28 * particle.scale,
          color: Colors.pinkAccent.withValues(alpha: particle.opacity),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Widget Particles Demo'),
        ),
        body: const Center(
          child: Text('Particles rendered as real widgets'),
        ),
      ),
    );
  }
}
```

When to use widget mode:

* You need complex visuals (icons, images, badges, small UIs).
* Particle count is moderate (dozens, not thousands).

---

## 4. Multiple systems with `MultiParticleFlow`

This demo shows how to:

* Combine snow circles + emojis + custom widgets in one overlay
* Share a single `child` UI beneath all systems
* Control all systems together using `isPaused` and `seed`

```dart
class MultiSystemDemoPage extends StatelessWidget {
  const MultiSystemDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiParticleFlow(
      systems: [
        // Background snow (small circles, many particles)
        ParticleSystemConfig.canvas(
          count: 200,
          behavior: const ParticleBehavior.snow(
            minOpacity: 0.25,
            maxOpacity: 0.7,
            minScale: 0.5,
            maxScale: 1.0,
          ),
          spawnConfig: const ParticleSpawnConfig(
            origin: ParticleSpawnOrigin.top,
          ),
          paint: CircleParticlePainter(
            baseRadius: 3,
            color: const Color(0xFFFFFFFF),
          ).paint,
        ),

        // Emoji flakes (medium count)
        ParticleSystemConfig.canvas(
          count: 70,
          behavior: const ParticleBehavior.snow(
            minSpeed: 20,
            maxSpeed: 60,
            minScale: 0.8,
            maxScale: 1.4,
          ),
          spawnConfig: const ParticleSpawnConfig(
            origin: ParticleSpawnOrigin.top,
          ),
          paint: MultiEmojiParticlePainter(
            texts: ['❄️', '⭐', '☃️'],
            style: const TextStyle(fontSize: 26),
          ).paint,
        ),

        // Foreground hearts (widgets, fewer particles)
        ParticleSystemConfig.widgets(
          count: 20,
          behavior: const ParticleBehavior.snow(
            minSpeed: 30,
            maxSpeed: 90,
            minScale: 0.7,
            maxScale: 1.3,
          ),
          spawnConfig: const ParticleSpawnConfig(
            origin: ParticleSpawnOrigin.top,
          ),
          build: (context, particle) {
            return Icon(
              Icons.favorite,
              color: Colors.pinkAccent.withValues(alpha: particle.opacity),
              size: 24 * particle.scale,
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MultiParticleFlow Demo'),
        ),
        body: const Center(
          child: Text(
            'Multiple particle layers on top of a single UI',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
```

Highlights:

* `child` is rendered once at the bottom.
* Each `ParticleSystemConfig` creates an independent `ParticleFlow` overlay.
* You can mix canvas-based and widget-based systems freely.

---

## Example app structure

A typical `example/lib/main.dart` might look like:

```dart
import 'package:flutter/material.dart';
import 'snow_demo_page.dart';
import 'emoji_snow_demo_page.dart';
import 'widget_particles_demo_page.dart';
import 'multi_system_demo_page.dart';

void main() {
  runApp(const ParticleFlowDemoApp());
}

class ParticleFlowDemoApp extends StatelessWidget {
  const ParticleFlowDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'particle_flow example',
      theme: ThemeData.dark(),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DemoItem>[
      _DemoItem(
        title: 'Snow (circles)',
        builder: (context) => const SnowDemoPage(),
      ),
      _DemoItem(
        title: 'Emoji Snow',
        builder: (context) => const EmojiSnowDemoPage(),
      ),
      _DemoItem(
        title: 'Widget Particles',
        builder: (context) => const WidgetParticlesDemoPage(),
      ),
      _DemoItem(
        title: 'MultiParticleFlow',
        builder: (context) => const MultiSystemDemoPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('particle_flow example'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: item.builder),
              );
            },
          );
        },
      ),
    );
  }
}

class _DemoItem {
  const _DemoItem({
    required this.title,
    required this.builder,
  });

  final String title;
  final WidgetBuilder builder;
}
```

You’re free to adapt this structure, but this layout:

* Keeps each demo focused and small.
* Makes it easy to explore different usage patterns.


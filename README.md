# particle_flow

High-performance, configurable particle system for Flutter.

`particle_flow` lets you add smooth, lightweight particle effects (snow, confetti, emoji rain, custom widgets, etc.) on top of any UI:

- Canvas-based particles for **maximum performance**
- Widget-based particles for **fully custom content**
- Easy overlay API: wrap any widget/page/app with particles using `child`
- Multiple particle systems at once via `MultiParticleFlow`

---

## Features

- 🔹 **Two rendering modes**
  - **Canvas mode** using `ParticleCanvasPainter` (best for many particles: snow, dust, emojis, shapes)
  - **Widget mode** using `ParticleWidgetBuilder` (icons, images, custom widgets)

- 🔹 **Overlay child support**
  - All core widgets (`ParticleFlow`, `MultiParticleFlow`) accept a `child`
  - Your UI renders once; particles are drawn on top

- 🔹 **Configurable behavior with `ParticleBehavior`**
  - Speed, gravity, drift, scale, opacity, lifetime, fade-in/out, rotation
  - Built-in preset: `ParticleBehavior.snow()`

- 🔹 **Flexible spawn with `ParticleSpawnConfig`**
  - Spawn from `top`, `bottom`, `left`, `right`, `sides`, or `full`
  - Optional `customArea` + `spawnPadding`

- 🔹 **Multiple systems with `MultiParticleFlow`**
  - Layer several particle systems on a single `child`
  - Mix canvas & widget systems

---

## Getting started

### 1. Add dependency

```yaml
dependencies:
  particle_flow: ^0.0.1  # or the latest version
```

Then:

```bash
flutter pub get
```

### 2. Import the package

```dart
import 'package:particle_flow/particle_flow.dart';
```

---

## Basic usage

### Simple snow overlay (circles + child)

```dart
import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';

class SnowPage extends StatelessWidget {
  const SnowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticleFlow.circles(
      count: 160,
      behavior: const ParticleBehavior.snow(),
      spawnConfig: const ParticleSpawnConfig(
        origin: ParticleSpawnOrigin.top,
      ),
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        body: const Center(
          child: Text(
            'Snow overlay',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
```

---

## Key APIs

### `ParticleFlow`

Main widget for a single particle system.

Convenience constructors:

* `ParticleFlow.circles(...)`
* `ParticleFlow.emoji(...)`
* `ParticleFlow.emojis(...)`
* `ParticleFlow.widgets(...)`

Common parameters:

* `count` – number of particles
* `behavior` – `ParticleBehavior` (motion, lifetime, opacity, etc.)
* `spawnConfig` – `ParticleSpawnConfig` (spawn origin/area)
* `isPaused` – pause/resume animation
* `seed` – optional random seed for deterministic behavior
* `child` – widget rendered underneath the particle overlay

---

### `MultiParticleFlow`

Combine multiple particle systems on top of a single `child`.

```dart
MultiParticleFlow(
  systems: [
    ParticleSystemConfig.canvas(...),
    ParticleSystemConfig.widgets(...),
  ],
  child: YourPage(),
);
```

* `systems` – list of `ParticleSystemConfig`
* `isPaused` – pause all systems at once
* `seed` – base seed (each system uses `seed + index`)
* `child` – rendered once beneath all particle systems

---

### `ParticleBehavior`

Controls motion and visual behavior.

* Vertical speed: `minSpeed`, `maxSpeed`
* Horizontal speed: `minHorizontalSpeed`, `maxHorizontalSpeed`
* Gravity: `gravity`
* Drift: `horizontalDriftAmplitude`, `horizontalDriftFrequency`
* Scale range: `minScale`, `maxScale`
* Opacity range: `minOpacity`, `maxOpacity`
* Lifetime: `minLifetime`, `maxLifetime`
* Fade: `fadeInFraction`, `fadeOutFraction`
* Rotation: `rotationSpeed`

Helpers:

* `const ParticleBehavior.snow(...)` – preset tuned for soft snow-like motion
* `copyWith(...)` – customize specific fields

---

### `ParticleSpawnConfig` & `ParticleSpawnOrigin`

Control where particles appear:

```dart
const ParticleSpawnConfig({
  this.origin = ParticleSpawnOrigin.top,
  this.customArea,
  this.spawnPadding = EdgeInsets.zero,
});
```

Origins:

* `ParticleSpawnOrigin.full`
* `ParticleSpawnOrigin.top`
* `ParticleSpawnOrigin.bottom`
* `ParticleSpawnOrigin.left`
* `ParticleSpawnOrigin.right`
* `ParticleSpawnOrigin.sides`

You can also:

* Limit spawn to a custom rectangle using `customArea`
* Spawn slightly off-screen using `spawnPadding`

---

## Examples

More complete and advanced examples (multi-system setups, emojis, custom widgets, etc.) live in:

👉 [`example/README.md`](example/README.md)

Run the example app:

```bash
cd example
flutter run
```

---

## License

This package is distributed under the MIT License.
See the [LICENSE](LICENSE) file for details.


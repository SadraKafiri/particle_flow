import 'package:flutter/material.dart';
import 'package:particle_flow/particle_flow.dart';
import 'package:particle_flow_example/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'particle_flow examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const SimpleCirclesExamplePage(),
    );
  }
}

class SimpleCirclesExamplePage extends StatelessWidget {
  const SimpleCirclesExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    const behavior = ParticleBehavior.snow();

    return ParticleFlow.circles(
      count: 120,
      behavior: behavior,
      spawnConfig: const ParticleSpawnConfig(origin: ParticleSpawnOrigin.top),
      color: Colors.grey,
      baseRadius: 3.5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('particle_flow – Simple example'),
          actions: [
            IconButton(
              tooltip: 'All demos',
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const DemoHomePage()));
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ac_unit, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Simple snow overlay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This is the minimal usage:\n'
                'ParticleFlow.circles(count: 120, child: Scaffold(...))',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('This button is still clickable'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DemoHomePage()),
                  );
                },
                child: const Text('Open all advanced demos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

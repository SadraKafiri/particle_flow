// example/lib/home_page.dart
// Simple menu listing all advanced demo screens.

import 'package:flutter/material.dart';

import 'demos/emoji_snow_demo_page.dart';
import 'demos/circle_snow_demo_page.dart';
import 'demos/gift_widgets_demo_page.dart';
import 'demos/custom_widgets_demo_page.dart';
import 'demos/multi_system_demo_page.dart';

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

/// Home page that lists all demos except the very basic one.
/// The basic example is shown directly in `main.dart`.
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoItem>[
      _DemoItem(
        title: 'Emoji Snow & Multi Emoji',
        subtitle: 'Canvas-based emoji/text particles with controls.',
        builder: (context) => EmojiSnowDemoPage(),
      ),
      _DemoItem(
        title: 'Circle Snow (Canvas)',
        subtitle: 'High-performance circle particles (snow / dust).',
        builder: (context) => CircleSnowDemoPage(),
      ),
      _DemoItem(
        title: 'Gift Widgets',
        subtitle: 'Widget-based particles (Icons).',
        builder: (context) => GiftWidgetsDemoPage(),
      ),
      _DemoItem(
        title: 'Custom Widgets & Mixed',
        subtitle: 'Multiple widget styles via MultiWidgetParticleBuilder.',
        builder: (context) => CustomWidgetsDemoPage(),
      ),
      _DemoItem(
        title: 'Multi-System Layout',
        subtitle: 'Different particles per area using MultiParticleFlow.',
        builder: (context) => MultiSystemDemoPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('particle_flow – All demos')),
      body: ListView.separated(
        itemCount: demos.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
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

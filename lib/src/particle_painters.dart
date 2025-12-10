// lib/particle_flow/particle_painters.dart
import 'package:flutter/widgets.dart';

import 'particle_model.dart';

/// Simple circle painter for snow-like particles.
class CircleParticlePainter {
  CircleParticlePainter({
    this.color = const Color(0xFFFFFFFF),
    this.baseRadius = 4.0,
    this.stroke = false,
    this.strokeWidth = 1.0,
  });

  /// Base color of the particle.
  final Color color;

  /// Base radius in logical pixels (scaled by [Particle.scale]).
  final double baseRadius;

  /// Whether to draw an outline instead of a filled circle.
  final bool stroke;

  /// Stroke width when [stroke] is true.
  final double strokeWidth;

  /// Canvas painter function.
  void paint(Canvas canvas, Size size, Particle p) {
    final radius = baseRadius * p.scale;
    if (radius <= 0) return;

    final paint = Paint()
      ..style = stroke ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: (color.a * p.opacity).clamp(0.0, 1.0));

    canvas.drawCircle(p.position, radius, paint);
  }
}

/// Emoji / text painter for particles.
///
/// This is more expensive than circle painting, so it is best for
/// moderate particle counts.
class EmojiParticlePainter {
  EmojiParticlePainter({
    required String text,
    TextStyle style = const TextStyle(fontSize: 18),
    this.alignToCenter = true,
  }) : _text = text,
       _baseStyle = style,
       _textPainter = TextPainter(textDirection: TextDirection.ltr);

  final String _text;
  final TextStyle _baseStyle;
  final bool alignToCenter;
  final TextPainter _textPainter;

  void paint(Canvas canvas, Size size, Particle p) {
    final color = _baseStyle.color ?? const Color(0xFFFFFFFF);
    final style = _baseStyle.copyWith(
      color: color.withValues(alpha: (color.a * p.opacity).clamp(0.0, 1.0)),
    );

    _textPainter.text = TextSpan(text: _text, style: style);
    _textPainter.layout();

    final textSize = _textPainter.size;
    final scaledSize = textSize * p.scale;

    Offset offset = p.position;
    if (alignToCenter) {
      offset = offset - Offset(scaledSize.width / 2, scaledSize.height / 2);
    }

    canvas.save();
    // Move to particle center, then rotate/scale, then draw at origin.
    canvas.translate(
      offset.dx + scaledSize.width / 2,
      offset.dy + scaledSize.height / 2,
    );
    canvas.rotate(p.rotation);
    canvas.scale(p.scale);
    canvas.translate(-textSize.width / 2, -textSize.height / 2);

    _textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}

/// Painter that randomly chooses between multiple emoji/text painters,
/// and keeps the choice stable per-particle.
class MultiEmojiParticlePainter {
  MultiEmojiParticlePainter({
    required List<String> texts,
    TextStyle style = const TextStyle(fontSize: 18),
    this.alignToCenter = true,
  }) : assert(texts.isNotEmpty),
       _painters = texts
           .map(
             (t) => EmojiParticlePainter(
               text: t,
               style: style,
               alignToCenter: alignToCenter,
             ),
           )
           .toList();

  final bool alignToCenter;
  final List<EmojiParticlePainter> _painters;

  void paint(Canvas canvas, Size size, Particle p) {
    final idx = stableIndexForParticle(p, _painters.length);
    _painters[idx].paint(canvas, size, p);
  }
}

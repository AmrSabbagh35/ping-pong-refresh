import 'package:flutter/material.dart';

/// Visual configuration for [PingPongRefresh].
///
/// Pass a [PingPongTheme] to [PingPongRefresh.theme] to customise colors.
/// Defaults produce a dark, neon-accented look.
class PingPongTheme {
  const PingPongTheme({
    this.leftPaddleColor = const Color(0xFFC0F500),
    this.rightPaddleColor = const Color(0xFF2792FF),
    this.ballGradientColors = const [
      Colors.white,
      Color(0xFFEAFFA6),
      Color(0xFFC0F500),
    ],
    this.ballGradientStops = const [0.38, 0.78, 1.0],
    this.labelColor = const Color(0xFFC4CAAC),
    this.handleColor = const Color(0xFFCC9E64),
    this.handleCollarColor = const Color(0xFF9E7645),
  });

  /// A light theme suitable for white/light backgrounds.
  const PingPongTheme.light({
    Color leftPaddleColor = const Color(0xFF4CAF50),
    Color rightPaddleColor = const Color(0xFF2196F3),
  }) : this(
         leftPaddleColor: leftPaddleColor,
         rightPaddleColor: rightPaddleColor,
         ballGradientColors: const [
           Colors.white,
           Color(0xFFE8F5E9),
           Color(0xFF4CAF50),
         ],
         labelColor: const Color(0xFF757575),
         handleColor: const Color(0xFFBCAAA4),
         handleCollarColor: const Color(0xFF8D6E63),
       );

  final Color leftPaddleColor;
  final Color rightPaddleColor;
  final List<Color> ballGradientColors;
  final List<double> ballGradientStops;
  final Color labelColor;
  final Color handleColor;
  final Color handleCollarColor;
}

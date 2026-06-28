import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';

import 'ping_pong_theme.dart';

export 'ping_pong_theme.dart';

/// Minimum time the refresh indicator stays visible so the animation is
/// perceptible even on fast data sources.
const Duration kPingPongMinRefreshDuration = Duration(seconds: 2);

/// Runs [action] but ensures at least [kPingPongMinRefreshDuration] elapses
/// before returning.
Future<void> runWithMinPingPongDuration(Future<void> Function() action) async {
  final stopwatch = Stopwatch()..start();
  await action();
  final remaining = kPingPongMinRefreshDuration - stopwatch.elapsed;
  if (remaining > Duration.zero) await Future<void>.delayed(remaining);
}

/// A Cupertino pull-to-refresh sliver with a ping-pong rally animation.
///
/// Drop this as the **first sliver** in a [CustomScrollView]:
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     PingPongRefresh(
///       onRefresh: () async { /* fetch data */ },
///     ),
///     // ... your other slivers
///   ],
/// )
/// ```
///
/// Wrap your async call with [runWithMinPingPongDuration] to keep the
/// animation visible long enough to be enjoyable:
///
/// ```dart
/// PingPongRefresh(
///   onRefresh: () => runWithMinPingPongDuration(() async {
///     await myRepo.reload();
///   }),
/// )
/// ```
class PingPongRefresh extends StatelessWidget {
  const PingPongRefresh({
    super.key,
    required this.onRefresh,
    this.theme = const PingPongTheme(),
    this.enableHaptics = true,
  });

  final RefreshCallback onRefresh;

  /// Visual configuration — colors for paddles, ball, and label.
  final PingPongTheme theme;

  /// Whether to fire haptic feedback when the pull arms and when it completes.
  final bool enableHaptics;

  static const double _contentHeight = 63.0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final indicatorExtent = topInset + _contentHeight;
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: indicatorExtent,
      refreshIndicatorExtent: indicatorExtent,
      onRefresh: onRefresh,
      builder: (
        context,
        refreshState,
        pulledExtent,
        triggerDistance,
        indicatorExtent,
      ) {
        return _PingPongIndicator(
          refreshState: refreshState,
          pulledExtent: pulledExtent,
          triggerDistance: triggerDistance,
          indicatorExtent: indicatorExtent,
          topInset: topInset,
          theme: theme,
          enableHaptics: enableHaptics,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PingPongIndicator extends StatefulWidget {
  const _PingPongIndicator({
    required this.refreshState,
    required this.pulledExtent,
    required this.triggerDistance,
    required this.indicatorExtent,
    required this.topInset,
    required this.theme,
    required this.enableHaptics,
  });

  final RefreshIndicatorMode refreshState;
  final double pulledExtent;
  final double triggerDistance;
  final double indicatorExtent;
  final double topInset;
  final PingPongTheme theme;
  final bool enableHaptics;

  @override
  State<_PingPongIndicator> createState() => _PingPongIndicatorState();
}

class _PingPongIndicatorState extends State<_PingPongIndicator>
    with SingleTickerProviderStateMixin {
  static const _rallyDuration = Duration(milliseconds: 600);
  static const _ballArc = 20.0;

  late final AnimationController _rallyController;
  bool _hasArmedHaptic = false;
  bool _hasCompletedHaptic = false;

  @override
  void initState() {
    super.initState();
    _rallyController = AnimationController(
      vsync: this,
      duration: _rallyDuration,
    );
  }

  @override
  void dispose() {
    _rallyController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PingPongIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWithState();
  }

  double get _progress =>
      (widget.pulledExtent / widget.triggerDistance).clamp(0.0, 1.0);

  void _syncWithState() {
    switch (widget.refreshState) {
      case RefreshIndicatorMode.drag:
        _hasArmedHaptic = false;
        _hasCompletedHaptic = false;
        if (_rallyController.isAnimating) _rallyController.stop();
      case RefreshIndicatorMode.armed:
        if (!_hasArmedHaptic) {
          _hasArmedHaptic = true;
          if (widget.enableHaptics) HapticFeedback.selectionClick();
        }
      case RefreshIndicatorMode.refresh:
        if (!_rallyController.isAnimating) _rallyController.repeat();
      case RefreshIndicatorMode.done:
        if (!_hasCompletedHaptic) {
          _hasCompletedHaptic = true;
          if (widget.enableHaptics) HapticFeedback.lightImpact();
        }
        _rallyController.stop();
      case RefreshIndicatorMode.inactive:
        _hasArmedHaptic = false;
        _hasCompletedHaptic = false;
        _rallyController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rallying =
        widget.refreshState == RefreshIndicatorMode.refresh ||
        widget.refreshState == RefreshIndicatorMode.done;

    final p = _progress;

    final label = switch (widget.refreshState) {
      RefreshIndicatorMode.refresh => 'RALLYING…',
      RefreshIndicatorMode.done => 'UP TO DATE',
      _ => p >= 1.0 ? 'RELEASE TO RALLY' : 'PULL TO REFRESH',
    };

    final visibleExtent = math.max(0.0, widget.pulledExtent - widget.topInset);

    return SizedBox(
      height: widget.pulledExtent,
      child: Padding(
        padding: EdgeInsets.only(top: widget.topInset),
        child: ClipRect(
          child: OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: rallying ? 1.0 : math.min(p * 1.5, 1.0),
                    child: Transform.scale(
                      scale: rallying ? 1.0 : 0.55 + p * 0.45,
                      child: AnimatedBuilder(
                        animation: _rallyController,
                        builder: (context, _) => SizedBox(
                          width: 94,
                          height: 29,
                          child: CustomPaint(
                            painter: _PongPainter(
                              progress: p,
                              rallying: rallying,
                              rallyT: _rallyController.value,
                              ballArc: _ballArc,
                              theme: widget.theme,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (visibleExtent > 44) ...[
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                        color: widget.theme.labelColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PongPainter extends CustomPainter {
  const _PongPainter({
    required this.progress,
    required this.rallying,
    required this.rallyT,
    required this.ballArc,
    required this.theme,
  });

  final double progress;
  final bool rallying;
  final double rallyT;
  final double ballArc;
  final PingPongTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfSpan = size.width / 2 - 15;

    double ballX, ballY, leftDeg, rightDeg;

    if (rallying) {
      final t = rallyT;
      if (t <= 0.25) {
        final k = t / 0.25;
        ballX = -halfSpan + k * halfSpan;
        ballY = -math.sin(k * math.pi / 2) * ballArc;
      } else if (t <= 0.5) {
        final k = (t - 0.25) / 0.25;
        ballX = k * halfSpan;
        ballY = -math.sin((1 - k) * math.pi / 2) * ballArc;
      } else if (t <= 0.75) {
        final k = (t - 0.5) / 0.25;
        ballX = halfSpan - k * halfSpan;
        ballY = -math.sin(k * math.pi / 2) * ballArc;
      } else {
        final k = (t - 0.75) / 0.25;
        ballX = -k * halfSpan;
        ballY = -math.sin((1 - k) * math.pi / 2) * ballArc;
      }

      leftDeg = _lerpKeyframes(t, const [
        (0.00, 16.0),
        (0.16, 40.0),
        (1.00, 34.0),
      ]);
      rightDeg = _lerpKeyframes(t, const [
        (0.00, -34.0),
        (0.40, -34.0),
        (0.50, -16.0),
        (0.66, -40.0),
        (1.00, -34.0),
      ]);
    } else {
      final p = progress.clamp(0.0, 1.0);
      ballX = -halfSpan + p * (halfSpan * 2);
      ballY = -math.sin(p * math.pi) * ballArc;
      leftDeg = 34 - p * 10;
      rightDeg = -34 + p * 10;
    }

    _paintPaddle(
      canvas,
      center: Offset(15, center.dy),
      degrees: leftDeg,
      blade: theme.leftPaddleColor,
    );
    _paintPaddle(
      canvas,
      center: Offset(size.width - 15, center.dy),
      degrees: rightDeg,
      blade: theme.rightPaddleColor,
    );
    _paintBall(canvas, center + Offset(ballX, ballY));
  }

  void _paintPaddle(
    Canvas canvas, {
    required Offset center,
    required double degrees,
    required Color blade,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(degrees * math.pi / 180);

    const handleLength = 16.0;
    const handleWidth = 4.6;
    const bladeRadius = 9.5;

    final handleRect = Rect.fromCenter(
      center: const Offset(0, handleLength * 0.55),
      width: handleWidth,
      height: handleLength,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(2.3)),
      Paint()..color = theme.handleColor,
    );

    final collarRect = Rect.fromCenter(
      center: const Offset(0, handleLength * 0.18),
      width: handleWidth + 2.5,
      height: 3.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(collarRect, const Radius.circular(1.5)),
      Paint()..color = theme.handleCollarColor,
    );

    canvas.drawCircle(Offset.zero, bladeRadius, Paint()..color = blade);
    canvas.drawCircle(
      Offset.zero,
      bladeRadius,
      Paint()
        ..color = const Color(0x400B1220)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(-3.2, -3.6),
        width: 6.4,
        height: 5.2,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.26),
    );

    canvas.restore();
  }

  void _paintBall(Canvas canvas, Offset position) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: theme.ballGradientColors,
        stops: theme.ballGradientStops,
      ).createShader(Rect.fromCircle(center: position, radius: 6.5));

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: position, radius: 6.5)),
      Colors.black.withValues(alpha: 0.4),
      3,
      false,
    );
    canvas.drawCircle(position, 6.5, paint);
  }

  @override
  bool shouldRepaint(_PongPainter old) =>
      old.progress != progress ||
      old.rallying != rallying ||
      old.rallyT != rallyT;
}

double _lerpKeyframes(double t, List<(double, double)> stops) {
  for (var i = 0; i < stops.length - 1; i++) {
    final (t0, v0) = stops[i];
    final (t1, v1) = stops[i + 1];
    if (t >= t0 && t <= t1) {
      final k = t1 == t0 ? 0.0 : (t - t0) / (t1 - t0);
      return v0 + (v1 - v0) * k;
    }
  }
  return stops.last.$2;
}

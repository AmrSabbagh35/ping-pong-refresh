# ping_pong_refresh

A Cupertino pull-to-refresh sliver with an animated ping-pong rally.

Drop `PingPongRefresh` into any `CustomScrollView` as a zero-dependency replacement for `CupertinoSliverRefreshControl`.

## Features

- Ball winds up between two paddles as you pull down
- Paddles rally the ball back and forth while your refresh is in flight
- Haptic feedback fires when the pull arms and when the refresh completes
- Fully themeable — swap paddle colors, ball gradient, and label color
- Ships a light theme and a dark theme out of the box
- Zero external dependencies

## Usage

```dart
import 'package:ping_pong_refresh/ping_pong_refresh.dart';

CustomScrollView(
  slivers: [
    PingPongRefresh(
      onRefresh: () => runWithMinPingPongDuration(() async {
        await myRepo.reload();
      }),
    ),
    // ... your other slivers
  ],
)
```

### Custom theme

```dart
PingPongRefresh(
  theme: PingPongTheme(
    leftPaddleColor: Colors.orange,
    rightPaddleColor: Colors.purple,
  ),
  onRefresh: () async { /* ... */ },
)
```

### Light theme preset

```dart
PingPongRefresh(
  theme: PingPongTheme.light(),
  onRefresh: () async { /* ... */ },
)
```

### Disable haptics

```dart
PingPongRefresh(
  enableHaptics: false,
  onRefresh: () async { /* ... */ },
)
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `onRefresh` | `RefreshCallback` | required | Called when the user triggers a refresh |
| `theme` | `PingPongTheme` | `PingPongTheme()` | Colors for paddles, ball, and label |
| `enableHaptics` | `bool` | `true` | Whether to fire haptic feedback |

## PingPongTheme

| Property | Default |
|---|---|
| `leftPaddleColor` | `Color(0xFFC0F500)` — neon lime |
| `rightPaddleColor` | `Color(0xFF2792FF)` — electric blue |
| `ballGradientColors` | white → lime gradient |
| `labelColor` | `Color(0xFFC4CAAC)` |
| `handleColor` | `Color(0xFFCC9E64)` — wood |
| `handleCollarColor` | `Color(0xFF9E7645)` — dark wood |

## runWithMinPingPongDuration

A convenience helper that ensures your refresh callback takes at least
`kPingPongMinRefreshDuration` (2 seconds) to complete, so the animation
is perceptible even on fast data sources.

```dart
onRefresh: () => runWithMinPingPongDuration(() async {
  await myRepo.reload();
})
```
# ping-pong-refresh

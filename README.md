# ping_pong_refresh

[![pub version](https://img.shields.io/pub/v/ping_pong_refresh.svg)](https://pub.dev/packages/ping_pong_refresh)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/AmrSabbagh35/ping-pong-refresh/blob/main/LICENSE)

A Cupertino pull-to-refresh sliver with an animated ping-pong rally. Drop it into any `CustomScrollView` as a zero-dependency replacement for `CupertinoSliverRefreshControl`.

<p align="center">
  <img src="https://raw.githubusercontent.com/AmrSabbagh35/ping-pong-refresh/main/assets/demo.gif" width="300" alt="ping_pong_refresh demo" />
</p>

---

## How it works

| Pull down | Armed | Refreshing |
|---|---|---|
| Ball winds up between two paddles tracking your drag | Haptic fires, paddles are fully open | Paddles rally the ball back and forth until your callback completes |

- **Drag** — ball slides from left paddle to right as you pull, paddles rotate open
- **Armed** — selection haptic fires the moment you hit the trigger threshold
- **Refreshing** — ball bounces back and forth in a looping rally animation
- **Done** — light haptic fires, animation stops, list springs back

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ping_pong_refresh: ^0.1.0
```

Then run:

```sh
flutter pub get
```

---

## Basic usage

```dart
import 'package:ping_pong_refresh/ping_pong_refresh.dart';

CustomScrollView(
  slivers: [
    PingPongRefresh(
      onRefresh: () async {
        await myRepo.reload();
      },
    ),
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => ListTile(title: Text(items[i])),
    ),
  ],
)
```

### Keep the animation visible on fast data sources

Wrap your callback with `runWithMinPingPongDuration` to guarantee the rally
plays for at least 2 seconds — otherwise it flashes past on cached or instant
responses:

```dart
PingPongRefresh(
  onRefresh: () => runWithMinPingPongDuration(() async {
    await myRepo.reload();
  }),
)
```

---

## Theming

### Dark (default)

```dart
PingPongRefresh(
  theme: PingPongTheme(), // neon lime + electric blue
  onRefresh: () async { ... },
)
```

### Light preset

```dart
PingPongRefresh(
  theme: PingPongTheme.light(), // green + blue on white
  onRefresh: () async { ... },
)
```

### Fully custom

```dart
PingPongRefresh(
  theme: PingPongTheme(
    leftPaddleColor: Colors.orange,
    rightPaddleColor: Colors.purple,
    ballGradientColors: [Colors.white, Colors.orange],
    ballGradientStops: [0.4, 1.0],
    labelColor: Colors.grey,
    handleColor: Color(0xFFBCAAA4),
    handleCollarColor: Color(0xFF8D6E63),
  ),
  onRefresh: () async { ... },
)
```

---

## Disable haptics

```dart
PingPongRefresh(
  enableHaptics: false,
  onRefresh: () async { ... },
)
```

---

## API reference

### PingPongRefresh

| Parameter | Type | Default | Description |
|---|---|---|---|
| `onRefresh` | `RefreshCallback` | required | Called when the user triggers a refresh |
| `theme` | `PingPongTheme` | `PingPongTheme()` | Visual configuration |
| `enableHaptics` | `bool` | `true` | Haptic on arm + on complete |

### PingPongTheme

| Property | Type | Default |
|---|---|---|
| `leftPaddleColor` | `Color` | `Color(0xFFC0F500)` — neon lime |
| `rightPaddleColor` | `Color` | `Color(0xFF2792FF)` — electric blue |
| `ballGradientColors` | `List<Color>` | white → lime |
| `ballGradientStops` | `List<double>` | `[0.38, 0.78, 1.0]` |
| `labelColor` | `Color` | `Color(0xFFC4CAAC)` |
| `handleColor` | `Color` | `Color(0xFFCC9E64)` — wood |
| `handleCollarColor` | `Color` | `Color(0xFF9E7645)` — dark wood |

### Helpers

| Symbol | Description |
|---|---|
| `runWithMinPingPongDuration(action)` | Runs `action` but ensures at least `kPingPongMinRefreshDuration` (2s) elapses |
| `kPingPongMinRefreshDuration` | `Duration(seconds: 2)` |

---

## Preview

<p align="center">
  <video src="assets/sample.mp4" width="300" autoplay loop muted playsinline></video>
</p>


---

## Preview

<p align="center">
  <img src="https://raw.githubusercontent.com/AmrSabbagh35/ping-pong-refresh/main/assets/preview.gif" width="300" alt="ping_pong_refresh in action" />
</p>

---

## Requirements

- Flutter `>=3.24.0`
- Dart `>=3.5.0`
- Works on iOS and Android. The Cupertino pull gesture is native on iOS; on Android it overlays naturally inside a `CustomScrollView`.

---

## License

MIT © [Amr Sabbagh](https://github.com/AmrSabbagh35)

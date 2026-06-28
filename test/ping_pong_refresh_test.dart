import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong_refresh/ping_pong_refresh.dart';

void main() {
  testWidgets('PingPongRefresh renders inside CustomScrollView', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CustomScrollView(
          slivers: [
            PingPongRefresh(onRefresh: () async {}),
            const SliverToBoxAdapter(child: SizedBox(height: 1000)),
          ],
        ),
      ),
    );
    expect(find.byType(PingPongRefresh), findsOneWidget);
  });

  testWidgets('PingPongRefresh accepts custom theme', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CustomScrollView(
          slivers: [
            PingPongRefresh(
              theme: const PingPongTheme(
                leftPaddleColor: Color(0xFFFF5722),
                rightPaddleColor: Color(0xFF9C27B0),
              ),
              onRefresh: () async {},
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 1000)),
          ],
        ),
      ),
    );
    expect(find.byType(PingPongRefresh), findsOneWidget);
  });

  test('runWithMinPingPongDuration completes', () async {
    var called = false;
    await runWithMinPingPongDuration(() async {
      called = true;
    });
    expect(called, isTrue);
  });
}

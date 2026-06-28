import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ping_pong_refresh/ping_pong_refresh.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _darkTheme = PingPongTheme();
  static const _lightTheme = PingPongTheme.light();

  bool _useDark = true;
  List<String> _items = List.generate(20, (i) => 'Item ${i + 1}');

  @override
  Widget build(BuildContext context) {
    final bg = _useDark ? const Color(0xFF0B141E) : Colors.white;
    final fg = _useDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text('PingPongRefresh', style: TextStyle(color: fg)),
        actions: [
          IconButton(
            icon: Icon(_useDark ? Icons.light_mode : Icons.dark_mode, color: fg),
            onPressed: () => setState(() => _useDark = !_useDark),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          PingPongRefresh(
            theme: _useDark ? _darkTheme : _lightTheme,
            onRefresh: () => runWithMinPingPongDuration(() async {
              await Future<void>.delayed(const Duration(milliseconds: 800));
              setState(() {
                _items = List.generate(
                  20,
                  (i) => 'Item ${i + 1} — refreshed at ${DateTime.now().second}s',
                );
              });
            }),
          ),
          SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(_items[i], style: TextStyle(color: fg)),
              leading: Icon(CupertinoIcons.sportscourt_fill, color: _useDark ? const Color(0xFFC0F500) : const Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
}

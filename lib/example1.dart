import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MemoryExample()));
}

final countProvider = StateNotifierProvider((_) => CountProvider(1));

final currentCount = Provider((ref) => ref.watch(countProvider.state));

class MemoryExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text("Riverpod Animation Example"),
          ),
          body: Column(
            children: [
              AnimatedWidget(),
              RaisedButton(
                  child: Text("Increment"),
                  onPressed: () {
                    context.read(countProvider).increment();
                  }),
            ],
          )),
    );
  }
}

class AnimatedWidget extends HookWidget {
  final Duration duration = const Duration(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    final _controller = useAnimationController(duration: duration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    var _count = useProvider(currentCount);
    useValueChanged(_count, (_, __) async {
      _controller.forward();
    });

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.green[300].withOpacity(_controller.value),
                  shape: BoxShape.circle),
              height: 200,
              width: 200,
              child: Center(
                  child: Text(
                _count.toString(),
                textScaleFactor: 5,
              )),
            ),
          );
        });
  }
}

class CountProvider extends StateNotifier<int> {
  CountProvider(int state) : super(state);

  void increment() {
    state += 1;
  }
}

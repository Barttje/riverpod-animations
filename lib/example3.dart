import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MemoryExample()));
}

class BooleanNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}

final booleanProvider = NotifierProvider<BooleanNotifier, bool>(() {
  return BooleanNotifier();
});

final booleanState = Provider((ref) => ref.watch(booleanProvider));

class MemoryExample extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(booleanProvider.notifier);
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
                child: Text("Rotate"),
                onPressed: () {
                  notifier.toggle();
                }),
          ],
        ),
      ),
    );
  }
}

class AnimatedWidget extends HookConsumerWidget {
  final Duration duration = const Duration(seconds: 1);

  Color getColor(bool isUp) {
    if (isUp) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  IconData getIcon(bool isUp) {
    if (isUp) {
      return Icons.arrow_upward;
    }
    return Icons.arrow_downward;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _controller =
        useAnimationController(duration: duration, initialValue: 1);

    var _isUp = ref.watch(booleanState);
    final isUp = useState(_isUp);

    useValueChanged(_isUp, (_, __) async {
      await _controller.reverse();
      isUp.value = _isUp;
      await _controller.forward();
    });

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.rotationX((1 - _controller.value) * pi / 2),
          alignment: Alignment.center,
          child: Container(
            height: 100,
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: getColor(isUp.value),
                border: Border.all(color: Colors.grey)),
            child: Icon(
              getIcon(isUp.value),
              size: 40,
              color: Colors.white70,
            ),
          ),
        );
      },
    );
  }
}

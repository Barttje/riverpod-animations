import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MemoryExample()));
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
  const MemoryExample({super.key});

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
          title: const Text("Riverpod Animation Example"),
        ),
        body: Column(
          children: [
            const AnimatedWidget(),
            ElevatedButton(
              child: const Text("Toggle"),
              onPressed: () {
                notifier.toggle();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedWidget extends HookConsumerWidget {
  final Duration duration = const Duration(milliseconds: 1000);
  static double containerWidth = 200;
  static double circleRadius = 25;
  static double beginPoint = (containerWidth / 2 - circleRadius / 2) * -1;
  static double endPoint = (containerWidth / 2 - circleRadius / 2);

  const AnimatedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
        duration: duration, lowerBound: beginPoint, upperBound: endPoint, initialValue: beginPoint);

    final boolState = ref.watch(booleanState);
    useValueChanged<bool, Function(bool, bool)>(boolState, (_, __) {
      if (boolState) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    });

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(10),
            height: containerWidth,
            width: containerWidth,
            decoration: BoxDecoration(color: Colors.white70, border: Border.all(color: Colors.green)),
            child: Transform.translate(
              offset: Offset(controller.value, 0),
              child: Align(
                child: Container(
                  width: circleRadius,
                  height: circleRadius,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

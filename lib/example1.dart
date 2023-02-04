import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MemoryExample()));
}

final countProvider = StateNotifierProvider((_) => CountProvider(1));

final currentCount = Provider((ref) => ref.watch(countProvider));

class MemoryExample extends HookConsumerWidget {
  const MemoryExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(countProvider.notifier);
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
              child: const Text("Increment"),
              onPressed: () {
                notifier.increment();
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

  const AnimatedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(duration: duration);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      }
    });

    var count = ref.watch(currentCount);
    useValueChanged(count, (_, __) async {
      controller.forward();
    });

    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: Colors.green[300]!.withOpacity(controller.value), shape: BoxShape.circle),
              height: 200,
              width: 200,
              child: Center(
                  child: Text(
                count.toString(),
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

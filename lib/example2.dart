import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MemoryExample()));
}

class BooleanNotifier extends StateNotifier<bool> {
  BooleanNotifier(bool state) : super(state);

  void toggle() {
    state = !state;
  }
}

final booleanProvider = StateNotifierProvider((_) => BooleanNotifier(false));

final booleanState = Provider((ref) => ref.watch(booleanProvider.state));

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
                  child: Text("Toggle"),
                  onPressed: () {
                    context.read(booleanProvider).toggle();
                  }),
            ],
          )),
    );
  }
}

class AnimatedWidget extends HookWidget {
  final Duration duration = const Duration(milliseconds: 1000);
  static double containerWidth = 200;
  static double circleRadius = 25;
  static double beginPoint = (containerWidth / 2 - circleRadius / 2) * -1;
  static double endPoint = (containerWidth / 2 - circleRadius / 2);

  @override
  Widget build(BuildContext context) {
    final _controller = useAnimationController(
        duration: duration,
        lowerBound: beginPoint,
        upperBound: endPoint,
        initialValue: beginPoint);

    var _boolState = useProvider(booleanState);
    useValueChanged(_boolState, (_, __) {
      if (_boolState) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Container(
              margin: EdgeInsets.all(10),
              height: containerWidth,
              width: containerWidth,
              decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(color: Colors.green)),
              child: Transform.translate(
                offset: Offset(_controller.value, 0),
                child: Align(
                  child: Container(
                    width: circleRadius,
                    height: circleRadius,
                    decoration: BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

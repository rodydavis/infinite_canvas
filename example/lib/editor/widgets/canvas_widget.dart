import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

typedef Knobs = Map<String, ReadOnlyKnob>;

typedef CanvasWidget = InfiniteCanvasNode<Knobs>;

class ReadOnlyKnob<T> {
  ReadOnlyKnob({
    required this.type,
    required this.label,
    required this.value,
  });

  final KnobType type;
  final String label;
  final T value;
}

class Knob<T> extends ReadOnlyKnob<T> {
  Knob({
    required super.type,
    required super.label,
    required T value,
  })  : notifier = ValueNotifier<T>(value),
        super(value: value);

  late final ValueNotifier<T> notifier;

  @override
  T get value => notifier.value;

  set value(T value) {
    notifier.value = value;
  }
}

enum KnobType {
  bool,
  int,
  double,
  string,
  color,
  offset,
  size,
  rect,
}

extension KnobsExtension on Knobs {
  K knob<K extends ReadOnlyKnob>(String key) {
    final knob = this[key];
    if (knob is K) {
      return knob;
    } else {
      throw Exception('Knob $key is not of type $K');
    }
  }

  T value<T>(String key) {
    final knob = this[key];
    if (knob is ReadOnlyKnob<T>) {
      return knob.value;
    } else {
      throw Exception('Knob $key is not of type $T');
    }
  }
}

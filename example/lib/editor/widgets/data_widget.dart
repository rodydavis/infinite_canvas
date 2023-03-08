import 'package:flutter/material.dart';

class DataWidget<T> extends StatefulWidget {
  const DataWidget({
    Key? key,
    required this.data,
    required this.builder,
  }) : super(key: key);

  final T data;
  final Widget Function(BuildContext context, T data, ValueChanged<T> update)
      builder;

  @override
  State<DataWidget<T>> createState() => _DataWidgetState<T>();
}

class _DataWidgetState<T> extends State<DataWidget<T>> {
  late T data = widget.data;

  @override
  void didUpdateWidget(covariant DataWidget<T> oldWidget) {
    if (oldWidget.data != widget.data) {
      if (mounted) {
        setState(() {
          data = widget.data;
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, data, (value) {
      if (mounted) {
        setState(() {
          data = value;
        });
      }
    });
  }
}

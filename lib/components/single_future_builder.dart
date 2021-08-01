import 'package:flutter/material.dart';

class SingleFutureBuilder extends StatelessWidget {
  final Widget Function(BuildContext, dynamic) childBuilder;
  final bool condition;
  final Future future;
  final dynamic fallbackData;

  const SingleFutureBuilder({
    Key? key,
    required this.childBuilder,
    required this.condition,
    required this.future,
    this.fallbackData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return childBuilder.call(context, fallbackData);
    }
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return childBuilder.call(context, snapshot.data);
      },
    );
  }
}

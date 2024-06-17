import 'package:flutter/material.dart';

class CustomStreamBuilder<T> extends StatelessWidget {
  const CustomStreamBuilder({
    super.key,
    required this.stream,
    required this.onLoaded,
    this.onError,
    this.onLoading,
  });

  final Stream<T?> stream;
  final Widget Function(T instance) onLoaded;
  final Widget Function(String error)? onError;
  final Widget Function()? onLoading;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return onLoaded(snapshot.data as T);
          } else if (snapshot.hasError) {
            return Center(
                child: onError?.call(snapshot.error.toString()) ??
                    Text(snapshot.error.toString()));
          } else {
            return onLoading?.call() ??
                const Center(
                  child: CircularProgressIndicator(),
                );
          }
        });
  }
}

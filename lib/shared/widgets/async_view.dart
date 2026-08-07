import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';

/// Renders an [AsyncValue] with the app's shared loading and error treatments,
/// so every screen fails the same way instead of inventing its own.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    required this.onRetry,
    this.loadingHeights = const [120, 180, 220],
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback onRetry;

  /// Skeleton block heights, so the placeholder echoes the real layout.
  final List<double> loadingHeights;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => _Skeleton(heights: loadingHeights),
      error: (e, _) => _ErrorState(
        message: '$e'.replaceFirst('Exception: ', ''),
        onRetry: onRetry,
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.heights});
  final List<double> heights;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IgnorePointer(
      child: Column(
        children: [
          for (final h in heights)
            Container(
              height: h,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: t.sub, size: 38),
          const SizedBox(height: 14),
          Text(
            'Could not load this screen',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.sub, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: t.primary),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

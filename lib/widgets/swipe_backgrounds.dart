import 'package:flutter/material.dart';

/// Shared backgrounds for swipe-to-act rows:
/// swipe right (startToEnd) reveals [editSwipeBackground] = edit,
/// swipe left (endToStart) reveals [deleteSwipeBackground] = delete.

Widget editSwipeBackground(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return Container(
    color: scheme.secondaryContainer,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 20),
    child: Icon(Icons.edit_outlined, color: scheme.onSecondaryContainer),
  );
}

Widget deleteSwipeBackground(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return Container(
    color: scheme.errorContainer,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
  );
}

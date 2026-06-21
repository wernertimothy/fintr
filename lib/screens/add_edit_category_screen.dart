import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';
import '../models/category.dart';

/// Curated palette and icon set so the picker stays simple and the icons are
/// referenced as constants (keeps them through icon tree-shaking on release
/// builds).
const List<Color> _palette = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.blueGrey,
];

const List<IconData> _icons = [
  Icons.restaurant,
  Icons.shopping_cart,
  Icons.directions_bus,
  Icons.directions_car,
  Icons.home,
  Icons.bolt,
  Icons.local_activity,
  Icons.sports_esports,
  Icons.fitness_center,
  Icons.medical_services,
  Icons.school,
  Icons.pets,
  Icons.flight,
  Icons.checkroom,
  Icons.coffee,
  Icons.savings,
  Icons.phone_android,
  Icons.subscriptions,
];

class AddEditCategoryScreen extends StatefulWidget {
  const AddEditCategoryScreen({super.key, this.existing});

  final Category? existing;

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _limitController;
  late int _colorValue;
  late int _iconCodePoint;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _limitController = TextEditingController(
      text: e != null ? e.monthlyLimit.toString() : '',
    );
    _colorValue = e?.colorValue ?? _palette.first.toARGB32();
    _iconCodePoint = e?.iconCodePoint ?? _icons.first.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  static double? _parseLimit(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<FinanceRepository>();
    final name = _nameController.text.trim();
    final limit = _parseLimit(_limitController.text)!;

    if (_isEditing) {
      await repo.updateCategory(widget.existing!.copyWith(
        name: name,
        monthlyLimit: limit,
        colorValue: _colorValue,
        iconCodePoint: _iconCodePoint,
      ));
    } else {
      await repo.addCategory(
        name: name,
        monthlyLimit: limit,
        colorValue: _colorValue,
        iconCodePoint: _iconCodePoint,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(_colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit category' : 'New category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(
                labelText: 'Monthly limit',
                suffixText: '€',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final limit = _parseLimit(v ?? '');
                if (limit == null) return 'Enter a valid number';
                if (limit <= 0) return 'Limit must be positive';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in _palette)
                  _SwatchButton(
                    color: color,
                    selected: color.toARGB32() == _colorValue,
                    onTap: () =>
                        setState(() => _colorValue = color.toARGB32()),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Icon', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final icon in _icons)
                  _IconButton(
                    icon: icon,
                    color: selectedColor,
                    selected: icon.codePoint == _iconCodePoint,
                    onTap: () =>
                        setState(() => _iconCodePoint = icon.codePoint),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Create category'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchButton extends StatelessWidget {
  const _SwatchButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(icon, color: selected ? color : null, size: 22),
      ),
    );
  }
}

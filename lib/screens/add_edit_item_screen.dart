import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';
import '../models/expense_item.dart';

/// Add a new expense, or edit an existing one when [existing] is provided.
class AddEditItemScreen extends StatefulWidget {
  const AddEditItemScreen({super.key, this.existing});

  final ExpenseItem? existing;

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  String? _categoryId;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toString() : '',
    );
    _categoryId = existing?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<FinanceRepository>();
    final name = _nameController.text.trim();
    final amount = _parseAmount(_amountController.text)!;
    final categoryId = _categoryId!;

    if (_isEditing) {
      await repo.updateItem(widget.existing!
          .copyWith(name: name, amount: amount, categoryId: categoryId));
    } else {
      await repo.addItem(
          name: name, amount: amount, categoryId: categoryId);
    }
    if (mounted) Navigator.of(context).pop();
  }

  static double? _parseAmount(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FinanceRepository>();
    final categories = repo.categories;
    // Guard against a category that was deleted while editing.
    if (_categoryId != null &&
        !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit expense' : 'Add expense'),
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
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                suffixText: '€',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final amount = _parseAmount(v ?? '');
                if (amount == null) return 'Enter a valid number';
                if (amount <= 0) return 'Amount must be positive';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in categories)
                  DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(c.icon, color: c.color, size: 20),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? 'Pick a category' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Add expense'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  TransactionType _selectedType = TransactionType.expense;
  bool _hasInitializedCategory = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpense() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0 || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid title, amount, and category'),
        ),
      );
      return;
    }

    final expense = Expense(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      type: _selectedType,
    );

    ref.read(expenseProvider.notifier).addExpense(expense);
    Navigator.pop(context);
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    // Initialize selected category after first frame if not set and categories are available
    if (!_hasInitializedCategory &&
        _selectedCategoryId == null &&
        categories.isNotEmpty) {
      _hasInitializedCategory = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedCategoryId == null && categories.isNotEmpty) {
          setState(() {
            _selectedCategoryId = categories.first.id;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 50,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(DateFormat.yMd().format(_selectedDate)),
                      IconButton(
                        onPressed: _presentDatePicker,
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: categories.isNotEmpty && _selectedCategoryId != null
                  ? _selectedCategoryId
                  : null,
              items: categories.isEmpty
                  ? [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No categories available'),
                      ),
                    ]
                  : categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(category.icon, color: category.color),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: categories.isEmpty ? null : _submitExpense,
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

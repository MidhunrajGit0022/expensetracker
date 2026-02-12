import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_provider.dart';
import '../models/category.dart';
import '../models/expense.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool _isMonthly = true;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);
    final categories = ref.watch(categoriesProvider);

    // Filter expenses (only Expenses, ignore Income if any)
    final filteredExpenses = expenses.where((expense) {
      if (expense.type != TransactionType.expense) return false;

      if (_isMonthly) {
        return expense.date.month == _selectedDate.month &&
            expense.date.year == _selectedDate.year;
      } else {
        return expense.date.day == _selectedDate.day &&
            expense.date.month == _selectedDate.month &&
            expense.date.year == _selectedDate.year;
      }
    }).toList();

    final totalAmount = filteredExpenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    for (var expense in filteredExpenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Daily')),
                ButtonSegment(value: true, label: Text('Monthly')),
              ],
              selected: {_isMonthly},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _isMonthly = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              _isMonthly
                  ? DateFormat.yMMMM().format(_selectedDate)
                  : DateFormat.yMMMMd().format(_selectedDate),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (filteredExpenses.isEmpty)
              const Expanded(
                child: Center(child: Text('No expenses for this period.')),
              )
            else ...[
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: categoryTotals.entries.map((entry) {
                      final category = categories.firstWhere(
                        (c) => c.id == entry.key,
                        orElse: () => Category(
                          id: 'unknown',
                          name: 'Unknown',
                          color: Colors.grey,
                          icon: Icons.help_outline,
                        ),
                      );
                      final percentage = totalAmount > 0
                          ? (entry.value / totalAmount) * 100
                          : 0.0;

                      return PieChartSectionData(
                        color: category.color,
                        value: entry.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: categoryTotals.entries.map((entry) {
                    final category = categories.firstWhere(
                      (c) => c.id == entry.key,
                      orElse: () => Category(
                        id: 'unknown',
                        name: 'Unknown',
                        color: Colors.grey,
                        icon: Icons.help_outline,
                      ),
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.2),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 20,
                        ),
                      ),
                      title: Text(category.name),
                      trailing: Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}

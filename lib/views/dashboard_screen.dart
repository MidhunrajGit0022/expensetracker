import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart' hide Scaffold;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(expenseProvider);
    final isDark = ref.watch(themeProvider);

    // Filter to only show expenses (not income)
    final expenses = allTransactions
        .where((e) => e.type == TransactionType.expense)
        .toList();
    final totalAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);

    ref.listen<List<Expense>>(expenseProvider, (previous, next) {
      final expensesOnly = next
          .where((e) => e.type == TransactionType.expense)
          .toList();
      final newTotal = expensesOnly.fold(0.0, (sum, item) => sum + item.amount);
      final salary = ref.read(salaryProvider);
      if (salary > 0) {
        if (newTotal > salary) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert: You have exceeded your budget!'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (newTotal > salary * 0.9) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Warning: You are approaching your budget limit!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(context, totalAmount),
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses yet!'))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return _buildExpenseTile(ref, context, expense);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double total) {
    return Consumer(
      builder: (context, ref, child) {
        final salary = ref.watch(salaryProvider);
        final remaining = salary - total;
        final progress = salary > 0 ? (total / salary).clamp(0.0, 1.0) : 0.0;

        Color statusColor = Colors.green;
        String statusMessage = "On Track";
        if (total > salary) {
          statusColor = Colors.red;
          statusMessage = "Over Budget!";
        } else if (total > salary * 0.9) {
          statusColor = Colors.redAccent;
          statusMessage = "Critical: Near Budget Limit";
        } else if (total > salary * 0.75) {
          statusColor = Colors.orange;
          statusMessage = "Warning: High Spending";
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showSalaryDialog(context, ref, salary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Salary', style: TextStyle(color: Colors.grey)),
                        Text(
                          '\$${salary.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Spent', style: TextStyle(color: Colors.grey)),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusMessage,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Remaining: \$${remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: remaining < 0 ? Colors.red : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSalaryDialog(
    BuildContext context,
    WidgetRef ref,
    double currentSalary,
  ) {
    final controller = TextEditingController(text: currentSalary.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Salary'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newSalary = double.tryParse(controller.text) ?? 0.0;
              ref.read(salaryProvider.notifier).updateSalary(newSalary);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(
    WidgetRef ref,
    BuildContext context,
    Expense expense,
  ) {
    final categories = ref.read(categoriesProvider);
    final category = categories.isNotEmpty
        ? categories.firstWhere(
            (c) => c.id == expense.categoryId,
            orElse: () => categories.first,
          )
        : Category(
            id: 'unknown',
            name: 'Unknown',
            color: Colors.grey,
            icon: Icons.help_outline,
          );

    return Slidable(
      key: Key(expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _showDeleteConfirmation(context, ref, expense);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: category.color.withOpacity(0.2),
            child: Icon(category.icon, color: category.color),
          ),
          title: Text(
            expense.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat.yMMMd().format(expense.date),
            style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                .copyWith(
                  color: ref.watch(themeProvider)
                      ? Colors.white
                      : Colors.black54,
                ),
          ),
          trailing: Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Do you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(expenseProvider.notifier).deleteExpense(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/legacy.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/database_helper.dart';
import 'package:flutter/material.dart';

final categoriesProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
      return CategoryNotifier();
    });

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    state = categories;
  }

  Future<void> addCategory(Category category) async {
    await DatabaseHelper.instance.insertCategory(category);
    state = [...state, category];
  }

  Future<void> deleteCategory(String id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    state = state.where((c) => c.id != id).toList();
  }

  Future<void> updateCategory(Category category) async {
    await DatabaseHelper.instance.insertCategory(category);
    state = [
      for (final c in state)
        if (c.id == category.id) category else c,
    ];
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((
  ref,
) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final expenses = await DatabaseHelper.instance.getExpenses();
    state = expenses;
  }

  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.instance.insertExpense(expense);
    // Reload to ensure order and consistency, or just optimize by inserting at top
    // state = [expense, ...state]; // Optimistic update
    // But since we want consistent ordering from DB (date DESC), let's just reload or insert carefully.
    // simpler:
    state = [expense, ...state]..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteExpense(String id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    state = state.where((e) => e.id != id).toList();
  }
}

final salaryProvider = StateNotifierProvider<SalaryNotifier, double>((ref) {
  return SalaryNotifier();
});

class SalaryNotifier extends StateNotifier<double> {
  SalaryNotifier() : super(0.0) {
    loadSalary();
  }

  Future<void> loadSalary() async {
    final salary = await DatabaseHelper.instance.getSalary();
    state = salary;
  }

  Future<void> updateSalary(double newSalary) async {
    await DatabaseHelper.instance.setSalary(newSalary);
    state = newSalary;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final isDark = await DatabaseHelper.instance.getTheme();
    state = isDark;
  }

  Future<void> toggleTheme() async {
    final newMode = !state;
    await DatabaseHelper.instance.setTheme(newMode);
    state = newMode;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    loadLocale();
  }

  Future<void> loadLocale() async {
    final languageCode = await DatabaseHelper.instance.getLocale();
    state = Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    await DatabaseHelper.instance.setLocale(locale.languageCode);
    state = locale;
  }
}

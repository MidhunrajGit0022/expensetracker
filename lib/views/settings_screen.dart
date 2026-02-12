import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/expense_provider.dart';
import 'category_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final salary = ref.watch(salaryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.appearance, isDark),
          SwitchListTile(
            title: Text(l10n.darkMode),
            subtitle: Text(l10n.enableDarkTheme),
            value: isDark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.budget, isDark),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(l10n.monthlySalary),
            subtitle: Text('\$${salary.toStringAsFixed(2)}'),
            trailing: const Icon(Icons.edit),
            onTap: () => _showSalaryDialog(context, ref, salary, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add or remove expense categories'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.language, isDark),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              _getLanguageName(ref.watch(localeProvider).languageCode),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, ref, l10n),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.about, isDark),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.blueAccent : Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showSalaryDialog(
    BuildContext context,
    WidgetRef ref,
    double currentSalary,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: currentSalary.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setSalary),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.amount,
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newSalary = double.tryParse(controller.text) ?? 0.0;
              ref.read(salaryProvider.notifier).updateSalary(newSalary);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'ml':
        return 'മലയാളം (Malayalam)';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी (Hindi)'),
              value: 'hi',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('മലയാളം (Malayalam)'),
              value: 'ml',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

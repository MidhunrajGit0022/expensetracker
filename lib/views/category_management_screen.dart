import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../controllers/expense_provider.dart';
import '../models/category.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color.withOpacity(0.2),
              child: Icon(category.icon, color: category.color),
            ),
            title: Text(category.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmation(context, ref, category);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 16),
                const Text('Select Color'),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        Colors.red,
                        Colors.pink,
                        Colors.purple,
                        Colors.indigo,
                        Colors.blue,
                        Colors.teal,
                        Colors.green,
                        Colors.orange,
                        Colors.brown,
                        Colors.grey,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 15,
                            child: selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Select Icon'),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children:
                      [
                        Icons.fastfood,
                        Icons.directions_car,
                        Icons.shopping_bag,
                        Icons.movie,
                        Icons.medical_services,
                        Icons.school,
                        Icons.home,
                        Icons.work,
                        Icons.fitness_center,
                        Icons.flight,
                        Icons.pets,
                        Icons.celebration,
                      ].map((icon) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIcon == icon
                                  ? Colors.blue.withOpacity(0.2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: selectedIcon == icon ? Colors.blue : null,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final category = Category(
                    id: const Uuid().v4(),
                    name: name,
                    color: selectedColor,
                    icon: selectedIcon,
                  );
                  ref.read(categoriesProvider.notifier).addCategory(category);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

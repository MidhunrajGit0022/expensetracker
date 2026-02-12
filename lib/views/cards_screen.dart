import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/expense_provider.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Cards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Card feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCreditCard(
            context,
            color: const Color(0xFF1E1E1E),
            bankName: 'Universal Bank',
            cardNumber: '**** **** **** 1234',
            expiry: '12/26',
            holderName: 'ALEX JOHNSON',
            balance: 12500.50,
            cardType: 'VISA',
          ),
          const SizedBox(height: 20),
          _buildCreditCard(
            context,
            color: const Color(0xFF0056D2),
            bankName: 'City Bank',
            cardNumber: '**** **** **** 5678',
            expiry: '09/25',
            holderName: 'ALEX JOHNSON',
            balance: 3420.00,
            cardType: 'MasterCard',
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(
    BuildContext context, {
    required Color color,
    required String bankName,
    required String cardNumber,
    required String expiry,
    required String holderName,
    required double balance,
    required String cardType,
  }) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bankName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                cardType,
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'Balance',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                holderName,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                expiry,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.transactions.length,
        itemBuilder: (_, index) {
          final t = provider.transactions[index];

          return Card(
            child: ListTile(
              title: Text(t.title),
              subtitle: Text(t.type.name),
              trailing: Text(
                'R\$ ${t.amount}',
                style: TextStyle(
                  color: t.type == TransactionType.income
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
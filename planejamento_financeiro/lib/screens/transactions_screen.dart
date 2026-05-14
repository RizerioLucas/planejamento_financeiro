import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final list = provider.transactions.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Extrato')),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, index) {
          final t = list[index];
          final isPositive = t.type == TransactionType.income || t.type == TransactionType.yield;
          return ListTile(
            title: Text(t.title),
            subtitle: Text("${t.date.day}/${t.date.month}/${t.date.year} - ${t.type.name}"),
            trailing: Text(
              'R\$ ${t.amount.toStringAsFixed(2)}',
              style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
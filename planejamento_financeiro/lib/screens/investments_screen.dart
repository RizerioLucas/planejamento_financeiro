import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/investment_model.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  final List<Investment> investmentsList = const [
    Investment(name: 'Bitcoin', price: 1000),
    Investment(name: 'Tesouro Direto', price: 100),
    Investment(name: 'Ação XPTO', price: 50),
  ];

  void buyInvestment(BuildContext context, Investment inv) {
    final provider =
        Provider.of<TransactionProvider>(context, listen: false);

    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Comprar ${inv.name}'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantidade'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              final total = inv.price * qty;

              if (!provider.canSpend(total)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saldo insuficiente'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              provider.addTransaction(
                TransactionItem(
                  title: inv.name,
                  amount: total,
                  type: TransactionType.investment,
                ),
              );

              Navigator.pop(context);
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investimentos')),
      body: ListView.builder(
        itemCount: investmentsList.length,
        itemBuilder: (_, index) {
          final inv = investmentsList[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(inv.name),
              subtitle: Text('R\$ ${inv.price} por unidade'),
              trailing: ElevatedButton(
                onPressed: () => buyInvestment(context, inv),
                child: const Text('Comprar'),
              ),
            ),
          );
        },
      ),
    );
  }
}
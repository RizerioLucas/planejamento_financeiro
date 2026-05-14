import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class InvestmentAsset {
  final String name;
  final double annualRate;
  final IconData icon;
  const InvestmentAsset({required this.name, required this.annualRate, required this.icon});
}

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  final List<InvestmentAsset> fixedAssets = const [
    InvestmentAsset(name: 'Tesouro Selic', annualRate: 13.75, icon: Icons.account_balance),
    InvestmentAsset(name: 'Poupança', annualRate: 6.17, icon: Icons.savings),
    InvestmentAsset(name: 'Ações (Dividendos)', annualRate: 10.0, icon: Icons.show_chart),
    InvestmentAsset(name: 'CDB Fixo', annualRate: 12.0, icon: Icons.speed),
  ];

  void _openActionDialog(BuildContext context, InvestmentAsset asset) {
    final amountController = TextEditingController();
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.name),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Valor (R\$)'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final val = double.tryParse(amountController.text) ?? 0;
              if (val > 0 && provider.canSpend(val)) {
                provider.addTransaction(TransactionItem(
                  title: 'Investimento: ${asset.name}',
                  amount: val,
                  type: TransactionType.investment,
                  date: DateTime.now(),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Investir'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(amountController.text) ?? 0;
              if (val <= 0) return;

              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              
              if (picked != null) {
                provider.simulateYield(val, asset.annualRate, picked);
                Navigator.pop(context);
              }
            },
            child: const Text('Simular'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mercado de Investimentos')),
      body: Column(
        children: [
          // 🔹 Cabeçalho com os dois valores
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Card de Investido
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Text('Investido', style: TextStyle(fontSize: 12)),
                        Text(
                          'R\$ ${provider.totalInvested.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Card de Simulado (EM AZUL)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Column(
                      children: [
                        const Text('Simulado', style: TextStyle(fontSize: 12)),
                        Text(
                          'R\$ ${provider.totalSimulated.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: fixedAssets.length,
              itemBuilder: (context, index) {
                final asset = fixedAssets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(asset.icon, color: Colors.green),
                    title: Text(asset.name),
                    subtitle: Text('Taxa fixa: ${asset.annualRate}% a.a'),
                    onTap: () => _openActionDialog(context, asset),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
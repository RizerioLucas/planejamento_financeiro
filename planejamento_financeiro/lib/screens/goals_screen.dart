import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  // 🔹 Criar nova meta
  void createGoal(BuildContext context) {
    final provider =
        Provider.of<TransactionProvider>(context, listen: false);

    final nameController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome da meta'),
            ),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Valor alvo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final target =
                  double.tryParse(valueController.text) ?? 0.0;

              provider.addGoal(
                nameController.text,
                target,
              );

              Navigator.pop(context);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  // 🔹 Adicionar dinheiro na meta
  void addMoney(BuildContext context, int index) {
    final provider =
        Provider.of<TransactionProvider>(context, listen: false);

    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar dinheiro'),
        content: TextField(
          controller: valueController,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: 'Valor'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final amount =
                  double.tryParse(valueController.text) ?? 0.0;

              // 🔴 valida saldo
              if (!provider.canSpend(amount)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saldo insuficiente'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              provider.addMoneyToGoal(index, amount);

              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createGoal(context),
        child: const Icon(Icons.add),
      ),
      body: provider.goals.isEmpty
          ? const Center(
              child: Text('Nenhuma meta criada'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.goals.length,
              itemBuilder: (_, index) {
                final g = provider.goals[index];

                // ✅ FIX DO ERRO AQUI
                final double progress = g.target == 0
                    ? 0.0
                    : (g.current / g.target).clamp(0.0, 1.0);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        LinearProgressIndicator(
                          value: progress,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'R\$ ${g.current.toStringAsFixed(2)} / ${g.target.toStringAsFixed(2)}',
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () =>
                                addMoney(context, index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
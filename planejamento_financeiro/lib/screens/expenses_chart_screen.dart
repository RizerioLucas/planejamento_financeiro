import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/transaction_provider.dart';

class ExpensesChartScreen extends StatefulWidget {
  const ExpensesChartScreen({super.key});

  @override
  State<ExpensesChartScreen> createState() =>
      _ExpensesChartScreenState();
}

class _ExpensesChartScreenState extends State<ExpensesChartScreen> {
  bool showExtract = false;

  final TextEditingController valueController =
      TextEditingController();

  String selectedCategory = 'Mercado';

  final List<String> categories = [
    'Mercado',
    'Luz',
    'Aluguel',
    'Transporte',
    'Lazer',
    'Outros'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    final expenses = provider.transactions
        .where((t) =>
            t.type == TransactionType.expense ||
            t.type == TransactionType.transfer ||
            t.type == TransactionType.investment ||
            t.type == TransactionType.goal)
        .toList();

    final Map<String, double> grouped = {};

    for (var e in expenses) {
      grouped[e.title] = (grouped[e.title] ?? 0) + e.amount;
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);

    final list = provider.transactions.reversed.toList();

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                showExtract = !showExtract;
              });
            },
            child: Text(
              showExtract ? 'Gráfico' : 'Extrato',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔥 INPUT DE GASTO
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField(
                  value: selectedCategory,
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value as String;
                    });
                  },
                  decoration:
                      const InputDecoration(labelText: 'Categoria'),
                ),

                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Valor'),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final value =
                          double.tryParse(valueController.text) ??
                              0;

                      provider.addExpense(
                        value,
                        title: selectedCategory,
                      );

                      valueController.clear();
                    },
                    child: const Text('Adicionar Gasto'),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: showExtract
                // 🔥 EXTRATO
                ? ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      final t = list[index];

                      final isPositive =
                          t.type == TransactionType.income;

                      return ListTile(
                        title: Text(t.title),
                        subtitle: Text(t.type.name),
                        trailing: Text(
                          'R\$ ${t.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isPositive
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  )

                // 🔥 GRÁFICO
                : total == 0
                    ? const Center(child: Text('Sem despesas ainda'))
                    : Column(
                        children: [
                          const SizedBox(height: 10),

                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: grouped.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final data = entry.value;

                                  final value = data.value;
                                  final percent =
                                      (value / total) * 100;

                                  return PieChartSectionData(
                                    value: value,
                                    title:
                                        '${percent.toStringAsFixed(1)}%',
                                    radius: 50,
                                    color: colors[
                                        index % colors.length],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Expanded(
                            child: ListView(
                              children: grouped.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final e = entry.value;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: colors[
                                        index % colors.length],
                                    radius: 6,
                                  ),
                                  title: Text(e.key),
                                  trailing: Text(
                                      'R\$ ${e.value.toStringAsFixed(2)}'),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
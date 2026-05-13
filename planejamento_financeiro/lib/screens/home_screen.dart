import 'package:flutter/material.dart';
import '../widgets/summary_card.dart';
import 'transactions_screen.dart';
import 'goals_screen.dart';
import 'investments_screen.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(),
    const TransactionsScreen(),
    const GoalsScreen(),
    const InvestmentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transações',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Investimentos',
          ),
        ],
      ),
    );
  }
}
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Financeiro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SummaryCard(
              title: 'Saldo',
              value: 'R\$ ${provider.balance.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
            ),
            const SizedBox(height: 16),
            SummaryCard(
              title: 'Receitas',
              value: 'R\$ ${provider.totalIncome.toStringAsFixed(2)}',
              icon: Icons.arrow_upward,
            ),
            const SizedBox(height: 16),
            SummaryCard(
              title: 'Despesas',
              value: 'R\$ ${provider.totalExpense.toStringAsFixed(2)}',
              icon: Icons.arrow_downward,
            ),
            const SizedBox(height: 16),
            SummaryCard(
              title: 'Investido',
              value: 'R\$ ${provider.totalInvested.toStringAsFixed(2)}',
              icon: Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }
}
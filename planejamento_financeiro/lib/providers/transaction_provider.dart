import 'package:flutter/material.dart';

enum TransactionType { income, expense, transfer, investment, goal, yield }

class TransactionItem {
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;

  TransactionItem({
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });
}

class Goal {
  final String name;
  final double target;
  double current;
  Goal({required this.name, required this.target, this.current = 0});
}

class TransactionProvider extends ChangeNotifier {
  final List<TransactionItem> _transactions = [
    TransactionItem(title: 'Saldo Inicial', amount: 5000, type: TransactionType.income, date: DateTime.now()),
  ];
  final List<Goal> _goals = [];

  List<TransactionItem> get transactions => _transactions;
  List<Goal> get goals => _goals;

  void addTransaction(TransactionItem transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void addGoal(String name, double target) {
    _goals.add(Goal(name: name, target: target));
    notifyListeners();
  }

  void addMoneyToGoal(int index, double value) {
    if (!canSpend(value)) return;
    _goals[index].current += value;
    addTransaction(TransactionItem(
      title: 'Meta: ${_goals[index].name}',
      amount: value,
      type: TransactionType.goal,
      date: DateTime.now(),
    ));
  }

  void simulateYield(double amount, double annualRate, DateTime targetDate) {
    final now = DateTime.now();
    final days = targetDate.difference(now).inDays;
    if (days <= 0) return;

    double dailyRate = (annualRate / 100) / 365;
    double yieldAmount = amount * dailyRate * days;

    addTransaction(TransactionItem(
      title: 'Rendimento Simulado (${annualRate}% a.a)',
      amount: yieldAmount,
      type: TransactionType.yield,
      date: targetDate,
    ));
  }

  bool canSpend(double value) => balance >= value;

  // 🔹 Pega apenas o que foi simulado (tipo yield)
  double get totalSimulated => _transactions
      .where((t) => t.type == TransactionType.yield)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income || t.type == TransactionType.yield)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense || t.type == TransactionType.transfer)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalInvested => _transactions
      .where((t) => t.type == TransactionType.investment)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalGoals => _transactions
      .where((t) => t.type == TransactionType.goal)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get balance => totalIncome - totalExpense - totalInvested - totalGoals;
}
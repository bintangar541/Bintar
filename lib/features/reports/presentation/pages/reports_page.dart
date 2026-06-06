import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final currentTimeFrame = ref.watch(timeFrameProvider);

    List<dynamic> filteredTransactions = [];
    if (transactionsAsync.hasValue && transactionsAsync.value != null) {
      final allTx = transactionsAsync.value!;
      final now = DateTime.now();
      
      filteredTransactions = allTx.where((tx) {
        final timestamp = DateTime.parse(tx['timestamp']);
        switch (currentTimeFrame) {
          case TimeFrame.weekly:
            return now.difference(timestamp).inDays <= 7;
          case TimeFrame.monthly:
            return timestamp.month == now.month && timestamp.year == now.year;
          case TimeFrame.yearly:
            return timestamp.year == now.year;
        }
      }).toList();
    }

    double income = 0;
    double expense = 0;
    Map<String, double> categoryAmounts = {};

    for (var tx in filteredTransactions) {
      final amount = (tx['amount'] as num).toDouble();
      if (amount > 0) {
        income += amount;
      } else {
        final absAmount = amount.abs();
        expense += absAmount;
        final cat = tx['category'] ?? 'Lainnya';
        categoryAmounts[cat] = (categoryAmounts[cat] ?? 0) + absAmount;
      }
    }

    final sortedCategories = categoryAmounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporan Keuangan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.darkText),
              ),
              const SizedBox(height: 4),
              Text(
                _getTimeFrameDescription(currentTimeFrame),
                style: TextStyle(fontSize: 14, color: AppTheme.subtleText),
              ),
              const SizedBox(height: 24),

              // Custom Tab Selector
              _buildTimeSelector(ref, currentTimeFrame),
              const SizedBox(height: 28),

              // Summary Cards Row
              Row(
                children: [
                  _buildSummaryCard(
                    'Pemasukan',
                    _formatCurrency(income),
                    Icons.arrow_downward_rounded,
                    AppTheme.emeraldGreen,
                  ),
                  const SizedBox(width: 16),
                  _buildSummaryCard(
                    'Pengeluaran',
                    _formatCurrency(expense),
                    Icons.arrow_upward_rounded,
                    AppTheme.accentRed,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Spending Breakdown
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Pengeluaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.darkText),
                    ),
                    const SizedBox(height: 20),
                    if (sortedCategories.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Tidak ada data di periode ini', style: TextStyle(color: AppTheme.subtleText)),
                        ),
                      )
                    else
                      ...sortedCategories.map((entry) {
                        final catColors = {
                          'Makanan': AppTheme.accentOrange,
                          'Transportasi': AppTheme.accentBlue,
                          'Hiburan': AppTheme.accentPurple,
                          'Belanja': AppTheme.accentRed,
                          'Tagihan': AppTheme.emeraldGreen,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _SpendingBar(
                            label: entry.key,
                            percent: expense > 0 ? entry.value / expense : 0,
                            amount: _formatCurrency(entry.value),
                            color: catColors[entry.key] ?? AppTheme.mutedText,
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeFrameDescription(TimeFrame frame) {
    switch (frame) {
      case TimeFrame.weekly:
        return 'Evaluasi pengeluaran 7 hari terakhir';
      case TimeFrame.monthly:
        return 'Rekap bulanan yang stabil';
      case TimeFrame.yearly:
        return 'Gambaran besar aset tahunan Anda';
    }
  }

  Widget _buildTimeSelector(WidgetRef ref, TimeFrame current) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildSelectorItem(ref, 'Mingguan', TimeFrame.weekly, current == TimeFrame.weekly),
          _buildSelectorItem(ref, 'Bulanan', TimeFrame.monthly, current == TimeFrame.monthly),
          _buildSelectorItem(ref, 'Tahunan', TimeFrame.yearly, current == TimeFrame.yearly),
        ],
      ),
    );
  }

  Widget _buildSelectorItem(WidgetRef ref, String label, TimeFrame value, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(timeFrameProvider.notifier).state = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.emeraldGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? AppTheme.emeraldShadow : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.subtleText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String amount, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: AppTheme.subtleText, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.darkText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingBar extends StatelessWidget {
  final String label;
  final double percent;
  final String amount;
  final Color color;

  const _SpendingBar({required this.label, required this.percent, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.darkText)),
            Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.darkText)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

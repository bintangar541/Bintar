import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Semua Transaksi',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📭', style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(color: AppTheme.mutedText, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          // Group transactions by date
          final Map<String, List<dynamic>> groupedTransactions = {};
          for (var tx in transactions) {
            final dateStr = tx['timestamp'].split('T')[0];
            if (!groupedTransactions.containsKey(dateStr)) {
              groupedTransactions[dateStr] = [];
            }
            groupedTransactions[dateStr]!.add(tx);
          }

          final sortedDates = groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateStr = sortedDates[index];
              final dateTxs = groupedTransactions[dateStr]!;
              final date = DateTime.parse(dateStr);
              final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                    child: Text(
                      isToday ? 'HARI INI' : DateFormat('EEEE, d MMMM y', 'id_ID').format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.subtleText,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...dateTxs.map((tx) => _buildTransactionTile(tx)).toList(),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.emeraldGreen)),
        error: (e, _) => Center(child: Text('Gagal memuat transaksi: $e')),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic tx) {
    final amount = (tx['amount'] as num).toDouble();
    final isExpense = amount <= 0;
    final absAmount = amount.abs();
    final formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(absAmount);
    final String category = tx['category'] ?? 'Lainnya';
    
    IconData icon = Icons.receipt_long_rounded;
    Color color = AppTheme.subtleText;

    if (category == 'Transportasi') { icon = Icons.directions_car_rounded; color = AppTheme.accentBlue; }
    else if (category == 'Makanan' || category == 'Makanan & Minuman') { icon = Icons.restaurant_rounded; color = AppTheme.accentOrange; }
    else if (category == 'Hiburan') { icon = Icons.movie_rounded; color = AppTheme.accentPurple; }
    else if (category == 'Belanja') { icon = Icons.shopping_bag_rounded; color = AppTheme.accentRed; }
    else if (category == 'Penghasilan' || !isExpense) { icon = Icons.account_balance_rounded; color = AppTheme.emeraldGreen; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['description'] ?? 'Transaksi',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.darkText, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 2),
                Text(category, style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isExpense ? '-' : '+'}$formattedAmount',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isExpense ? AppTheme.accentRed : AppTheme.emeraldGreen,
            ),
          ),
        ],
      ),
    );
  }
}

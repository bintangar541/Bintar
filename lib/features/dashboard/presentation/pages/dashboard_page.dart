import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bintar/core/theme/app_theme.dart';
import 'package:bintar/core/providers/providers.dart';
import 'package:bintar/core/services/auth_service.dart';
import 'package:bintar/shared/widgets/main_shell.dart';
import 'package:bintar/features/goals/presentation/pages/goals_page.dart';
import 'package:bintar/features/goals/presentation/providers/goals_provider.dart';
import 'package:bintar/features/transactions/presentation/pages/manual_sync_page.dart';
import 'package:bintar/features/transactions/presentation/widgets/voice_input_sheet.dart';
import 'package:bintar/features/profile/presentation/pages/profile_page.dart';
import 'package:bintar/features/transactions/presentation/pages/transactions_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatMini(double amount) {
    if (amount >= 1000000) return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return 'Rp${(amount / 1000).round()}rb';
    return 'Rp${amount.round()}';
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final currentTimeFrame = ref.watch(timeFrameProvider);
    
    double balance = 0;
    double income = 0;
    double expense = 0;

    if (transactionsAsync.hasValue && transactionsAsync.value != null) {
      final allTx = transactionsAsync.value!;
      final now = DateTime.now();
      
      // Calculate lifetime balance
      for (var tx in allTx) {
        balance += (tx['amount'] as num).toDouble();
      }

      // Filter for timeframe stats (Default: Monthly)
      final filteredTransactions = allTx.where((tx) {
        final timestamp = DateTime.parse(tx['timestamp']);
        return timestamp.month == now.month && timestamp.year == now.year;
      }).toList();

      for (var tx in filteredTransactions) {
        final amount = (tx['amount'] as num).toDouble();
        if (amount > 0) income += amount;
        else expense += amount.abs();
      }
    }

    final fmtBalance = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(balance);
    final fmtIncome = _formatMini(income);
    final fmtExpense = _formatMini(expense);

    final authState = ref.watch(authProvider);
    final userName = authState.user?['full_name'] ?? 'Bintar User';
    
    // Dynamic greeting
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 11) greeting = 'Selamat Pagi 👋';
    else if (hour < 15) greeting = 'Selamat Siang 👋';
    else if (hour < 18) greeting = 'Selamat Sore 👋';
    else greeting = 'Selamat Malam 👋';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            color: AppTheme.subtleText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showVoiceInput(context, ref),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic_rounded, color: AppTheme.emeraldGreen, size: 22),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfilePage()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.darkText.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: AppTheme.darkText, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppTheme.darkGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.25),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL SALDO',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.trending_up_rounded, color: AppTheme.emeraldLight, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '+5.2%',
                                style: TextStyle(
                                  color: AppTheme.emeraldLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fmtBalance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _BalanceMini(
                            label: 'Pemasukan',
                            amount: fmtIncome,
                            icon: Icons.south_west_rounded,
                            color: AppTheme.emeraldLight,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _BalanceMini(
                            label: 'Pengeluaran',
                            amount: fmtExpense,
                            icon: Icons.north_east_rounded,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Misi Tabungan Banner
              _buildGoalsBanner(context, ref),


              const SizedBox(height: 20),

              // Financial Health Score (Dynamic)
              Builder(builder: (_) {
                // Hitung skor kesehatan finansial
                double savingsRatio = 0;
                double expenseRatio = 0;
                double budgetScore = 0;
                String healthLabel = 'BELUM ADA DATA';
                int healthScore = 0;

                if (income > 0 || expense > 0) {
                  savingsRatio = income > 0 ? ((income - expense) / income).clamp(0.0, 1.0) : 0;
                  expenseRatio = income > 0 ? (expense / income).clamp(0.0, 1.0) : 1.0;
                  budgetScore = (1.0 - (expense / (income > 0 ? income : expense + 1))).clamp(0.0, 1.0);
                  healthScore = ((savingsRatio * 40) + ((1 - expenseRatio) * 30) + (budgetScore * 30)).round().clamp(0, 100);
                  healthLabel = healthScore >= 80 ? 'OPTIMAL' : healthScore >= 50 ? 'CUKUP' : 'PERLU PERHATIAN';
                }

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kesehatan Finansial',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.darkText),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: healthScore >= 50 ? AppTheme.emeraldGradient : const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              healthLabel,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$healthScore',
                            style: TextStyle(
                              fontSize: 48, fontWeight: FontWeight.w900, height: 1,
                              color: healthScore >= 50 ? AppTheme.emeraldGreen : AppTheme.accentRed,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('/100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.mutedText)),
                          ),
                          const Spacer(),
                          ...List.generate(7, (i) {
                            final heights = [20.0, 28.0, 24.0, 32.0, 28.0, 36.0, 30.0];
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Container(
                                width: 6, height: heights[i],
                                decoration: BoxDecoration(
                                  color: i == 5 ? AppTheme.emeraldGreen : AppTheme.emeraldGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _HealthBar(label: 'Rasio Tabungan', value: savingsRatio, color: AppTheme.emeraldGreen),
                      const SizedBox(height: 12),
                      _HealthBar(label: 'Kontrol Pengeluaran', value: (1 - expenseRatio).clamp(0.0, 1.0), color: AppTheme.accentOrange),
                      const SizedBox(height: 12),
                      _HealthBar(label: 'Sisa Budget', value: budgetScore, color: AppTheme.accentBlue),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // AI Insight Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.emeraldGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.emeraldShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI INSIGHT',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      income == 0 && expense == 0
                        ? '"Belum ada data transaksi. Mulai catat pemasukan dan pengeluaranmu untuk mendapatkan insight AI yang personal!"'
                        : '"Total pemasukan ${_formatMini(income)} dan pengeluaran ${_formatMini(expense)}. ${expense > income ? "Pengeluaran melebihi pemasukan, yuk kurangi!" : "Keuanganmu sehat, pertahankan!"} Tanya AI Coach untuk saran lebih detail."',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        MainShell.shellKey.currentState?.switchToTab(4);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Tanya AI Coach →',
                          style: TextStyle(
                            color: AppTheme.emeraldDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi Terakhir',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.darkText),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TransactionsPage()),
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }
                  return Column(
                    children: transactions.take(5).map((tx) {
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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TransactionTile(
                          icon: icon,
                          color: color,
                          title: tx['description'] ?? 'Transaksi',
                          subtitle: category,
                          amount: '${isExpense ? '-' : '+'}$formattedAmount',
                          isExpense: isExpense,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                error: (e, _) => Center(child: Text('Gagal memuat transaksi: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsBanner(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final goals = goalsAsync.value ?? [];
    final completed = goals.where((g) => g.isCompleted).length;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.emeraldGreen, const Color(0xFF11998e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.emeraldGreen.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('🎯', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Misi Tabungan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goals.isEmpty
                        ? 'Belum ada misi. Buat sekarang!'
                        : '${goals.length} misi aktif · $completed selesai',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.7), size: 16),
          ],
        ),
      ),
    );
  }

  void _showVoiceInput(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceInputSheet(ref: ref),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.darkText),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Manual Sync',
                subtitle: 'Import Bank',
                icon: Icons.sync_rounded,
                color: AppTheme.emeraldGreen,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualSyncPage())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionCard(
                title: 'Laporan AI',
                subtitle: 'Analisis DNA',
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.accentBlue,
                onTap: () {
                  MainShell.shellKey.currentState?.switchToTab(3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }


  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final notificationsAsync = ref.watch(smartNotificationsProvider);

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Notifikasi Pintar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.darkText)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.emeraldGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.emeraldGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('AI Bintar memantau keuanganmu 24/7.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
                const SizedBox(height: 24),
                notificationsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: AppTheme.emeraldGreen),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Gagal memuat notifikasi: $err', style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              const Text('📭', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 12),
                              Text('Belum ada notifikasi baru.', style: TextStyle(color: AppTheme.mutedText)),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: notifications.map((n) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _NotificationItem(
                            icon: _getIconData(n['icon']),
                            color: _getColor(n['color']),
                            title: n['title'] ?? 'Notifikasi',
                            desc: n['desc'] ?? '',
                            time: n['time'] ?? '',
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  IconData _getIconData(String? name) {
    switch (name) {
      case 'warning_amber_rounded': return Icons.warning_amber_rounded;
      case 'event_repeat_rounded': return Icons.event_repeat_rounded;
      case 'auto_awesome_rounded': return Icons.auto_awesome_rounded;
      case 'local_attraction_rounded': return Icons.local_attraction_rounded;
      case 'payments_rounded': return Icons.payments_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }

  Color _getColor(String? name) {
    switch (name) {
      case 'orange': return Colors.orange;
      case 'blue': return AppTheme.accentBlue;
      case 'green': return AppTheme.emeraldGreen;
      case 'red': return AppTheme.accentRed;
      case 'purple': return Colors.purple;
      default: return AppTheme.emeraldGreen;
    }
  }
}


class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.darkText)),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: AppTheme.mutedText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──

class _BalanceMini extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _BalanceMini({required this.label, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11, fontWeight: FontWeight.w500)),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}



class _HealthBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _HealthBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppTheme.subtleText, fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String amount;
  final bool isExpense;

  const _TransactionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.darkText)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.mutedText)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isExpense ? AppTheme.accentRed : AppTheme.emeraldGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.darkText)),
                    Text(time, style: TextStyle(fontSize: 10, color: AppTheme.mutedText)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppTheme.subtleText, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

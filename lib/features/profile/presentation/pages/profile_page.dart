import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bintar/core/theme/app_theme.dart';
import 'package:bintar/core/providers/providers.dart';
import 'package:bintar/core/services/auth_service.dart';
import 'package:bintar/features/transactions/presentation/pages/manual_sync_page.dart';
import 'package:bintar/features/profile/presentation/pages/security_settings_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    // Hitung statistik dari data real
    int totalTx = 0;
    double income = 0;
    double expense = 0;

    if (transactionsAsync.hasValue && transactionsAsync.value != null) {
      final txList = transactionsAsync.value!;
      totalTx = txList.length;
      for (var tx in txList) {
        final amount = (tx['amount'] as num).toDouble();
        if (amount > 0) income += amount;
        else expense += amount.abs();
      }
    }

    final balance = income - expense;
    // Hitung skor kesehatan finansial
    double savingsRatio = income > 0 ? ((income - expense) / income).clamp(0.0, 1.0) : 0;
    double expenseRatio = income > 0 ? (expense / income).clamp(0.0, 1.0) : 1.0;
    double budgetScore = (1.0 - (expense / (income > 0 ? income : expense + 1))).clamp(0.0, 1.0);
    int healthScore = (income > 0 || expense > 0)
        ? ((savingsRatio * 40) + ((1 - expenseRatio) * 30) + (budgetScore * 30)).round().clamp(0, 100)
        : 0;

    // Tentukan tipe pengguna berdasarkan rasio keuangan
    String userType;
    if (totalTx == 0) {
      userType = '✦ Pengguna Baru';
    } else if (savingsRatio >= 0.5) {
      userType = '✦ The Saver';
    } else if (savingsRatio >= 0.2) {
      userType = '✦ Strategic Planner';
    } else if (expense > income) {
      userType = '✦ Big Spender';
    } else {
      userType = '✦ The Explorer';
    }

    final fmtBalance = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(balance);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = user?['full_name'] ?? 'Bintar User';
    final userEmail = user?['email'] ?? '';
    final initials = userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            children: [
              // Profile Header
              Stack(
                children: [
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.emeraldGreen, width: 2.5),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF1E293B),
                            child: Text(
                              initials.isEmpty ? 'BN' : initials,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        if (userEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            userType,
                            style: const TextStyle(
                              color: AppTheme.emeraldLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ProfileStat(label: 'Transaksi', value: '$totalTx'),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 24)),
                            _ProfileStat(label: 'Saldo', value: balance >= 1000000 ? '${(balance / 1000000).toStringAsFixed(1)}M' : balance >= 1000 ? '${(balance / 1000).toStringAsFixed(0)}K' : '${balance.toInt()}'),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 24)),
                            _ProfileStat(label: 'Skor', value: '$healthScore'),
                          ],
                        ),
                      ],
                    ),
                  ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
              const SizedBox(height: 24),

              // Account Section
              _SectionLabel('AKUN'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.account_balance_wallet_rounded, 
                      title: 'Dompet Saya', 
                      subtitle: 'Saldo: $fmtBalance', 
                      color: AppTheme.emeraldGreen,
                    ),
                    _TileDivider(),
                    _ProfileTile(
                      icon: Icons.shield_rounded, 
                      title: 'Keamanan', 
                      subtitle: 'Dilindungi', 
                      color: AppTheme.accentBlue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage())),
                    ),
                    _TileDivider(),
                    _ProfileTile(
                      icon: Icons.psychology_rounded, 
                      title: 'Preferensi AI', 
                      subtitle: 'Engine: Groq Llama 3.3', 
                      color: AppTheme.accentPurple,
                      showArrow: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),


              // Logout
              GestureDetector(
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: const _ProfileTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    subtitle: 'Akhiri sesi Anda',
                    color: AppTheme.accentRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.mutedText,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: AppTheme.dividerColor),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool showArrow;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.darkText)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.mutedText)),
              ],
            ),
          ),
          if (onTap != null && showArrow)
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.mutedText),
        ],
      ),
    );

    if (onTap == null) return body;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: body,
    );
  }
}

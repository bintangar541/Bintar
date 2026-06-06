import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bintar/core/theme/app_theme.dart';
import 'package:bintar/core/providers/providers.dart';
import 'package:bintar/features/analytics/presentation/pages/wrapped_page.dart';
import 'package:bintar/features/analytics/presentation/pages/simulation_page.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analisis AI',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.darkText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pola keuanganmu berdasarkan AI',
                        style: TextStyle(fontSize: 14, color: AppTheme.subtleText),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Financial DNA Card
              analysisAsync.when(
                data: (analysis) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppTheme.premiumGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emeraldGreen.withOpacity(0.3),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'FINANCIAL DNA',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis['dna_title'] ?? 'The Strategic Planner',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        analysis['dna_description'] ?? 'Analisis DNA keuanganmu sedang diproses...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => Container(
                  width: double.infinity,
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppTheme.premiumGradient,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
                error: (e, _) => Text('Gagal memuat analisis: $e'),
              ),
              const SizedBox(height: 32),

              // Premium Action Cards
              Row(
                children: [
                  Expanded(
                    child: _PremiumActionCard(
                      title: 'Bintar Wrapped',
                      subtitle: 'Laporan Estetik 📄',
                      color: AppTheme.emeraldGreen,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WrappedPage())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PremiumActionCard(
                      title: 'Simulasi AI',
                      subtitle: 'Skenario Mandiri 🧠',
                      color: AppTheme.accentBlue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SimulationPage())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Timeline Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Timeline Keuangan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.darkText),
                  ),
                  const Icon(Icons.auto_awesome_rounded, color: AppTheme.emeraldGreen, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              analysisAsync.when(
                data: (analysis) {
                  final insights = (analysis['timeline_insights'] as List?) ?? [];
                  if (insights.isEmpty) return const Text('Belum ada timeline terbaru.');
                  return Column(
                    children: insights.map((item) => _TimelineItem(
                      title: item['title'] ?? 'Insight AI',
                      desc: item['desc'] ?? '',
                      date: 'BARU',
                      icon: Icons.auto_awesome_rounded,
                      color: AppTheme.emeraldGreen,
                    )).toList(),
                  );
                },
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String desc;
  final String date;
  final IconData icon;
  final Color color;

  const _TimelineItem({
    required this.title,
    required this.desc,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.darkText)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              date,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.mutedText, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
class _PremiumActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PremiumActionCard({required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(title.contains('Wrapped') ? Icons.auto_awesome_motion_rounded : Icons.psychology_rounded, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.darkText)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: AppTheme.mutedText, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bintar/core/theme/app_theme.dart';
import 'package:bintar/core/providers/providers.dart';
import 'package:bintar/features/goals/presentation/providers/goals_provider.dart';
import 'package:bintar/features/goals/domain/models/goal.dart';
import 'package:bintar/core/utils/currency_formatter.dart';
import 'package:flutter/services.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    // Calculate average monthly savings
    double avgSavings = 0;
    if (transactionsAsync.hasValue && transactionsAsync.value != null) {
      final txs = transactionsAsync.value!;
      double totalNet = 0;
      for (var tx in txs) {
        totalNet += (tx['amount'] as num).toDouble();
      }
      // Simple logic: if net > 0, use it as savings. 
      // For better logic, we'd group by month, but this is a good start.
      avgSavings = totalNet.clamp(0.0, double.infinity);
      if (avgSavings < 100000) avgSavings = 100000; // Minimum for estimation
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Misi Tabungan',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppTheme.emeraldGreen, size: 24),
            ),
            onPressed: () => _showAddGoalSheet(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) => goals.isEmpty
            ? _buildEmptyState(context, ref)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: goals.length,
                itemBuilder: (context, index) => _GoalCard(
                  goal: goals[index],
                  avgSavings: avgSavings,
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.emeraldGreen)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flag_rounded, size: 60, color: AppTheme.emeraldGreen),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada misi tabungan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.darkText),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mulai susun mimpimu agar Bintar bisa\nmembantumu mencapainya lebih cepat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedText, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _showAddGoalSheet(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Buat Misi Pertama', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddGoalSheet(ref: ref),
    );
  }
}

// ── Stateful Bottom Sheet for Add Goal ──
class _AddGoalSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddGoalSheet({required this.ref});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Mimpi';
  String _selectedIcon = '🚀';
  bool _isLoading = false;

  final _icons = ['🚀', '🏡', '📱', '✈️', '🎓', '💍', '🚗', '💼', '🏥', '🎮'];
  final _categories = ['Mimpi', 'Kebutuhan', 'Investasi', 'Lainnya'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Buat Misi Baru 🎯',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.darkText),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tentukan targetmu dan Bintar akan membantu melacak progresnya.',
              style: TextStyle(fontSize: 13, color: AppTheme.mutedText, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Icon picker
            const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.darkText, fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _selectedIcon = _icons[i]),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _selectedIcon == _icons[i]
                          ? AppTheme.emeraldGreen.withOpacity(0.12)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: _selectedIcon == _icons[i]
                          ? Border.all(color: AppTheme.emeraldGreen, width: 2)
                          : null,
                    ),
                    child: Center(child: Text(_icons[i], style: const TextStyle(fontSize: 22))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Judul Misi (misal: Beli iPhone)', _titleController, Icons.title_rounded),
            const SizedBox(height: 14),
            _buildTextField(
              'Target Nominal (Rp)', 
              _amountController, 
              Icons.account_balance_wallet_rounded, 
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
            ),
            const SizedBox(height: 20),
            const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.darkText, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _categories.map((cat) => GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedCategory == cat
                        ? AppTheme.emeraldGreen.withOpacity(0.1)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedCategory == cat
                        ? Border.all(color: AppTheme.emeraldGreen, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: _selectedCategory == cat ? AppTheme.emeraldGreen : AppTheme.subtleText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  disabledBackgroundColor: AppTheme.mutedText,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Misi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await widget.ref.read(goalsProvider.notifier).addGoal(
        title: _titleController.text,
        targetAmount: double.parse(_amountController.text.replaceAll('.', '')),
        category: _selectedCategory,
        icon: _selectedIcon,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    String hint, 
    TextEditingController controller, 
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.mutedText, fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.mutedText, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// ── Goal Card ──
class _GoalCard extends StatelessWidget {
  final Goal goal;
  final double avgSavings;

  const _GoalCard({required this.goal, required this.avgSavings});

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).toInt();
    final months = goal.calculateMonthsRemaining(avgSavings);

    Color progressColor = pct >= 75
        ? AppTheme.emeraldGreen
        : pct >= 40
            ? AppTheme.accentOrange
            : AppTheme.accentBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(goal.icon, style: const TextStyle(fontSize: 24)),
              ),
              Row(
                children: [
                  if (goal.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('✅ Selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.emeraldGreen)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        goal.category.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.subtleText, letterSpacing: 0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(goal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.darkText)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(CurrencyFormat.format(goal.currentAmount), style: TextStyle(fontWeight: FontWeight.w800, color: progressColor, fontSize: 15)),
              Text(' / ${CurrencyFormat.format(goal.targetAmount)}', style: const TextStyle(color: AppTheme.mutedText, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 18),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: goal.progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct% Tercapai',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.subtleText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 11, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      goal.isCompleted ? 'Target Tercapai!' : 'Estimasi $months bln',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


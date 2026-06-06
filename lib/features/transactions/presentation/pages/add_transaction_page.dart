import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/auth_service.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isExpense = true;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(transactionCategoryProvider(_descController.text));

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.darkText),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _TypeTab(label: 'Pengeluaran', icon: Icons.north_east_rounded, isSelected: _isExpense, onTap: () => setState(() => _isExpense = true)),
                  const SizedBox(width: 4),
                  _TypeTab(label: 'Pemasukan', icon: Icons.south_west_rounded, isSelected: !_isExpense, onTap: () => setState(() => _isExpense = false)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'NOMINAL',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Rp', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.mutedText)),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsSeparatorFormatter(),
                    ],
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppTheme.darkText),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: AppTheme.mutedText),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'DESKRIPSI',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Contoh: Kopi pagi di Janji Jiwa',
                hintStyle: TextStyle(color: AppTheme.mutedText),
                fillColor: AppTheme.cardWhite,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppTheme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppTheme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 20),

            if (_descController.text.length > 3)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.emeraldGreen.withOpacity(0.05), AppTheme.accentBlue.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.emeraldGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KATEGORI AI',
                            style: TextStyle(
                              color: AppTheme.emeraldGreen.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          categoryAsync.when(
                            data: (category) => Text(
                              category,
                              style: const TextStyle(color: AppTheme.emeraldDark, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            loading: () => const Text('Menganalisis...', style: TextStyle(color: AppTheme.mutedText, fontSize: 14)),
                            error: (_, __) => const Text('Lainnya', style: TextStyle(color: AppTheme.mutedText, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final amountString = _amountController.text.replaceAll('.', '');
                  if (amountString.isEmpty || _descController.text.isEmpty) return;
                  
                  final amount = double.tryParse(amountString) ?? 0;
                  final finalAmount = _isExpense ? -amount : amount;
                  final category = categoryAsync.value ?? 'Lainnya';
                  
                  try {
                    final userId = ref.read(authProvider).user?['id'] ?? 1;
                    
                    await ref.read(apiServiceProvider).saveTransaction({
                      'amount': finalAmount,
                      'description': _descController.text,
                      'category': category,
                      'wallet_type': 'Main Wallet',
                      'user_id': userId,
                    });
                    
                    // Force refresh the dashboard provider
                    ref.invalidate(recentTransactionsProvider);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Transaksi Berhasil Disimpan! ✅'),
                          backgroundColor: AppTheme.emeraldDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Gagal menyimpan transaksi. Pastikan backend aktif.'),
                          backgroundColor: AppTheme.accentRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeTab({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cardWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? AppTheme.softShadow : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppTheme.darkText : AppTheme.mutedText),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected ? AppTheme.darkText : AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll('.', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

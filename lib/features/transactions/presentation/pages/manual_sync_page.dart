import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/currency_formatter.dart';

class ManualSyncPage extends ConsumerStatefulWidget {
  const ManualSyncPage({super.key});

  @override
  ConsumerState<ManualSyncPage> createState() => _ManualSyncPageState();
}

class _ManualSyncPageState extends ConsumerState<ManualSyncPage> {
  bool _isUploading = false;
  List<dynamic> _parsedTransactions = [];
  String? _fileName;

  Future<void> _pickFile() async {
    // Sesuai versi file_picker terbaru (11.0.2), panggil pickFiles secara static
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv', 'pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _isUploading = true;
        _fileName = result.files.first.name;
        _parsedTransactions = [];
      });

      try {
        final api = ref.read(apiServiceProvider);
        final txs = await api.importBank(
          result.files.first.bytes!,
          result.files.first.name,
        );
        setState(() {
          _parsedTransactions = txs;
          _isUploading = false;
        });
        if (txs.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI tidak menemukan transaksi. Pastikan file berisi teks mutasi yang jelas!')),
          );
        }
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membaca file: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveAll() async {
    setState(() => _isUploading = true);
    try {
      final api = ref.read(apiServiceProvider);
      for (var tx in _parsedTransactions) {
        await api.saveTransaction({
          'description': tx['description'],
          'amount': tx['amount'],
          'category': tx['category'],
          'date': tx['date'] ?? DateTime.now().toIso8601String(),
        });
      }
      ref.invalidate(recentTransactionsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua transaksi berhasil diimpor! 📁✅')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Manual Sync (Bank)', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildUploadSection(),
          if (_isUploading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.emeraldGreen)))
          else if (_parsedTransactions.isNotEmpty)
            Expanded(child: _buildTransactionList())
          else
            _buildEmptyState(),
        ],
      ),
      bottomNavigationBar: _parsedTransactions.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildUploadSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.emeraldGreen),
          const SizedBox(height: 16),
          const Text('Upload Mutasi Bank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'Upload file PDF, CSV, atau TXT hasil download m-banking mu. AI Bintar akan otomatis membaca isinya.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickFile,
            icon: const Icon(Icons.file_present_rounded),
            label: Text(_fileName ?? 'Pilih File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _parsedTransactions.length,
      itemBuilder: (context, index) {
        final tx = _parsedTransactions[index];
        final amount = (tx['amount'] as num).toDouble();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceLight),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded, size: 20, color: AppTheme.subtleText),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['description'] ?? 'Tanpa Judul', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(tx['category'] ?? 'Lainnya', style: const TextStyle(color: AppTheme.mutedText, fontSize: 11)),
                  ],
                ),
              ),
              Text(
                CurrencyFormat.format(amount),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: amount < 0 ? Colors.redAccent : AppTheme.emeraldGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Text('Belum ada file yang diupload', style: TextStyle(color: AppTheme.mutedText)),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isUploading ? null : _saveAll,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.emeraldGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            'Simpan ${_parsedTransactions.length} Transaksi',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/currency_formatter.dart';

class VoiceInputSheet extends StatefulWidget {
  final WidgetRef ref;
  const VoiceInputSheet({super.key, required this.ref});

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Tekan mikrofon dan mulailah bicara...";
  double _confidence = 1.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    if (mounted) setState(() {});
  }

  void _listen() async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            debugPrint('onStatus: $val');
            if (val == 'notListening' && mounted) {
              setState(() => _isListening = false);
            }
          },
          onError: (val) {
            debugPrint('onError: $val');
            if (mounted) {
              setState(() {
                _isListening = false;
                _text = "Error: ${val.errorMsg}. Pastikan izin mic aktif!";
              });
            }
          },
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            localeId: 'id_ID',
            onResult: (val) => setState(() {
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            }),
          );
        } else {
          setState(() {
            _text = "Mic tidak tersedia atau izin ditolak. Coba ketik manual saja!";
          });
        }
      } else {
        setState(() => _isListening = false);
        _speech.stop();
        _processInput(_text);
      }
    } catch (e) {
      debugPrint('Speech Error: $e');
      setState(() => _text = "Gagal inisialisasi Mic: $e");
    }
  }

  Future<void> _processInput(String input) async {
    if (input.isEmpty || input.contains("Tekan mikrofon") || input.contains("Error")) return;
    
    setState(() => _isProcessing = true);
    try {
      final api = widget.ref.read(apiServiceProvider);
      final result = await api.smartInput(input);
      
      if (mounted) {
        setState(() => _isProcessing = false);
        _showConfirmationDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _text = "Bintar bingung, coba bicara lebih jelas ya!";
        });
      }
    }
  }

  void _showConfirmationDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Konfirmasi Transaksi 🤖', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bintar menangkap:', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
            const SizedBox(height: 12),
            _buildDetailRow('Deskripsi', data['description'] ?? '-'),
            _buildDetailRow('Nominal', CurrencyFormat.format((data['amount'] as num).toDouble())),
            _buildDetailRow('Kategori', data['category'] ?? 'Lainnya'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppTheme.mutedText)),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.ref.read(apiServiceProvider).saveTransaction({
                'description': data['description'],
                'amount': data['amount'],
                'category': data['category'],
                'date': DateTime.now().toIso8601String(),
              });
              widget.ref.invalidate(recentTransactionsProvider);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dicatat! 🎉')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          const Text('Bicara ke Bintar 🎙️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Katakan: "Makan siang 50 ribu"', style: TextStyle(color: AppTheme.mutedText)),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _isListening ? AppTheme.darkText : AppTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Atau ketik manual di sini...',
                    hintStyle: TextStyle(color: AppTheme.mutedText.withOpacity(0.5), fontSize: 14),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppTheme.emeraldGreen),
                      onPressed: () => _processInput(_text),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (val) => setState(() => _text = val),
                  onSubmitted: (val) => _processInput(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          if (_isProcessing)
            const CircularProgressIndicator(color: AppTheme.emeraldGreen)
          else
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red.withOpacity(0.1) : AppTheme.emeraldGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isListening ? Colors.red : AppTheme.emeraldGreen,
                    width: 4,
                  ),
                ),
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 48,
                  color: _isListening ? Colors.red : AppTheme.emeraldGreen,
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

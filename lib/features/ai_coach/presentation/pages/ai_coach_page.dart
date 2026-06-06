import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';
import 'package:bintar/features/analytics/presentation/pages/simulation_page.dart';

class AICoachPage extends ConsumerStatefulWidget {
  const AICoachPage({super.key});

  @override
  ConsumerState<AICoachPage> createState() => _AICoachPageState();
}

class _AICoachPageState extends ConsumerState<AICoachPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  final _messages = <_ChatMessage>[
    _ChatMessage(
      text: 'Halo! Saya asisten keuangan AI Bintar. Saya selalu siap membantu menganalisis dan meng-optimalkan keuanganmu. Ada yang bisa saya bantu? 🚀',
      isAI: true,
    ),
  ];

  Future<void> _sendMessage([String? presetMessage]) async {
    final text = presetMessage ?? _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    if (presetMessage == null) _controller.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatMessage(text: text, isAI: false));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final reply = await ref.read(apiServiceProvider).sendChatMessage(text);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(text: reply, isAI: true));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(text: "Maaf sayang sekali koneksi terputus. Coba tanya lagi ya. 🙇‍♂️", isAI: true));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.emeraldGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppTheme.emeraldShadow,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Money Coach',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.darkText),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.emeraldGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Aktif · Menganalisis data',
                            style: TextStyle(fontSize: 12, color: AppTheme.emeraldGreen, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20, right: 100),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.emeraldGreen,
                            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(4),
                              ),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: const Text('Sedang mengetik...', style: TextStyle(color: AppTheme.mutedText)),
                          ),
                        ],
                      ),
                    );
                  }
                  final msg = _messages[index];
                  return _ChatBubble(message: msg.text, isAI: msg.isAI);
                },
              ),
            ),

            // Suggestions
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SimulationPage())),
                    child: const _SuggestionChip(label: '🧠 Simulasi AI'),
                  ),
                  GestureDetector(
                    onTap: () => _sendMessage('💰 Analisis keuangan saya'),
                    child: const _SuggestionChip(label: '💰 Analisis keuangan saya'),
                  ),
                  GestureDetector(
                    onTap: () => _sendMessage('📊 Tips menabung'),
                    child: const _SuggestionChip(label: '📊 Tips menabung'),
                  ),
                  GestureDetector(
                    onTap: () => _sendMessage('🎯 Cek target'),
                    child: const _SuggestionChip(label: '🎯 Cek target'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Tanyakan sesuatu...',
                          hintStyle: TextStyle(color: AppTheme.mutedText, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isTyping ? null : () => _sendMessage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: _isTyping ? null : AppTheme.emeraldGradient,
                        color: _isTyping ? Colors.grey.shade300 : null,
                        shape: BoxShape.circle,
                        boxShadow: _isTyping ? [] : AppTheme.emeraldShadow,
                      ),
                      child: Icon(Icons.send_rounded, color: _isTyping ? Colors.grey : Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isAI;
  _ChatMessage({required this.text, required this.isAI});
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.darkText)),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isAI;

  const _ChatBubble({required this.message, required this.isAI});

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Teks berhasil disalin! 📋'),
        backgroundColor: AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.emeraldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyText(context),
              child: Column(
                crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isAI ? AppTheme.cardWhite : AppTheme.darkText,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isAI ? 4 : 20),
                        bottomRight: Radius.circular(isAI ? 20 : 4),
                      ),
                      boxShadow: isAI
                          ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isAI ? AppTheme.darkText : Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (isAI) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _copyText(context),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded, size: 14, color: AppTheme.mutedText),
                            const SizedBox(width: 4),
                            Text('Salin', style: TextStyle(fontSize: 11, color: AppTheme.mutedText, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppTheme.surfaceLight,
              radius: 14,
              child: Text('JD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.subtleText)),
            ),
          ],
        ],
      ),
    );
  }
}

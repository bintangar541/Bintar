import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _biometricEnabled = true;
  bool _appLockEnabled = false;

  void _showChangePasswordSheet() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isObscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 28,
            right: 28,
            top: 28,
          ),
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
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ganti Kata Sandi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.darkText),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan kata sandi baru Anda kuat dan unik.',
                style: TextStyle(color: AppTheme.mutedText, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildModernField(
                controller: oldPasswordController,
                label: 'Kata Sandi Lama',
                isPassword: isObscure,
                onToggle: () => setModalState(() => isObscure = !isObscure),
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: newPasswordController,
                label: 'Kata Sandi Baru',
                isPassword: isObscure,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: confirmPasswordController,
                label: 'Konfirmasi Kata Sandi Baru',
                isPassword: isObscure,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (newPasswordController.text == confirmPasswordController.text && newPasswordController.text.isNotEmpty) {
                      ref.read(lastPasswordChangeProvider.notifier).state = 'Terakhir diubah baru saja';
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kata sandi berhasil diperbarui'),
                          backgroundColor: AppTheme.emeraldGreen,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkText,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.mutedText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surfaceLight.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: onToggle != null
                ? IconButton(
                    icon: Icon(isPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Keamanan',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('AUTENTIKASI'),
            const SizedBox(height: 12),
            _buildSecurityCard([
              _buildSwitchTile(
                icon: Icons.fingerprint_rounded,
                title: 'Login Biometrik',
                subtitle: 'Gunakan FaceID atau Sidik Jari',
                value: _biometricEnabled,
                onChanged: (val) => setState(() => _biometricEnabled = val),
                color: AppTheme.emeraldGreen,
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.lock_outline_rounded,
                title: 'Kunci Aplikasi',
                subtitle: 'Minta PIN saat buka aplikasi',
                value: _appLockEnabled,
                onChanged: (val) => setState(() => _appLockEnabled = val),
                color: AppTheme.accentBlue,
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('KREDENSIAL'),
            const SizedBox(height: 12),
            _buildSecurityCard([
              _buildActionTile(
                icon: Icons.password_rounded,
                title: 'Ganti Kata Sandi',
                subtitle: ref.watch(lastPasswordChangeProvider),
                onTap: _showChangePasswordSheet,
                color: AppTheme.accentPurple,
              ),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Data Anda dilindungi dengan enkripsi AES-256',
                style: TextStyle(
                  color: AppTheme.mutedText.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.mutedText,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSecurityCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.darkText)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.emeraldGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.darkText)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.mutedText),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppTheme.dividerColor, indent: 64);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String? _selected;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select the returning user's last-used mode so they can just
    // tap DEVAM ET to continue.
    final auth = context.read<AuthProvider>();
    final existingMode = auth.appUser?.appMode ?? '';
    if (existingMode.isNotEmpty) {
      _selected = existingMode;
    }
  }

  static const _modes = [
    _ModeOption(
      value: 'reglTakip',
      emoji: '🌸',
      color: Color(0xFFEC4899),
      bgColor: Color(0xFFFDF2F8),
      bgColorDark: Color(0xFF2D1B26),
    ),
    _ModeOption(
      value: 'hamileTakip',
      emoji: '🤰',
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
      bgColorDark: Color(0xFF1E1635),
    ),
    _ModeOption(
      value: 'hamilleKalma',
      emoji: '✨',
      color: Color(0xFFF59E0B),
      bgColor: Color(0xFFFFFBEB),
      bgColorDark: Color(0xFF2A2010),
    ),
  ];

  Future<void> _confirm() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final uid = auth.appUser?.uid;
      if (uid == null) return;
      await auth.userService.updateAppMode(uid, _selected!);
      // Mark this session as confirmed so AuthGate transitions to MainShell.
      auth.confirmModeForSession();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydedilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? AppColors.bgGradientDark
                : AppColors.bgGradientLight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo_new.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appPurpose,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                ..._modes.map((mode) => _ModeCard(
                      mode: mode,
                      title: _modeTitle(l10n, mode.value),
                      desc: _modeDesc(l10n, mode.value),
                      selected: _selected == mode.value,
                      isDark: isDark,
                      onTap: () => setState(() => _selected = mode.value),
                    )),
                const Spacer(),
                AnimatedOpacity(
                  opacity: _selected != null ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton(
                    onPressed: _selected != null && !_loading ? _confirm : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'DEVAM ET',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _modeTitle(AppLocalizations l10n, String value) {
    switch (value) {
      case 'reglTakip':
        return l10n.modePeriodTrack;
      case 'hamileTakip':
        return l10n.modePregnancy;
      case 'hamilleKalma':
        return l10n.modeTryConceive;
      default:
        return value;
    }
  }

  String _modeDesc(AppLocalizations l10n, String value) {
    switch (value) {
      case 'reglTakip':
        return l10n.modePeriodTrackDesc;
      case 'hamileTakip':
        return l10n.modePregnancyDesc;
      case 'hamilleKalma':
        return l10n.modeTryConceiveDesc;
      default:
        return '';
    }
  }
}

class _ModeOption {
  final String value;
  final String emoji;
  final Color color;
  final Color bgColor;
  final Color bgColorDark;

  const _ModeOption({
    required this.value,
    required this.emoji,
    required this.color,
    required this.bgColor,
    required this.bgColorDark,
  });
}

class _ModeCard extends StatelessWidget {
  final _ModeOption mode;
  final String title;
  final String desc;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.title,
    required this.desc,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? mode.bgColorDark : mode.bgColor;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? bg : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? mode.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? mode.color.withValues(alpha:0.15)
                  : Colors.black.withValues(alpha:0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mode.color.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(mode.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? mode.color : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? mode.color : Colors.transparent,
                border: Border.all(
                  color: selected ? mode.color : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

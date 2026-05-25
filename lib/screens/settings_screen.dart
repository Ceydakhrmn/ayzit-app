// =============================================
// screens/settings_screen.dart
// Sections:
//   • Genel Ayarlar — app mode (regl / hamile / hamile kalma)
//   • Bildirimler — FCM push toggles (stored on user doc)
//   • Tema — light / dark / system
//   • Döngü — average cycle & period length
//
// All sections are theme-aware (work in light + dark).
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_background.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_provider.dart';
import '../models/app_user.dart';
import '../models/notification_prefs.dart';
import '../providers/auth_provider.dart';
import '../providers/cycle_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Ayarlar'),
        ),
      body: ListView(
        children: const [
          _GeneralSettingsSection(),
          _NotificationsSection(),
          _ThemeSection(),
          _CycleSettingsSection(),
          SizedBox(height: 32),
        ],
      ),
      ),
    );
  }
}

// ────────────────────────────────────────────
// Genel Ayarlar
// ────────────────────────────────────────────
class _GeneralSettingsSection extends StatelessWidget {
  const _GeneralSettingsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();

    return _Section(
      title: 'Genel Ayarlar',
      icon: Icons.tune,
      children: [
        _subLabel(context, 'Uygulama amacı'),
        _ModeCard(
          title: 'Regl Takip',
          subtitle: 'Adet döngünüzü takip edin',
          icon: Icons.water_drop_outlined,
          selected: provider.appMode == AppMode.reglTakip,
          onTap: () => provider.updateAppMode(AppMode.reglTakip),
        ),
        const SizedBox(height: 8),
        _ModeCard(
          title: 'Hamile Takip',
          subtitle: 'Hamilelik sürecinizi takip edin',
          icon: Icons.pregnant_woman_outlined,
          selected: provider.appMode == AppMode.hamileTakip,
          onTap: () async {
            provider.updateAppMode(AppMode.hamileTakip);
            final picked = await showDatePicker(
              context: context,
              initialDate: provider.pregnancyStartDate ??
                  DateTime.now().subtract(const Duration(days: 70)),
              firstDate: DateTime.now().subtract(const Duration(days: 280)),
              lastDate: DateTime.now(),
              helpText: 'Son Adet Tarihinizi Seçin (LMP)',
              cancelText: 'İPTAL',
              confirmText: 'TAMAM',
            );
            if (picked != null) {
              provider.updatePregnancyStartDate(picked);
            }
          },
        ),
        if (provider.appMode == AppMode.hamileTakip) ...[
          const SizedBox(height: 8),
          _LmpRow(),
        ],
        const SizedBox(height: 8),
        _ModeCard(
          title: 'Hamile Kalma',
          subtitle: 'Doğurganlık pencerelerinizi takip edin',
          icon: Icons.favorite_outline,
          selected: provider.appMode == AppMode.hamilleKalma,
          onTap: () => provider.updateAppMode(AppMode.hamilleKalma),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────
// Bildirimler (FCM)
// ────────────────────────────────────────────
class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    final prefs = user?.preferences.notifications ?? const NotificationPrefs();

    Future<void> update(NotificationPrefs newPrefs) async {
      if (user == null) return;
      try {
        await auth.userService.updateNotificationPrefs(user.uid, newPrefs);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Kaydedilemedi: $e')));
        }
      }
    }

    String intervalLabel(int minutes) {
      if (minutes < 60) return '$minutes dakika';
      if (minutes == 60) return '1 saat';
      if (minutes % 60 == 0) return '${minutes ~/ 60} saat';
      return '${minutes ~/ 60} sa ${minutes % 60} dk';
    }

    return _Section(
      title: 'Bildirimler',
      icon: Icons.notifications_outlined,
      children: [
        _SwitchRow(
          title: 'Postuma yorum geldiğinde',
          subtitle: 'Paylaşımlarına yorum geldiğinde bildirim al',
          value: prefs.commentOnPost,
          onChanged: (v) => update(prefs.copyWith(commentOnPost: v)),
        ),
        _SwitchRow(
          title: 'Regl başladı',
          subtitle: 'Regl günün geldiğinde hatırlat',
          value: prefs.periodStart,
          onChanged: (v) => update(prefs.copyWith(periodStart: v)),
        ),
        _SwitchRow(
          title: 'Regl bitti',
          subtitle: 'Regl bitiş günü hatırlat',
          value: prefs.periodEnd,
          onChanged: (v) => update(prefs.copyWith(periodEnd: v)),
        ),
        _SwitchRow(
          title: 'Egzersiz hatırlatıcısı',
          subtitle: 'Düzenli egzersiz zamanı hatırlatıcısı',
          value: prefs.exerciseReminder,
          onChanged: (v) => update(prefs.copyWith(exerciseReminder: v)),
        ),
        if (prefs.exerciseReminder) ...[
          const SizedBox(height: 8),
          _subLabel(context, 'Her ${prefs.exerciseReminderIntervalDays} günde bir hatırlat'),
          _SliderTile(
            value: prefs.exerciseReminderIntervalDays.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '${prefs.exerciseReminderIntervalDays} gün',
            onChanged: (v) => update(prefs.copyWith(exerciseReminderIntervalDays: v.round())),
          ),
        ],
        const Divider(height: 24),
        _SwitchRow(
          title: 'Su içme hatırlatıcısı',
          subtitle: 'Düzenli aralıklarla su iç',
          value: prefs.waterReminder,
          onChanged: (v) => update(prefs.copyWith(waterReminder: v)),
        ),
        if (prefs.waterReminder) ...[
          const SizedBox(height: 8),
          _subLabel(context, 'Hatırlatma sıklığı: ${intervalLabel(prefs.waterReminderIntervalMinutes)}'),
          _SliderTile(
            value: prefs.waterReminderIntervalMinutes.toDouble(),
            min: 15,
            max: 240,
            divisions: 15,
            label: intervalLabel(prefs.waterReminderIntervalMinutes),
            onChanged: (v) => update(prefs.copyWith(waterReminderIntervalMinutes: v.round())),
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────
// Tema
// ────────────────────────────────────────────
class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    final current =
        user?.preferences.themeMode ?? themeProvider.mode;

    Future<void> setMode(AppThemeMode mode) async {
      themeProvider.setMode(mode);
      if (user != null) {
        try {
          await auth.userService.updateThemeMode(user.uid, mode);
        } catch (_) {}
      }
    }

    return _Section(
      title: 'Tema',
      icon: Icons.palette_outlined,
      children: [
        _ThemeRadio(
          label: 'Sistemi takip et',
          value: AppThemeMode.system,
          groupValue: current,
          onChanged: setMode,
        ),
        _ThemeRadio(
          label: 'Açık',
          value: AppThemeMode.light,
          groupValue: current,
          onChanged: setMode,
        ),
        _ThemeRadio(
          label: 'Koyu',
          value: AppThemeMode.dark,
          groupValue: current,
          onChanged: setMode,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────
// Döngü Ayarları
// ────────────────────────────────────────────
class _CycleSettingsSection extends StatelessWidget {
  const _CycleSettingsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();

    return _Section(
      title: 'Döngü',
      icon: Icons.loop,
      children: [
        _subLabel(context, 'Ortalama döngü uzunluğu'),
        _SliderTile(
          value: provider.cycleLength.toDouble(),
          min: 21,
          max: 40,
          divisions: 19,
          label: '${provider.cycleLength} gün',
          onChanged: (v) => provider.updateCycleLength(v.round()),
        ),
        const SizedBox(height: 16),
        _subLabel(context, 'Regl süresi'),
        _SliderTile(
          value: provider.periodLength.toDouble(),
          min: 2,
          max: 10,
          divisions: 8,
          label: '${provider.periodLength} gün',
          onChanged: (v) => provider.updatePeriodLength(v.round()),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────
// Shared widgets
// ────────────────────────────────────────────
Widget _subLabel(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.6),
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _LmpRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final lmp = provider.pregnancyStartDate;
    final label = lmp != null
        ? 'Son adet tarihi: ${lmp.day}/${lmp.month}/${lmp.year}  •  ${provider.pregnancyWeek}. hafta'
        : 'Son adet tarihi girilmedi';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: lmp ?? DateTime.now().subtract(const Duration(days: 70)),
          firstDate: DateTime.now().subtract(const Duration(days: 280)),
          lastDate: DateTime.now(),
          helpText: 'Son Adet Tarihinizi Seçin (LMP)',
          cancelText: 'İPTAL',
          confirmText: 'TAMAM',
        );
        if (picked != null) provider.updatePregnancyStartDate(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: Color(0xFF7C3AED)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: isDark ? 0.15 : 0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected
                    ? primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ThemeRadio extends StatelessWidget {
  final String label;
  final AppThemeMode value;
  final AppThemeMode groupValue;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemeMode>(
      contentPadding: EdgeInsets.zero,
      value: value,
      groupValue: groupValue,
      title: Text(label),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _SliderTile extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

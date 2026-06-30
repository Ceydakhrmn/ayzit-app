// =============================================
// screens/paywall_screen.dart
// Ayzit Premium upgrade / paywall screen.
// Displayed when a free user tries a gated feature
// or navigates to Settings → Upgrade.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/theme/app_colors.dart';
import '../providers/premium_provider.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedProductId = '';
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PremiumProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final premium = context.watch<PremiumProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.bgDark : const Color(0xFFF7F0FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(),
        actions: [
          TextButton(
            onPressed: _purchasing ? null : () => _restore(context),
            child: Text(
              'Satın alımları geri yükle',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: premium.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, premium, isDark),
    );
  }

  Widget _buildContent(
      BuildContext context, PremiumProvider premium, bool isDark) {
    final monthly = _packageFor(premium, 'monthly');
    final yearly = _packageFor(premium, 'yearly');

    // Fallback: use first two available packages if identifiers differ
    final packages = <Package>[
      ?monthly,
      ?yearly,
      if (monthly == null && yearly == null)
        ...?premium.offerings?.current?.availablePackages,
    ];

    if (_selectedProductId.isEmpty && packages.isNotEmpty) {
      // Default: annual (better value)
      _selectedProductId = (packages.length > 1 ? packages[1] : packages[0])
          .storeProduct
          .identifier;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // ── Hero ──
          Image.asset('assets/logo.png', width: 100, height: 100),
          const SizedBox(height: 12),
          Text(
            'Ayzit Premium',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tüm özelliklere sınırsız erişim',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 28),

          // ── Feature list ──
          _FeatureItem(
              icon: Icons.bar_chart_rounded,
              label: 'Gelişmiş döngü istatistikleri'),
          _FeatureItem(
              icon: Icons.child_friendly_rounded,
              label: 'Hamilelik takibi & bebek gelişimi'),
          _FeatureItem(
              icon: Icons.spa_rounded, label: 'Tüm egzersiz & yoga pozları'),
          _FeatureItem(
              icon: Icons.people_alt_rounded,
              label: 'Sosyal akış & paylaşım'),
          _FeatureItem(
              icon: Icons.notifications_active_rounded,
              label: 'Akıllı hatırlatıcılar'),
          _FeatureItem(
              icon: Icons.block_rounded, label: 'Reklamsız deneyim'),
          const SizedBox(height: 28),

          // ── Plan cards ──
          if (packages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Ürünler yüklenirken bir sorun oluştu.\nİnternet bağlantınızı kontrol edin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            )
          else
            ...packages.map((pkg) => _PlanCard(
                  package: pkg,
                  isSelected: _selectedProductId ==
                      pkg.storeProduct.identifier,
                  isRecommended: packages.length > 1 &&
                      pkg == packages[1],
                  onTap: () => setState(() =>
                      _selectedProductId = pkg.storeProduct.identifier),
                )),

          const SizedBox(height: 24),

          // ── CTA button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  (_purchasing || packages.isEmpty) ? null : () => _buy(context, packages),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _purchasing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Premium\'a Geç',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'İstediğin zaman iptal edebilirsin.\nÜyelik mağaza üzerinden yönetilir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Package? _packageFor(PremiumProvider p, String type) {
    final pkgs = p.offerings?.current?.availablePackages ?? [];
    for (final pkg in pkgs) {
      final id = pkg.storeProduct.identifier.toLowerCase();
      if (id.contains(type)) return pkg;
    }
    return null;
  }

  Future<void> _buy(BuildContext context, List<Package> packages) async {
    final selected = packages.firstWhere(
      (p) => p.storeProduct.identifier == _selectedProductId,
      orElse: () => packages.first,
    );
    setState(() => _purchasing = true);
    final premiumProvider = context.read<PremiumProvider>();
    try {
      final success = await premiumProvider.purchase(selected);
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);
      // ignore: use_build_context_synchronously
      final nav = Navigator.of(context);
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('🎉 Premium\'a hoş geldin!')),
        );
        nav.pop();
      }
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore(BuildContext context) async {
    setState(() => _purchasing = true);
    final premiumProvider = context.read<PremiumProvider>();
    try {
      final success = await premiumProvider.restore();
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);
      // ignore: use_build_context_synchronously
      final nav = Navigator.of(context);
      messenger.showSnackBar(SnackBar(
        content: Text(success
            ? '✅ Premium erişim geri yüklendi!'
            : 'Aktif abonelik bulunamadı.'),
      ));
      if (success) nav.pop();
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            )),
      ]),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;
  const _PlanCard({
    required this.package,
    required this.isSelected,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = package.storeProduct;
    final isYearly = product.identifier.toLowerCase().contains('yearly') ||
        product.identifier.toLowerCase().contains('annual') ||
        product.identifier.toLowerCase().contains('year');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : Colors.white),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(children: [
          // Radio dot
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color:
                      isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2),
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    isYearly ? 'Yıllık Plan' : 'Aylık Plan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (isRecommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('En İyi Değer',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
                if (isYearly)
                  Text(
                    '${_monthlyEquivalent(product.price)} / ay',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          // Price
          Text(
            product.priceString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ]),
      ),
    );
  }

  String _monthlyEquivalent(double yearlyPrice) {
    final monthly = yearlyPrice / 12;
    return monthly.toStringAsFixed(2);
  }
}

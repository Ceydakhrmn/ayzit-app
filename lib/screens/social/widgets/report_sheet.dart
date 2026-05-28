// =============================================
// screens/social/widgets/report_sheet.dart
// Bottom sheet that collects report reason + optional description,
// then calls ReportService.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/post_report.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/report_service.dart';

Future<void> showReportSheet(
  BuildContext context, {
  required ReportTarget target,
  required String targetId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _ReportSheet(target: target, targetId: targetId),
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.target, required this.targetId});

  final ReportTarget target;
  final String targetId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason _reason = ReportReason.spam;
  final _descCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  final _service = ReportService();

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  String _label(ReportReason r, {bool isEn = false}) {
    switch (r) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return isEn ? 'Harassment' : 'Taciz';
      case ReportReason.inappropriate:
        return isEn ? 'Inappropriate content' : 'Uygunsuz içerik';
      case ReportReason.hate:
        return isEn ? 'Hate speech' : 'Nefret söylemi';
      case ReportReason.other:
        return isEn ? 'Other' : 'Diğer';
    }
  }

  Future<void> _submit() async {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (uid == null) throw Exception('auth');
      await _service.createReport(
        target: widget.target,
        targetId: widget.targetId,
        reporterId: uid,
        reason: _reason,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEn ? 'Report received, thank you' : 'Şikayetin alındı, teşekkürler')),
      );
    } on ReportAlreadyExists {
      setState(() => _error = isEn ? 'You already reported this' : 'Bunu zaten şikayet etmişsin');
    } catch (e) {
      setState(() => _error = isEn ? 'Failed to send: $e' : 'Gönderim başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEn ? 'Report' : 'Şikayet Et',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            isEn ? 'Please select a reason' : 'Lütfen sebebi seç',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ...ReportReason.values.map(
            (r) => RadioListTile<ReportReason>(
              contentPadding: EdgeInsets.zero,
              value: r,
              groupValue: _reason,
              title: Text(_label(r, isEn: isEn)),
              onChanged: _loading ? null : (v) => setState(() => _reason = v!),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: isEn ? 'Description (optional)' : 'Açıklama (opsiyonel)',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(isEn ? 'SEND' : 'GÖNDER'),
          ),
        ],
      ),
    );
  }
}

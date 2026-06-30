// =============================================
// services/report_service.dart
// Creates reports in the top-level `reports` collection.
// Duplicate prevention: one report per (reporterId, targetType, targetId).
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_paths.dart';
import '../models/post_report.dart';

class ReportAlreadyExists implements Exception {
  @override
  String toString() => 'You already reported this content.';
}

class ReportService {
  ReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reportsCol =>
      _firestore.collection(FirestorePaths.reports);

  /// Creates a report. Uses a deterministic ID (reporter + target) so the
  /// same user can't report the same content twice.
  Future<void> createReport({
    required ReportTarget target,
    required String targetId,
    required String reporterId,
    required ReportReason reason,
    String? description,
  }) async {
    final docId = '${reporterId}_${target.name}_${targetId.replaceAll('/', '_')}';
    final ref = _reportsCol.doc(docId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) throw ReportAlreadyExists();

      tx.set(ref, {
        'targetType': target.name,
        'targetId': targetId,
        'reporterId': reporterId,
        'reason': reason.name,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    });
  }
}

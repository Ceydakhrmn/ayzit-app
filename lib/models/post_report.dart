// =============================================
// models/post_report.dart
// =============================================

enum ReportTarget { post, comment }

enum ReportReason { spam, harassment, inappropriate, hate, other }

class PostReport {
  final String id;
  final ReportTarget targetType;
  final String targetId; // postId, or "postId/commentId" for a comment
  final String reporterId;
  final ReportReason reason;
  final String? description;
  final DateTime createdAt;
  final String status; // pending | resolved | dismissed

  const PostReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reporterId,
    required this.reason,
    this.description,
    required this.createdAt,
    this.status = 'pending',
  });
}

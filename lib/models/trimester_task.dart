// =============================================
// models/trimester_task.dart
// Trimesterlere göre tıbbi test ve görev modeli.
// =============================================

enum TaskType { test, reminder, tool }

class TrimesterTask {
  final String title;
  final String description;
  final int trimester;        // 1, 2 veya 3
  final int startWeek;
  final int endWeek;
  final TaskType type;
  final bool isCritical;

  const TrimesterTask({
    required this.title,
    required this.description,
    required this.trimester,
    required this.startWeek,
    required this.endWeek,
    required this.type,
    this.isCritical = false,
  });

  /// Görevin belirtilen haftada aktif olup olmadığı.
  bool isActiveAt(int week) => week >= startWeek && week <= endWeek;
}

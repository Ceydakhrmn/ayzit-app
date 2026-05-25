// =============================================
// data/trimester_tasks.dart
// 3 trimesters için tıbbi test, görev ve araç listesi.
// =============================================

import '../models/trimester_task.dart';

const List<TrimesterTask> kTrimesterTasks = [

  // ─── 1. Trimester (1–12. Hafta) ───────────────────────────────────────

  TrimesterTask(
    title: 'Folik Asit Hatırlatması',
    description: 'Her gün folik asit aldın mı? Nöral tüp gelişimi için '
        'bu dönemde kritik.',
    trimester: 1,
    startWeek: 1,
    endWeek: 12,
    type: TaskType.reminder,
    isCritical: true,
  ),
  TrimesterTask(
    title: 'Kese Kontrolü',
    description: '4–5. haftada gebelik kesesi ultrasonla görülebilir. '
        'Doktoruna randevu al.',
    trimester: 1,
    startWeek: 4,
    endWeek: 5,
    type: TaskType.test,
  ),
  TrimesterTask(
    title: 'Kalp Atışı Dinleme & Rutin Tahliller',
    description: '6–8. haftada kalp atışı ultrasonda duyulabilir. '
        'Rutin kan ve idrar tahlilleri bu dönemde yapılır.',
    trimester: 1,
    startWeek: 6,
    endWeek: 8,
    type: TaskType.test,
  ),
  TrimesterTask(
    title: 'İkili Tarama & Ense Kalınlığı',
    description: '11–12. haftada ikili tarama testi ve ense kalınlığı '
        'ölçümü yapılır. Trisomi 21 taraması için önemli.',
    trimester: 1,
    startWeek: 11,
    endWeek: 12,
    type: TaskType.test,
    isCritical: true,
  ),

  // ─── 2. Trimester (13–26. Hafta) ──────────────────────────────────────

  TrimesterTask(
    title: 'Yeni Vitamin Düzeni',
    description: 'Demir, Magnezyum ve D Vitamini takviyeleri bu dönemde '
        'başlanmalı. Doktoruna danış.',
    trimester: 2,
    startWeek: 13,
    endWeek: 26,
    type: TaskType.reminder,
  ),
  TrimesterTask(
    title: 'Üçlü / Dörtlü Tarama',
    description: '16–20. haftada gerekirse üçlü veya dörtlü tarama testi '
        'yapılır.',
    trimester: 2,
    startWeek: 16,
    endWeek: 20,
    type: TaskType.test,
  ),
  TrimesterTask(
    title: 'Detaylı Ultrason',
    description: '20–24. haftada detaylı ultrason yapılmalı. Bebeğin tüm '
        'organları incelenir.',
    trimester: 2,
    startWeek: 20,
    endWeek: 24,
    type: TaskType.test,
    isCritical: true,
  ),
  TrimesterTask(
    title: 'Şeker Yükleme Testi (OGTT)',
    description: '24–27. haftada gestasyonel diyabeti taramak için şeker '
        'yükleme testi yapılır.',
    trimester: 2,
    startWeek: 24,
    endWeek: 26,
    type: TaskType.test,
    isCritical: true,
  ),

  // ─── 3. Trimester (27–40. Hafta) ──────────────────────────────────────

  TrimesterTask(
    title: 'Tekme Sayarı',
    description: '28. haftadan itibaren günlük tekme sayımı başlatılabilir. '
        'Günde en az 10 hareket normal kabul edilir.',
    trimester: 3,
    startWeek: 28,
    endWeek: 40,
    type: TaskType.tool,
  ),
  TrimesterTask(
    title: 'Kan Uyuşmazlığı İğnesi',
    description: 'Gerekirse 27–32. haftada Rh uyuşmazlığı için anti-D '
        'immünoglobülin uygulanır.',
    trimester: 3,
    startWeek: 27,
    endWeek: 32,
    type: TaskType.test,
  ),
  TrimesterTask(
    title: 'Çalışabilir / Çalışamaz Raporu',
    description: '32. haftada iş göremezlik raporu için doktorundan '
        'belge talep edebilirsin.',
    trimester: 3,
    startWeek: 32,
    endWeek: 32,
    type: TaskType.reminder,
  ),
  TrimesterTask(
    title: 'Kasılma / Sancı Sayarı',
    description: '36. haftadan itibaren kasılmalarını takip edebilirsin. '
        '5 dakikada bir düzenli kasılma doğum işareti olabilir.',
    trimester: 3,
    startWeek: 36,
    endWeek: 40,
    type: TaskType.tool,
  ),
  TrimesterTask(
    title: 'Haftalık NST Kontrolü',
    description: '36. haftadan itibaren haftalık non-stres testi (NST) '
        'için doktor takibi gerekir.',
    trimester: 3,
    startWeek: 36,
    endWeek: 40,
    type: TaskType.test,
    isCritical: true,
  ),
  TrimesterTask(
    title: 'Doğum Çantası',
    description: '40. haftada doğum çantanı hazırla: hastane evrakları, '
        'bebek kıyafetleri, hijyen malzemeleri.',
    trimester: 3,
    startWeek: 40,
    endWeek: 40,
    type: TaskType.reminder,
  ),
];

/// Verilen haftada aktif olan görevleri döndürür.
List<TrimesterTask> tasksForWeek(int week) =>
    kTrimesterTasks.where((t) => t.isActiveAt(week)).toList();

/// Verilen trimestedeki tüm görevleri döndürür.
List<TrimesterTask> tasksForTrimester(int trimester) =>
    kTrimesterTasks.where((t) => t.trimester == trimester).toList();

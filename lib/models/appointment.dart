// =============================================
// models/appointment.dart
// Kullanıcının eklediği randevu / hatırlatma kaydı.
// Firestore: users/{uid}/appointments/{autoId}
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final String note;

  const Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'dateTime': Timestamp.fromDate(dateTime),
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory Appointment.fromDoc(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      title: (map['title'] as String?) ?? 'Randevu',
      dateTime: (map['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: (map['note'] as String?) ?? '',
    );
  }

  /// Bu randevuya ait 3 bildirimin kararlı taban kimliği
  /// (bildirim id'leri: base, base+1, base+2).
  int get notificationBaseId => id.hashCode.abs() % 700000000;

  bool get isPast => dateTime.isBefore(DateTime.now());
}

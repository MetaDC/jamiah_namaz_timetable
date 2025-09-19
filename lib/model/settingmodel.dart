import 'package:cloud_firestore/cloud_firestore.dart';

class NamazTimeModel {
  final String islamicDate;
  final DateTime englishDate;
  final Map<String, dynamic> namazTime;
  final Map<String, dynamic> extraTime;

  NamazTimeModel({
    required this.islamicDate,
    required this.englishDate,
    required this.namazTime,
    required this.extraTime,
  });

  factory NamazTimeModel.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return NamazTimeModel.fromMap(data);
  }

  factory NamazTimeModel.fromMap(Map<String, dynamic> map) {
    return NamazTimeModel(
      islamicDate: map['islamicDate'] ?? '',
      englishDate: _parseDate(map['englishDate']),
      namazTime: Map<String, dynamic>.from(map['namazTime'] ?? {}),
      extraTime: Map<String, dynamic>.from(map['extraTime'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'islamicDate': islamicDate,
      'englishDate': Timestamp.fromDate(englishDate),
      'namazTime': namazTime,
      'extraTime': extraTime,
    };
  }

  NamazTimeModel copyWith({
    String? islamicDate,
    DateTime? englishDate,
    Map<String, dynamic>? namazTime,
    Map<String, dynamic>? extraTime,
  }) {
    return NamazTimeModel(
      islamicDate: islamicDate ?? this.islamicDate,
      englishDate: englishDate ?? this.englishDate,
      namazTime: namazTime ?? this.namazTime,
      extraTime: extraTime ?? this.extraTime,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}

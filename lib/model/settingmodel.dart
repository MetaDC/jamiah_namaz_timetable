import 'package:cloud_firestore/cloud_firestore.dart';

class NamazTimeModel {
  final int? islamicDay;
  final String? islamicMonth;
  final int? islamicYear;
  final String? islamicDayName;
  final String? duaText;
  final DateTime englishDate;
  final Map<String, dynamic> namazTime;
  final Map<String, dynamic> extraTime;

  NamazTimeModel({
    this.islamicDay,
    this.islamicMonth,
    this.islamicYear,
    this.islamicDayName,
    this.duaText,
    required this.englishDate,
    required this.namazTime,
    required this.extraTime,
  });

  /// Convert Firestore doc to Model
  factory NamazTimeModel.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return NamazTimeModel.fromMap(data);
  }

  factory NamazTimeModel.fromMap(Map<String, dynamic> map) {
    final islamic = map['islamicDate'] as Map<String, dynamic>? ?? {};

    return NamazTimeModel(
      islamicDay: islamic['day'],
      islamicMonth: islamic['month'],
      duaText: islamic['duaText'],
      islamicYear: islamic['year'],
      islamicDayName: islamic['dayName'],
      englishDate: _parseDate(map['englishDate']),
      namazTime: Map<String, dynamic>.from(map['namazTime'] ?? {}),
      extraTime: Map<String, dynamic>.from(map['extraTime'] ?? {}),
    );
  }

  /// Convert Model to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'islamicDate': {
        'day': islamicDay,
        'month': islamicMonth,
        'year': islamicYear,
        'dayName': islamicDayName,
        'duaText': duaText,
      },
      'englishDate': Timestamp.fromDate(englishDate),
      'namazTime': namazTime,
      'extraTime': extraTime,
    };
  }

  NamazTimeModel copyWith({
    int? islamicDay,
    String? islamicMonth,
    int? islamicYear,
    String? duaText,
    String? islamicDayName,
    DateTime? englishDate,
    Map<String, dynamic>? namazTime,
    Map<String, dynamic>? extraTime,
  }) {
    return NamazTimeModel(
      islamicDay: islamicDay ?? this.islamicDay,
      islamicMonth: islamicMonth ?? this.islamicMonth,
      duaText: duaText ?? this.duaText,
      islamicYear: islamicYear ?? this.islamicYear,
      islamicDayName: islamicDayName ?? this.islamicDayName,
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

enum StreakWeekday {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun;

  static StreakWeekday fromApi(String? raw) {
    switch (raw) {
      case 'tue':
        return StreakWeekday.tue;
      case 'wed':
        return StreakWeekday.wed;
      case 'thu':
        return StreakWeekday.thu;
      case 'fri':
        return StreakWeekday.fri;
      case 'sat':
        return StreakWeekday.sat;
      case 'sun':
        return StreakWeekday.sun;
      case 'mon':
      default:
        return StreakWeekday.mon;
    }
  }

  /// Short Uzbek label for the chip under each day cell.
  String get shortLabelUz => switch (this) {
    StreakWeekday.mon => 'Du',
    StreakWeekday.tue => 'Se',
    StreakWeekday.wed => 'Cho',
    StreakWeekday.thu => 'Pa',
    StreakWeekday.fri => 'Ju',
    StreakWeekday.sat => 'Sha',
    StreakWeekday.sun => 'Ya',
  };
}

class StreakDay {
  const StreakDay({
    required this.date,
    required this.weekday,
    required this.active,
  });

  final DateTime date;
  final StreakWeekday weekday;
  final bool active;

  factory StreakDay.fromJson(Map<String, dynamic> json) {
    final raw = json['date'] as String? ?? '';
    return StreakDay(
      date: DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0),
      weekday: StreakWeekday.fromApi(json['weekday'] as String?),
      active: json['active'] as bool? ?? false,
    );
  }
}

class WeeklyStreak {
  const WeeklyStreak({
    required this.currentStreak,
    required this.activeDaysThisWeek,
    required this.daysLeftThisWeek,
    required this.week,
  });

  final int currentStreak;
  final int activeDaysThisWeek;
  final int daysLeftThisWeek;
  final List<StreakDay> week;

  static const WeeklyStreak empty = WeeklyStreak(
    currentStreak: 0,
    activeDaysThisWeek: 0,
    daysLeftThisWeek: 7,
    week: [],
  );

  factory WeeklyStreak.fromJson(Map<String, dynamic> json) {
    final raw = json['week'];
    final week = raw is List
        ? raw
              .whereType<Map>()
              .map((e) => StreakDay.fromJson(e.cast<String, dynamic>()))
              .toList(growable: false)
        : const <StreakDay>[];
    return WeeklyStreak(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      activeDaysThisWeek: (json['activeDaysThisWeek'] as num?)?.toInt() ?? 0,
      daysLeftThisWeek: (json['daysLeftThisWeek'] as num?)?.toInt() ?? 0,
      week: week,
    );
  }
}

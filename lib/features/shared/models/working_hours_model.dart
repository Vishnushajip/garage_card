class DayWorkingHours {
  const DayWorkingHours({
    required this.day,
    this.isOpen = true,
    this.openTime = '08:30 AM',
    this.closeTime = '07:30 PM',
  });

  final String day;
  final bool isOpen;
  final String openTime;
  final String closeTime;

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  factory DayWorkingHours.fromMap(Map<String, dynamic> map) {
    return DayWorkingHours(
      day: map['day'] as String? ?? 'monday',
      isOpen: map['isOpen'] as bool? ?? true,
      openTime: map['openTime'] as String? ?? '08:30 AM',
      closeTime: map['closeTime'] as String? ?? '07:30 PM',
    );
  }

  DayWorkingHours copyWith({
    String? day,
    bool? isOpen,
    String? openTime,
    String? closeTime,
  }) {
    return DayWorkingHours(
      day: day ?? this.day,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  String get dayLabel => WorkingHoursSchedule.getDayLabel(day);
  String get shortDayLabel => WorkingHoursSchedule.getShortDayLabel(day);
  String get dayInitial => WorkingHoursSchedule.getDayInitial(day);
}

class WorkingHoursSchedule {
  WorkingHoursSchedule._();

  static const List<String> weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static List<DayWorkingHours> defaultSchedule() {
    return [
      const DayWorkingHours(
        day: 'monday',
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      ),
      const DayWorkingHours(
        day: 'tuesday',
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      ),
      const DayWorkingHours(
        day: 'wednesday',
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      ),
      const DayWorkingHours(
        day: 'thursday',
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      ),
      const DayWorkingHours(
        day: 'friday',
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      ),
      const DayWorkingHours(
        day: 'saturday',
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      ),
      const DayWorkingHours(
        day: 'sunday',
        isOpen: false,
        openTime: '09:00 AM',
        closeTime: '05:00 PM',
      ),
    ];
  }

  static List<DayWorkingHours> parse(dynamic data, [String? fallbackString]) {
    if (data is List && data.isNotEmpty) {
      final parsed = <DayWorkingHours>[];
      for (final item in data) {
        if (item is Map) {
          parsed.add(DayWorkingHours.fromMap(Map<String, dynamic>.from(item)));
        }
      }
      if (parsed.length == 7) {
        return parsed;
      }
    }

    String open = '08:30 AM';
    String close = '07:30 PM';

    if (fallbackString != null && fallbackString.trim().isNotEmpty) {
      final parts = fallbackString.split('-');
      if (parts.length == 2) {
        final candidateOpen = parts[0].trim();
        final candidateClose = parts[1].trim();
        if (candidateOpen.isNotEmpty && candidateClose.isNotEmpty) {
          open = candidateOpen;
          close = candidateClose;
        }
      }
    }

    return [
      DayWorkingHours(
        day: 'monday',
        isOpen: true,
        openTime: open,
        closeTime: close,
      ),
      DayWorkingHours(
        day: 'tuesday',
        isOpen: true,
        openTime: open,
        closeTime: close,
      ),
      DayWorkingHours(
        day: 'wednesday',
        isOpen: true,
        openTime: open,
        closeTime: close,
      ),
      DayWorkingHours(
        day: 'thursday',
        isOpen: true,
        openTime: open,
        closeTime: close,
      ),
      DayWorkingHours(
        day: 'friday',
        isOpen: true,
        openTime: open,
        closeTime: close,
      ),
      DayWorkingHours(
        day: 'saturday',
        isOpen: true,
        openTime: open,
        closeTime: close,
      ),
      DayWorkingHours(
        day: 'sunday',
        isOpen: false,
        openTime: open,
        closeTime: close,
      ),
    ];
  }

  static String getDayLabel(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Monday';
      case 'tuesday':
        return 'Tuesday';
      case 'wednesday':
        return 'Wednesday';
      case 'thursday':
        return 'Thursday';
      case 'friday':
        return 'Friday';
      case 'saturday':
        return 'Saturday';
      case 'sunday':
        return 'Sunday';
      default:
        return day;
    }
  }

  static String getShortDayLabel(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        return day;
    }
  }

  static String getDayInitial(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'M';
      case 'tuesday':
        return 'T';
      case 'wednesday':
        return 'W';
      case 'thursday':
        return 'T';
      case 'friday':
        return 'F';
      case 'saturday':
        return 'S';
      case 'sunday':
        return 'S';
      default:
        return day.isNotEmpty ? day[0].toUpperCase() : '';
    }
  }

  static String toDisplaySummary(List<DayWorkingHours> schedule) {
    if (schedule.isEmpty) return '9:00 AM - 7:00 PM';

    final openDays = schedule.where((d) => d.isOpen).toList();
    if (openDays.isEmpty) return 'Temporarily Closed';

    if (openDays.length == 7) {
      final first = openDays.first;
      final allSame = openDays.every(
        (d) => d.openTime == first.openTime && d.closeTime == first.closeTime,
      );
      if (allSame) {
        return 'Daily: ${first.openTime} - ${first.closeTime}';
      }
    }

    final monToSat = schedule.where((d) => d.day != 'sunday').toList();
    final sun = schedule.firstWhere(
      (d) => d.day == 'sunday',
      orElse: () => const DayWorkingHours(day: 'sunday', isOpen: false),
    );

    final monToSatAllOpen = monToSat.every((d) => d.isOpen);
    if (monToSatAllOpen) {
      final first = monToSat.first;
      final monToSatAllSame = monToSat.every(
        (d) => d.openTime == first.openTime && d.closeTime == first.closeTime,
      );
      if (monToSatAllSame) {
        if (!sun.isOpen) {
          return 'Mon - Sat: ${first.openTime} - ${first.closeTime}, Sun: Closed';
        } else {
          return 'Mon - Sat: ${first.openTime} - ${first.closeTime}, Sun: ${sun.openTime} - ${sun.closeTime}';
        }
      }
    }

    final monToFri = schedule
        .where((d) => d.day != 'saturday' && d.day != 'sunday')
        .toList();
    final sat = schedule.firstWhere(
      (d) => d.day == 'saturday',
      orElse: () => const DayWorkingHours(day: 'saturday', isOpen: false),
    );

    final monToFriAllOpen = monToFri.every((d) => d.isOpen);
    if (monToFriAllOpen) {
      final first = monToFri.first;
      final monToFriAllSame = monToFri.every(
        (d) => d.openTime == first.openTime && d.closeTime == first.closeTime,
      );
      if (monToFriAllSame) {
        final buffer = StringBuffer(
          'Mon - Fri: ${first.openTime} - ${first.closeTime}',
        );
        if (sat.isOpen) {
          buffer.write(', Sat: ${sat.openTime} - ${sat.closeTime}');
        } else {
          buffer.write(', Sat: Closed');
        }
        if (!sun.isOpen) {
          buffer.write(', Sun: Closed');
        } else {
          buffer.write(', Sun: ${sun.openTime} - ${sun.closeTime}');
        }
        return buffer.toString();
      }
    }

    final openDayNames = openDays.map((d) => d.shortDayLabel).join(', ');
    final first = openDays.first;
    final allOpenSame = openDays.every(
      (d) => d.openTime == first.openTime && d.closeTime == first.closeTime,
    );
    if (allOpenSame) {
      return '$openDayNames: ${first.openTime} - ${first.closeTime}';
    }

    return '$openDayNames: Open for selected hours';
  }

  static bool isCurrentlyOpen(List<DayWorkingHours> schedule, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final todayName = dayNames[current.weekday - 1];

    final todaySchedule = schedule.firstWhere(
      (d) => d.day.toLowerCase() == todayName,
      orElse: () => const DayWorkingHours(day: 'unknown', isOpen: false),
    );

    if (!todaySchedule.isOpen) return false;

    final openMinutes = _timeStringToMinutes(todaySchedule.openTime);
    final closeMinutes = _timeStringToMinutes(todaySchedule.closeTime);
    final nowMinutes = current.hour * 60 + current.minute;

    if (openMinutes == null || closeMinutes == null) return true;

    if (closeMinutes > openMinutes) {
      return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
    } else {
      return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
    }
  }

  static int? _timeStringToMinutes(String timeStr) {
    try {
      final normalized = timeStr.trim().toUpperCase();
      final isPM = normalized.contains('PM');
      final isAM = normalized.contains('AM');

      final cleaned = normalized
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim();
      final parts = cleaned.split(':');
      if (parts.length != 2) return null;

      var hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return hour * 60 + minute;
    } catch (_) {
      return null;
    }
  }
}

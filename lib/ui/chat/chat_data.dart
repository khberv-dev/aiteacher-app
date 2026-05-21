import 'package:flutter/material.dart';

enum ActivityType { chat, comment, task, call, complaint }

class ActivityTypeStyle {
  const ActivityTypeStyle({
    required this.label,
    required this.icon,
    required this.dotColor,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.bubbleBackground,
    required this.bubbleBorder,
  });

  final String label;
  final IconData icon;
  final Color dotColor;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color bubbleBackground;
  final Color bubbleBorder;
}

const Map<ActivityType, ActivityTypeStyle> kActivityTypeStyles = {
  ActivityType.chat: ActivityTypeStyle(
    label: 'Chat',
    icon: Icons.chat_bubble_outline_rounded,
    dotColor: Color(0xFF64748B),
    badgeBackground: Color(0xFFF1F5F9),
    badgeForeground: Color(0xFF64748B),
    bubbleBackground: Colors.white,
    bubbleBorder: Color(0x0D000000),
  ),
  ActivityType.comment: ActivityTypeStyle(
    label: 'Izoh',
    icon: Icons.edit_outlined,
    dotColor: Color(0xFFA16207),
    badgeBackground: Color(0xFFFEF9C3),
    badgeForeground: Color(0xFFA16207),
    bubbleBackground: Color(0xFFFFFBEB),
    bubbleBorder: Color(0x33F5B700),
  ),
  ActivityType.task: ActivityTypeStyle(
    label: 'Vazifa',
    icon: Icons.check_rounded,
    dotColor: Color(0xFF15803D),
    badgeBackground: Color(0xFFDCFCE7),
    badgeForeground: Color(0xFF15803D),
    bubbleBackground: Color(0xFFF0FDF4),
    bubbleBorder: Color(0x330D9488),
  ),
  ActivityType.call: ActivityTypeStyle(
    label: "Qo'ng'iroq",
    icon: Icons.phone_outlined,
    dotColor: Color(0xFF1D4ED8),
    badgeBackground: Color(0xFFDBEAFE),
    badgeForeground: Color(0xFF1D4ED8),
    bubbleBackground: Color(0xFFEFF6FF),
    bubbleBorder: Color(0x262563EB),
  ),
  ActivityType.complaint: ActivityTypeStyle(
    label: 'Ariza',
    icon: Icons.flag_outlined,
    dotColor: Color(0xFFBE123C),
    badgeBackground: Color(0xFFFFE4E6),
    badgeForeground: Color(0xFFBE123C),
    bubbleBackground: Color(0xFFFFF1F2),
    bubbleBorder: Color(0x33F43F5E),
  ),
};

class CallResult {
  const CallResult({required this.label, required this.note});

  final String label;
  final String note;
}

class TaskAction {
  const TaskAction({required this.label, required this.completed});

  final String label;
  final bool completed;
}

class ActivityItem {
  const ActivityItem({
    required this.authorName,
    required this.initials,
    required this.avatarColors,
    required this.type,
    required this.time,
    required this.body,
    this.callResult,
    this.task,
  });

  final String authorName;
  final String initials;
  final List<Color> avatarColors;
  final ActivityType type;
  final String time;
  final String body;
  final CallResult? callResult;
  final TaskAction? task;
}

class ActivityGroup {
  const ActivityGroup({required this.dateLabel, required this.items});

  final String dateLabel;
  final List<ActivityItem> items;
}

const List<ActivityGroup> kActivityGroups = [
  ActivityGroup(
    dateLabel: 'Bugun, 8-mart',
    items: [
      ActivityItem(
        authorName: 'Aziz Karimov',
        initials: 'AK',
        avatarColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        type: ActivityType.comment,
        time: '10:24',
        body:
            "Sardor bilan 1 yillik Premium shartnoma imzolandi — 1 980 000 so'm. "
            'Siz bilan zo\'r natijalarga erishamiz degan umiddaman! 🤝',
      ),
      ActivityItem(
        authorName: 'Nilufar Mirzayeva',
        initials: 'NM',
        avatarColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        type: ActivityType.call,
        time: '11:05',
        body: "Sardorga qo'ng'iroq qilindi — telefon ko'tarilmadi.",
        callResult: CallResult(label: "Javob yo'q", note: '· 2 daqiqa kutildi'),
      ),
      ActivityItem(
        authorName: 'Otabek Toshmatov',
        initials: 'OT',
        avatarColors: [Color(0xFF0D9488), Color(0xFF059669)],
        type: ActivityType.task,
        time: '12:30',
        body: "Ertaga soat 10:00 da Sardorga qayta qo'ng'iroq qilish kerak.",
        task: TaskAction(label: "Ertaga 10:00 — qo'ng'iroq", completed: false),
      ),
      ActivityItem(
        authorName: "Sardor (o'quvchi)",
        initials: 'S',
        avatarColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        type: ActivityType.chat,
        time: '13:15',
        body:
            "Assalomu alaykum! Bugungi speaking darsini qayta ko'ra olamanmi? "
            'Yozib qolmadim 😅',
      ),
      ActivityItem(
        authorName: "Sardor (o'quvchi)",
        initials: 'S',
        avatarColors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
        type: ActivityType.complaint,
        time: '14:02',
        body:
            'Sifat nazorati: AI mentor oxirgi 3 darsda bir xil topshiriq berdi. '
            "Yangilanish kerak deb o'ylayman.",
      ),
    ],
  ),
  ActivityGroup(
    dateLabel: 'Kecha, 7-mart',
    items: [
      ActivityItem(
        authorName: 'Aziz Karimov',
        initials: 'AK',
        avatarColors: [Color(0xFF0D9488), Color(0xFF059669)],
        type: ActivityType.task,
        time: '16:45',
        body:
            'Sardorga yangi dars materiallari yuborildi — B2 darajasi uchun '
            'Speaking pack.',
        task: TaskAction(label: 'Material yuborildi ✓', completed: true),
      ),
    ],
  ),
];

class FilterTab {
  const FilterTab({required this.label, required this.dotColor});

  final String label;
  final Color dotColor;
}

const List<FilterTab> kFilterTabs = [
  FilterTab(label: 'Hammasi', dotColor: Colors.white),
  FilterTab(label: 'Izohlar', dotColor: Color(0xFFA16207)),
  FilterTab(label: 'Vazifalar', dotColor: Color(0xFF15803D)),
  FilterTab(label: "Qo'ng'iroqlar", dotColor: Color(0xFF1D4ED8)),
  FilterTab(label: 'Arizalar', dotColor: Color(0xFFBE123C)),
];

const List<ActivityType> kComposeTypes = [
  ActivityType.chat,
  ActivityType.comment,
  ActivityType.task,
  ActivityType.call,
  ActivityType.complaint,
];

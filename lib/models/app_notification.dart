// ── Data model ──
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final NotificationType type;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    time: time,
    type: type,
    isRead: isRead ?? this.isRead,
  );
}

enum NotificationType { order, earnings, promo, system }

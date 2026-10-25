enum TodoItemType {
  deliveryToday,
  paymentDue,
  workPending,
  completedYesterday,
}

class DailyTodoItemModel {
  const DailyTodoItemModel({
    required this.id,
    this.jobId,
    this.invoiceId,
    required this.vehicleDisplay,
    required this.customerName,
    required this.customerPhone,
    required this.type,
    required this.title,
    required this.subtitle,
    this.amount,
    this.scheduledTime,
    this.isDone = false,
  });

  final String id;
  final String? jobId;
  final String? invoiceId;
  final String vehicleDisplay;
  final String customerName;
  final String customerPhone;
  final TodoItemType type;
  final String title;
  final String subtitle;
  final double? amount;
  final String? scheduledTime;
  final bool isDone;

  DailyTodoItemModel copyWith({
    String? id,
    String? jobId,
    String? invoiceId,
    String? vehicleDisplay,
    String? customerName,
    String? customerPhone,
    TodoItemType? type,
    String? title,
    String? subtitle,
    double? amount,
    String? scheduledTime,
    bool? isDone,
  }) {
    return DailyTodoItemModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      invoiceId: invoiceId ?? this.invoiceId,
      vehicleDisplay: vehicleDisplay ?? this.vehicleDisplay,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isDone: isDone ?? this.isDone,
    );
  }
}

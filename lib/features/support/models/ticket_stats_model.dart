class TicketStatsModel {
  const TicketStatsModel({
    this.total = 0,
    this.open = 0,
    this.newTickets = 0,
    this.inProgress = 0,
    this.waitingForCustomer = 0,
    this.waitingForMerchant = 0,
    this.resolved = 0,
    this.closed = 0,
  });

  final int total;
  final int open;
  final int newTickets;
  final int inProgress;
  final int waitingForCustomer;
  final int waitingForMerchant;
  final int resolved;
  final int closed;

  factory TicketStatsModel.empty() => const TicketStatsModel();
}

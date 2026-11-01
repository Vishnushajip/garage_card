import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appointment_repository.dart';
import 'chat_repository.dart';
import 'customer_data_repository.dart';
import 'estimate_repository.dart';
import 'garage_data_repository.dart';
import 'garage_repository_store.dart';
import 'inventory_repository.dart';
import 'invoice_repository.dart';
import 'job_workflow_repository.dart';
import 'notification_repository.dart';
import 'service_job_repository.dart';

export 'appointment_repository.dart';
export 'chat_repository.dart';
export 'customer_data_repository.dart';
export 'estimate_repository.dart';
export 'garage_data_repository.dart';
export 'garage_repository_store.dart';
export 'inventory_repository.dart';
export 'invoice_repository.dart';
export 'job_workflow_repository.dart';
export 'notification_repository.dart';
export 'service_job_repository.dart';

class GarageRepository extends GarageRepositoryStore
    with
        GarageDataRepository,
        ServiceJobRepository,
        JobWorkflowRepository,
        CustomerDataRepository,
        EstimateRepository,
        InvoiceRepository,
        InventoryRepository,
        AppointmentRepository,
        NotificationRepository,
        ChatRepository {
  GarageRepository();

  void clearCache() {
    garages.clear();
    customers.clear();
    vehicles.clear();
    jobs.clear();
    jobHistory.clear();
    inspections.clear();
    estimates.clear();
    invoices.clear();
    payments.clear();
    reminders.clear();
    notifications.clear();
    appointments.clear();
    services.clear();
    reviews.clear();
    conversations.clear();
    messages.clear();
    inventoryItems.clear();
  }
}

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepository();
});

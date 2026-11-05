import '../models/appointment_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../models/customer_model.dart';
import '../models/estimate_model.dart';
import '../models/garage_model.dart';
import '../models/garage_service_model.dart';
import '../models/inventory_item_model.dart';
import '../models/invoice_model.dart';
import '../models/job_status_history_model.dart';
import '../models/mechanic_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/review_model.dart';
import '../models/service_job_model.dart';
import '../models/service_reminder_model.dart';
import '../models/vehicle_inspection_model.dart';
import '../models/vehicle_model.dart';

abstract class GarageRepositoryStore {
  final List<GarageModel> garages = [];
  final List<CustomerModel> customers = [];
  final List<MechanicModel> mechanics = [];
  final List<VehicleModel> vehicles = [];
  final List<ServiceJobModel> jobs = [];
  final List<EstimateModel> estimates = [];
  final List<InvoiceModel> invoices = [];
  final List<PaymentModel> payments = [];
  final List<ServiceReminderModel> reminders = [];
  final List<NotificationModel> notifications = [];
  final List<AppointmentModel> appointments = [];
  final List<GarageServiceModel> services = [];
  final List<ReviewModel> reviews = [];
  final List<ConversationModel> conversations = [];
  final List<ChatMessageModel> messages = [];
  final List<InventoryItemModel> inventoryItems = [];
  final List<VehicleInspectionModel> inspections = [];
  final List<JobStatusHistoryModel> jobHistory = [];

  Future<String> generateGatePass(String garageId, String jobId);
}

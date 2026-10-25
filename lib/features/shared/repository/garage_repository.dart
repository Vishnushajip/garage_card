import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/location/geohash_helper.dart';
import '../models/appointment_model.dart';
import '../models/customer_model.dart';
import '../models/estimate_model.dart';
import '../models/garage_model.dart';
import '../models/invoice_model.dart';
import '../models/job_status_history_model.dart';
import '../models/line_item_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/service_job_model.dart';
import '../models/service_reminder_model.dart';
import '../models/vehicle_inspection_model.dart';
import '../models/vehicle_model.dart';

class GarageRepository {
  GarageRepository() {
    _initData();
  }

  final List<GarageModel> _garages = [];
  final List<CustomerModel> _customers = [];
  final List<VehicleModel> _vehicles = [];
  final List<ServiceJobModel> _jobs = [];
  final List<JobStatusHistoryModel> _jobHistory = [];
  final List<VehicleInspectionModel> _inspections = [];
  final List<EstimateModel> _estimates = [];
  final List<InvoiceModel> _invoices = [];
  final List<PaymentModel> _payments = [];
  final List<ServiceReminderModel> _reminders = [];
  final List<NotificationModel> _notifications = [];
  final List<AppointmentModel> _appointments = [];

  void _initData() {
    final now = DateTime.now();

    final g1 = GarageModel(
      id: 'garage_demo_1',
      name: 'Apex Precision Automotive',
      logoUrl: null,
      address: 'Near MG Road, Ravipuram, Kochi, Kerala',
      phone: '+91 98460 12345',
      email: 'service@apexprecision.com',
      currencyCode: 'INR',
      latitude: 9.9674,
      longitude: 76.2891,
      city: 'Kochi',
      rating: 4.9,
      openHours: '8:30 AM - 7:30 PM',
      isVerified: true,
      ownerUid: 'merchant_demo_1',
      taxNumber: '32AAACH7890Q1ZS',
      servicesOffered: const [
        'Periodic Maintenance',
        'Brake System Overhaul',
        'Engine Diagnostic & Tuning',
        'Suspension Repair',
        'AC Service & Gas Refill',
        'Wheel Alignment & Balancing',
      ],
      createdAt: now.subtract(const Duration(days: 120)),
    );

    final g2 = GarageModel(
      id: 'garage_demo_2',
      name: 'Royal Auto Works & Body Care',
      logoUrl: null,
      address: 'Kaloor - Kadavanthra Road, Kochi, Kerala',
      phone: '+91 98471 54321',
      email: 'info@royalautoworks.in',
      currencyCode: 'INR',
      latitude: 9.9880,
      longitude: 76.2940,
      city: 'Kochi',
      rating: 4.7,
      openHours: '9:00 AM - 8:00 PM',
      isVerified: true,
      ownerUid: 'merchant_demo_2',
      taxNumber: '32BBBCH4321P1ZT',
      servicesOffered: const [
        'Body Painting & Detailing',
        'Dent Removal',
        'Engine Overhaul',
        'Electrical Diagnostics',
      ],
      createdAt: now.subtract(const Duration(days: 90)),
    );

    final g3 = GarageModel(
      id: 'garage_demo_3',
      name: 'SpeedX Hybrid & EV Garage',
      logoUrl: null,
      address: 'Edappally Toll, Kochi, Kerala',
      phone: '+91 97450 99887',
      email: 'contact@speedxgarage.com',
      currencyCode: 'INR',
      latitude: 10.0234,
      longitude: 76.3082,
      city: 'Kochi',
      rating: 4.8,
      openHours: '9:00 AM - 7:00 PM',
      isVerified: true,
      ownerUid: 'merchant_demo_3',
      taxNumber: '32CCCCH1122K1ZU',
      servicesOffered: const [
        'Hybrid Battery Diagnostics',
        'High Voltage Systems',
        'General Service',
      ],
      createdAt: now.subtract(const Duration(days: 60)),
    );

    _garages.addAll([g1, g2, g3]);

    final c1 = CustomerModel(
      id: 'cust_demo_1',
      garageId: 'garage_demo_1',
      userId: 'customer_demo_uid',
      name: 'Arjun Menon',
      phone: '+91 98460 77112',
      email: 'arjun.menon@example.com',
      address: 'Hill View Enclave, Kakkanad, Kochi',
      notes: 'Prefers synthetic engine oil and OEM brake pads.',
      vehicleIds: const ['veh_1', 'veh_2'],
      createdAt: now.subtract(const Duration(days: 60)),
    );

    final c2 = CustomerModel(
      id: 'cust_demo_2',
      garageId: 'garage_demo_1',
      userId: 'user_cust_2',
      name: 'Sneha Nambiar',
      phone: '+91 94471 22334',
      email: 'sneha.n@example.com',
      address: 'Marine Drive Residences, Kochi',
      notes: 'Customer requested quick inspection before weekend trip.',
      vehicleIds: const ['veh_3'],
      createdAt: now.subtract(const Duration(days: 45)),
    );

    final c3 = CustomerModel(
      id: 'cust_demo_3',
      garageId: 'garage_demo_1',
      userId: 'user_cust_3',
      name: 'Faizal Khan',
      phone: '+91 98950 33445',
      email: 'faizal.khan@example.com',
      address: 'Aluva Bypass Road, Ernakulam',
      notes: 'Fleet vehicle coordinator.',
      vehicleIds: const ['veh_4'],
      createdAt: now.subtract(const Duration(days: 30)),
    );

    _customers.addAll([c1, c2, c3]);

    final v1 = VehicleModel(
      id: 'veh_1',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_1',
      make: 'Hyundai',
      model: 'Creta SX(O)',
      year: 2022,
      licensePlate: 'KL 07 CD 4488',
      vin: 'MALC381CLNM128490',
      currentOdometer: 34250,
      fuelType: 'Diesel',
      color: 'Phantom Black',
      lastServiceDate: now.subtract(const Duration(days: 75)),
      nextServiceDue: now.add(const Duration(days: 105)),
      createdAt: now.subtract(const Duration(days: 60)),
    );

    final v2 = VehicleModel(
      id: 'veh_2',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_1',
      make: 'Honda',
      model: 'City ZX',
      year: 2020,
      licensePlate: 'KL 07 BX 9021',
      vin: 'MAKGM665ELH004218',
      currentOdometer: 51200,
      fuelType: 'Petrol',
      color: 'Platinum White',
      lastServiceDate: now.subtract(const Duration(days: 140)),
      nextServiceDue: now.add(const Duration(days: 40)),
      createdAt: now.subtract(const Duration(days: 50)),
    );

    final v3 = VehicleModel(
      id: 'veh_3',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_2',
      make: 'Maruti Suzuki',
      model: 'Swift ZXi+',
      year: 2023,
      licensePlate: 'KL 07 DD 1102',
      currentOdometer: 18400,
      fuelType: 'Petrol',
      color: 'Solid Fire Red',
      lastServiceDate: now.subtract(const Duration(days: 20)),
      nextServiceDue: now.add(const Duration(days: 160)),
      createdAt: now.subtract(const Duration(days: 45)),
    );

    final v4 = VehicleModel(
      id: 'veh_4',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_3',
      make: 'Toyota',
      model: 'Innova Crysta 2.4 VX',
      year: 2021,
      licensePlate: 'KL 07 CC 7733',
      currentOdometer: 89000,
      fuelType: 'Diesel',
      color: 'Super White',
      lastServiceDate: now.subtract(const Duration(days: 15)),
      nextServiceDue: now.add(const Duration(days: 165)),
      createdAt: now.subtract(const Duration(days: 30)),
    );

    _vehicles.addAll([v1, v2, v3, v4]);

    final j1 = ServiceJobModel(
      id: 'job_demo_1',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_1',
      vehicleId: 'veh_1',
      jobNumber: 'JOB-2026-001',
      status: 'inProgress',
      odometerReading: 34250,
      complaints: const [
        'Brake pedal vibration during high-speed braking',
        'Slight squeaking sound from front suspension on speed bumps',
        'Scheduled 35,000 km general service and engine oil change',
      ],
      customerNotes:
          'Front brake rotor resurfacing and suspension bush replacement in progress. Expected delivery by 5:00 PM tomorrow.',
      internalNotes:
          'Front right disc rotor warped by 0.2mm. Turning on lathe approved. New Bosch semi-metallic pads ready.',
      technicianName: 'Suresh Kumar (Senior Tech)',
      estimatedCompletionDate: now.add(const Duration(hours: 24)),
      vehicleDisplay: '2022 Hyundai Creta (KL 07 CD 4488)',
      customerName: 'Arjun Menon',
      createdAt: now.subtract(const Duration(hours: 18)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    final j2 = ServiceJobModel(
      id: 'job_demo_2',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_1',
      vehicleId: 'veh_2',
      jobNumber: 'JOB-2026-002',
      status: 'completed',
      odometerReading: 48900,
      complaints: const [
        'AC cooling weak during afternoon heat',
        'Cabin air filter replacement',
      ],
      customerNotes: 'AC condenser cleaned, gas topped up, filter replaced.',
      internalNotes: 'Condenser pressure normal after cleaning.',
      technicianName: 'Vineeth Roy',
      completedDate: now.subtract(const Duration(days: 45)),
      vehicleDisplay: '2020 Honda City (KL 07 BX 9021)',
      customerName: 'Arjun Menon',
      createdAt: now.subtract(const Duration(days: 46)),
      updatedAt: now.subtract(const Duration(days: 45)),
    );

    final j3 = ServiceJobModel(
      id: 'job_demo_3',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_2',
      vehicleId: 'veh_3',
      jobNumber: 'JOB-2026-003',
      status: 'readyForCollection',
      odometerReading: 18400,
      complaints: const [
        'Full synthetic oil change and oil filter',
        'Wheel alignment check',
      ],
      customerNotes: 'Vehicle washed, sanitized and ready for pickup at billing counter.',
      internalNotes: 'Ready in Bay 4.',
      technicianName: 'Suresh Kumar',
      vehicleDisplay: '2023 Maruti Suzuki Swift (KL 07 DD 1102)',
      customerName: 'Sneha Nambiar',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 3)),
    );

    final j4 = ServiceJobModel(
      id: 'job_demo_4',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_1',
      vehicleId: 'veh_re_350',
      jobNumber: 'JOB-2026-004',
      status: 'readyForCollection',
      odometerReading: 12400,
      complaints: const [
        'Periodic 12,000 km service',
        'Chain clean, lubrication, and slack adjustment',
        'Engine oil & filter change',
      ],
      customerNotes: 'Service complete. Bike washed and ready for delivery today.',
      internalNotes: 'Motul 15W50 used. Delivered in Bay 1.',
      technicianName: 'Vineeth Roy',
      estimatedCompletionDate: now,
      completedDate: now,
      vehicleDisplay: '2022 Royal Enfield Classic 350 (KL 07 CE 8821)',
      customerName: 'Rahul Varma',
      createdAt: now.subtract(const Duration(hours: 22)),
      updatedAt: now.subtract(const Duration(hours: 1)),
    );

    final j5 = ServiceJobModel(
      id: 'job_demo_5',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_2',
      vehicleId: 'veh_mt_15',
      jobNumber: 'JOB-2026-005',
      status: 'inProgress',
      odometerReading: 19800,
      complaints: const [
        'Front fork oil seal leaking',
        'Front and rear brake disc pads replacement',
      ],
      customerNotes: 'Parts installed, final test ride in progress. Delivery scheduled today by 4:30 PM.',
      internalNotes: 'Yamaha genuine oil seals fitted.',
      technicianName: 'Suresh Kumar',
      estimatedCompletionDate: now.add(const Duration(hours: 3)),
      vehicleDisplay: '2023 Yamaha MT-15 V2 (KL 07 CF 3311)',
      customerName: 'Fahad Basheer',
      createdAt: now.subtract(const Duration(hours: 20)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    final j6 = ServiceJobModel(
      id: 'job_demo_6',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_3',
      vehicleId: 'veh_activa',
      jobNumber: 'JOB-2026-006',
      status: 'completed',
      odometerReading: 24500,
      complaints: const [
        'General service & engine oil change',
        'CVT drive belt inspection & brake tightening',
      ],
      customerNotes: 'Completed yesterday. Customer collected vehicle.',
      internalNotes: 'Belt in good condition. Adjusted play.',
      technicianName: 'Vineeth Roy',
      estimatedCompletionDate: now.subtract(const Duration(days: 1)),
      completedDate: now.subtract(const Duration(days: 1)),
      vehicleDisplay: '2021 Honda Activa 6G (KL 07 CD 9090)',
      customerName: 'Ananya Krishnan',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    final j7 = ServiceJobModel(
      id: 'job_demo_7',
      garageId: 'garage_demo_1',
      customerId: 'cust_demo_3',
      vehicleId: 'veh_wagonr',
      jobNumber: 'JOB-2026-007',
      status: 'completed',
      odometerReading: 62000,
      complaints: const [
        'Brake cleaning and fluid top-up',
        'Coolant replacement',
      ],
      customerNotes: 'Completed yesterday and delivered.',
      internalNotes: 'Brake shoes cleaned and adjusted.',
      technicianName: 'Suresh Kumar',
      estimatedCompletionDate: now.subtract(const Duration(days: 1)),
      completedDate: now.subtract(const Duration(days: 1)),
      vehicleDisplay: '2020 Maruti WagonR VXI (KL 07 BN 4411)',
      customerName: 'Deepak Nair',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    _jobs.addAll([j1, j2, j3, j4, j5, j6, j7]);

    _jobHistory.addAll([
      JobStatusHistoryModel(
        id: 'hist_1',
        jobId: 'job_demo_1',
        fromStatus: 'received',
        toStatus: 'inspectionPending',
        notes: 'Vehicle received at front desk, preliminary checklist generated.',
        updatedBy: 'Front Desk',
        timestamp: now.subtract(const Duration(hours: 18)),
      ),
      JobStatusHistoryModel(
        id: 'hist_2',
        jobId: 'job_demo_1',
        fromStatus: 'inspectionPending',
        toStatus: 'estimatePending',
        notes: 'Inspection complete. Warped rotor and worn pads documented.',
        updatedBy: 'Suresh Kumar',
        timestamp: now.subtract(const Duration(hours: 14)),
      ),
      JobStatusHistoryModel(
        id: 'hist_3',
        jobId: 'job_demo_1',
        fromStatus: 'estimatePending',
        toStatus: 'estimateApproved',
        notes: 'Customer reviewed and approved digital estimate EST-2026-089 via app.',
        updatedBy: 'Customer App',
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      JobStatusHistoryModel(
        id: 'hist_4',
        jobId: 'job_demo_1',
        fromStatus: 'estimateApproved',
        toStatus: 'inProgress',
        notes: 'Parts requisitioned from store. Disassembly started.',
        updatedBy: 'Suresh Kumar',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ]);

    final est1 = EstimateModel(
      id: 'est_demo_1',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_1',
      customerId: 'cust_demo_1',
      estimateNumber: 'EST-2026-089',
      items: const [
        LineItemModel(
          id: 'li_1',
          description: 'Synthetic Engine Oil 5W-30 (4 Liters)',
          type: 'part',
          quantity: 1,
          unitPrice: 2800.0,
        ),
        LineItemModel(
          id: 'li_2',
          description: 'Genuine OEM Oil Filter & Drain Washer',
          type: 'part',
          quantity: 1,
          unitPrice: 450.0,
        ),
        LineItemModel(
          id: 'li_3',
          description: 'Front Brake Pad Set (Bosch High Performance)',
          type: 'part',
          quantity: 1,
          unitPrice: 2400.0,
        ),
        LineItemModel(
          id: 'li_4',
          description: 'Front Brake Disc Rotor Lathe Turning & Balancing',
          type: 'labor',
          quantity: 2,
          unitPrice: 600.0,
        ),
        LineItemModel(
          id: 'li_5',
          description: 'Comprehensive 40-Point Periodic Inspection & Labor',
          type: 'labor',
          quantity: 1,
          unitPrice: 1200.0,
        ),
      ],
      subtotal: 8050.0,
      taxRate: 18.0,
      taxAmount: 1449.0,
      discountAmount: 500.0,
      totalAmount: 8999.0,
      currencyCode: 'INR',
      status: 'approved',
      version: 1,
      expiresAt: now.add(const Duration(days: 7)),
      approvedAt: now.subtract(const Duration(hours: 8)),
      createdAt: now.subtract(const Duration(hours: 14)),
    );

    _estimates.add(est1);

    final inv1 = InvoiceModel(
      id: 'inv_demo_1',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_2',
      estimateId: null,
      customerId: 'cust_demo_1',
      invoiceNumber: 'INV-2026-042',
      items: const [
        LineItemModel(
          id: 'inv_li_1',
          description: 'R134a AC Refrigerant Gas Refill (450g)',
          type: 'part',
          quantity: 1,
          unitPrice: 1500.0,
        ),
        LineItemModel(
          id: 'inv_li_2',
          description: 'Cabin AC Micro-Particle Air Filter',
          type: 'part',
          quantity: 1,
          unitPrice: 650.0,
        ),
        LineItemModel(
          id: 'inv_li_3',
          description: 'Condenser Cleaning & System Leak Test Labor',
          type: 'labor',
          quantity: 1,
          unitPrice: 850.0,
        ),
      ],
      subtotal: 3000.0,
      taxRate: 18.0,
      taxAmount: 540.0,
      discountAmount: 140.0,
      totalAmount: 3400.0,
      paidAmount: 3400.0,
      balanceDue: 0.0,
      currencyCode: 'INR',
      status: 'paid',
      issuedAt: now.subtract(const Duration(days: 45)),
      createdAt: now.subtract(const Duration(days: 45)),
    );

    final inv2 = InvoiceModel(
      id: 'inv_demo_2',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_4',
      customerId: 'cust_demo_1',
      invoiceNumber: 'INV-2026-088',
      items: const [
        LineItemModel(
          id: 'inv2_li_1',
          description: 'Motul 15W50 Semi-Synthetic Engine Oil (2.5L)',
          type: 'part',
          quantity: 1,
          unitPrice: 1000.0,
        ),
        LineItemModel(
          id: 'inv2_li_2',
          description: 'OEM Oil Filter & O-Ring Seal',
          type: 'part',
          quantity: 1,
          unitPrice: 250.0,
        ),
        LineItemModel(
          id: 'inv2_li_3',
          description: 'General Periodic Service & Tuning Labor',
          type: 'labor',
          quantity: 1,
          unitPrice: 1250.0,
        ),
      ],
      subtotal: 2500.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      discountAmount: 200.0,
      totalAmount: 2300.0,
      paidAmount: 2300.0,
      balanceDue: 0.0,
      currencyCode: 'INR',
      status: 'paid',
      issuedAt: now.subtract(const Duration(hours: 3)),
      createdAt: now.subtract(const Duration(hours: 3)),
    );

    final inv3 = InvoiceModel(
      id: 'inv_demo_3',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_3',
      customerId: 'cust_demo_2',
      invoiceNumber: 'INV-2026-089',
      items: const [
        LineItemModel(
          id: 'inv3_li_1',
          description: 'Castrol Magnatec 5W-30 Full Synthetic (3.5L)',
          type: 'part',
          quantity: 1,
          unitPrice: 2200.0,
        ),
        LineItemModel(
          id: 'inv3_li_2',
          description: 'Oil Filter & Sump Washer',
          type: 'part',
          quantity: 1,
          unitPrice: 400.0,
        ),
        LineItemModel(
          id: 'inv3_li_3',
          description: '4-Wheel Computerized Alignment & Balancing',
          type: 'labor',
          quantity: 1,
          unitPrice: 2000.0,
        ),
      ],
      subtotal: 4600.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      discountAmount: 100.0,
      totalAmount: 4500.0,
      paidAmount: 2000.0,
      balanceDue: 2500.0,
      currencyCode: 'INR',
      status: 'partially_paid',
      dueDate: now,
      issuedAt: now.subtract(const Duration(hours: 5)),
      createdAt: now.subtract(const Duration(hours: 5)),
    );

    final inv4 = InvoiceModel(
      id: 'inv_demo_4',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_6',
      customerId: 'cust_demo_3',
      invoiceNumber: 'INV-2026-085',
      items: const [
        LineItemModel(
          id: 'inv4_li_1',
          description: 'Honda Genuine 10W-30 4T Scooter Engine Oil',
          type: 'part',
          quantity: 1,
          unitPrice: 450.0,
        ),
        LineItemModel(
          id: 'inv4_li_2',
          description: 'Gearbox Oil & Spark Plug Replacement',
          type: 'part',
          quantity: 1,
          unitPrice: 350.0,
        ),
        LineItemModel(
          id: 'inv4_li_3',
          description: 'Full Scooter Service & CVT Inspection Labor',
          type: 'labor',
          quantity: 1,
          unitPrice: 1000.0,
        ),
      ],
      subtotal: 1800.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      discountAmount: 0.0,
      totalAmount: 1800.0,
      paidAmount: 1800.0,
      balanceDue: 0.0,
      currencyCode: 'INR',
      status: 'paid',
      issuedAt: now.subtract(const Duration(days: 1)),
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final inv5 = InvoiceModel(
      id: 'inv_demo_5',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_2',
      customerId: 'cust_demo_1',
      invoiceNumber: 'INV-2026-081',
      items: const [
        LineItemModel(
          id: 'inv5_li_1',
          description: 'Exide Matrix 45Ah Car Battery with Exchange',
          type: 'part',
          quantity: 1,
          unitPrice: 5500.0,
        ),
        LineItemModel(
          id: 'inv5_li_2',
          description: 'Electrical System Charging Test & Battery Installation',
          type: 'labor',
          quantity: 1,
          unitPrice: 3000.0,
        ),
      ],
      subtotal: 8500.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      discountAmount: 350.0,
      totalAmount: 8150.0,
      paidAmount: 8150.0,
      balanceDue: 0.0,
      currencyCode: 'INR',
      status: 'paid',
      issuedAt: now.subtract(const Duration(days: 3)),
      createdAt: now.subtract(const Duration(days: 3)),
    );

    final inv6 = InvoiceModel(
      id: 'inv_demo_6',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_1',
      customerId: 'cust_demo_3',
      invoiceNumber: 'INV-2026-072',
      items: const [
        LineItemModel(
          id: 'inv6_li_1',
          description: 'Front Suspension Lower Arms (Pair)',
          type: 'part',
          quantity: 1,
          unitPrice: 7200.0,
        ),
        LineItemModel(
          id: 'inv6_li_2',
          description: 'Stabilizer Link Rods & Bushing Kit',
          type: 'part',
          quantity: 1,
          unitPrice: 2800.0,
        ),
        LineItemModel(
          id: 'inv6_li_3',
          description: 'Suspension Overhaul Labor & Road Testing',
          type: 'labor',
          quantity: 1,
          unitPrice: 4200.0,
        ),
      ],
      subtotal: 14200.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      discountAmount: 500.0,
      totalAmount: 13700.0,
      paidAmount: 13700.0,
      balanceDue: 0.0,
      currencyCode: 'INR',
      status: 'paid',
      issuedAt: now.subtract(const Duration(days: 12)),
      createdAt: now.subtract(const Duration(days: 12)),
    );

    _invoices.addAll([inv1, inv2, inv3, inv4, inv5, inv6]);

    _payments.addAll([
      PaymentModel(
        id: 'pay_demo_1',
        garageId: 'garage_demo_1',
        invoiceId: 'inv_demo_1',
        customerId: 'cust_demo_1',
        amount: 3400.0,
        paymentMethod: 'upi',
        referenceNumber: 'UPI/202609081234/OKAXIS',
        recordedByUid: 'merchant_demo_1',
        notes: 'Paid via GPay at billing desk.',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      PaymentModel(
        id: 'pay_demo_2',
        garageId: 'garage_demo_1',
        invoiceId: 'inv_demo_2',
        customerId: 'cust_demo_1',
        amount: 2300.0,
        paymentMethod: 'upi',
        referenceNumber: 'UPI/202610245591/PAYTM',
        recordedByUid: 'merchant_demo_1',
        notes: 'Settled with ₹200 discount adjustment.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      PaymentModel(
        id: 'pay_demo_3',
        garageId: 'garage_demo_1',
        invoiceId: 'inv_demo_3',
        customerId: 'cust_demo_2',
        amount: 2000.0,
        paymentMethod: 'cash',
        referenceNumber: 'CASH/2026/044',
        recordedByUid: 'merchant_demo_1',
        notes: 'Advance paid in cash. ₹2,500 due on pickup.',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      PaymentModel(
        id: 'pay_demo_4',
        garageId: 'garage_demo_1',
        invoiceId: 'inv_demo_4',
        customerId: 'cust_demo_3',
        amount: 1800.0,
        paymentMethod: 'upi',
        referenceNumber: 'UPI/202610239922/PHONEPE',
        recordedByUid: 'merchant_demo_1',
        notes: 'Full payment on vehicle delivery yesterday.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      PaymentModel(
        id: 'pay_demo_5',
        garageId: 'garage_demo_1',
        invoiceId: 'inv_demo_5',
        customerId: 'cust_demo_1',
        amount: 8150.0,
        paymentMethod: 'card',
        referenceNumber: 'POS/HDFC/20261021/881',
        recordedByUid: 'merchant_demo_1',
        notes: 'Credit Card swipe with ₹350 seasonal discount.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      PaymentModel(
        id: 'pay_demo_6',
        garageId: 'garage_demo_1',
        invoiceId: 'inv_demo_6',
        customerId: 'cust_demo_3',
        amount: 13700.0,
        paymentMethod: 'bank_transfer',
        referenceNumber: 'NEFT/SBIN004811/9011',
        recordedByUid: 'merchant_demo_1',
        notes: 'Direct bank transfer. ₹500 goodwill discount applied.',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ]);

    _reminders.addAll([
      ServiceReminderModel(
        id: 'rem_1',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_1',
        vehicleId: 'veh_1',
        vehicleDisplay: '2022 Hyundai Creta (KL 07 CD 4488)',
        title: '40,000 km Major Service & Brake Fluid Flush',
        serviceType: 'Major Service',
        dueDate: now.add(const Duration(days: 75)),
        dueMileage: 40000,
        status: 'pending',
        isCustomerReported: false,
        notes: 'Check transmission fluid level and coolant condition.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      ServiceReminderModel(
        id: 'rem_2',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_1',
        vehicleId: 'veh_2',
        vehicleDisplay: '2020 Honda City (KL 07 BX 9021)',
        title: 'Annual Wheel Alignment & Tyre Rotation',
        serviceType: 'Tyre Maintenance',
        dueDate: now.add(const Duration(days: 14)),
        dueMileage: 55000,
        status: 'pending',
        isCustomerReported: false,
        notes: 'Recommended due to recent highway usage.',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ]);

    _notifications.addAll([
      NotificationModel(
        id: 'notif_1',
        recipientUid: 'customer_demo_uid',
        title: 'Vehicle Ready for Collection!',
        body:
            'All service tasks completed on your Hyundai Creta (JOB-2026-001). Ready for pickup.',
        type: 'readyForCollection',
        referenceId: 'job_demo_1',
        referenceType: 'service_job',
        imageUrl:
            'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
        deepLink: '/customer/jobs/job_demo_1',
        garageId: 'garage_demo_1',
        eventId: 'job_demo_1_readyForCollection',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif_2',
        recipientUid: 'customer_demo_uid',
        title: 'Estimate Ready for Approval',
        body: 'Itemized estimate EST-2026-089 for ₹8,999 is waiting for your review.',
        type: 'estimateCreated',
        referenceId: 'est_demo_1',
        referenceType: 'estimate',
        imageUrl:
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
        deepLink: '/customer/estimates',
        garageId: 'garage_demo_1',
        eventId: 'est_demo_1_created',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      NotificationModel(
        id: 'notif_3',
        recipientUid: 'customer_demo_uid',
        title: 'Periodic Service Due',
        body: 'Honda City scheduled maintenance and tyre alignment is due in 14 days.',
        type: 'serviceReminderDue',
        referenceId: 'rem_2',
        referenceType: 'reminder',
        imageUrl:
            'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&q=80',
        deepLink: '/customer/reminders',
        garageId: 'garage_demo_1',
        eventId: 'rem_2_due',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'notif_m1',
        recipientUid: 'user_merchant_1',
        title: 'New Service Booking Request',
        body: 'Kiran Kumar booked General Service for Royal Enfield Himalayan.',
        type: 'serviceRequestSubmitted',
        referenceId: 'job_today_1',
        referenceType: 'service_job',
        imageUrl:
            'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
        deepLink: '/merchant/jobs',
        garageId: 'garage_demo_1',
        eventId: 'job_today_1_request',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: 'notif_m2',
        recipientUid: 'user_merchant_1',
        title: 'Estimate Approved by Customer',
        body: 'Customer approved estimate EST-2024-001 (₹4,500). Ready to start work.',
        type: 'estimateApproved',
        referenceId: 'est_m_1',
        referenceType: 'estimate',
        imageUrl:
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
        deepLink: '/merchant/estimates',
        garageId: 'garage_demo_1',
        eventId: 'est_m_1_approved',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: 'notif_m3',
        recipientUid: 'user_merchant_1',
        title: 'Vehicle Ready for Collection',
        body: 'Yamaha MT-15 (JOB-2024-002) is ready for pickup by customer Priya.',
        type: 'readyForCollection',
        referenceId: 'job_today_2',
        referenceType: 'service_job',
        imageUrl:
            'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
        deepLink: '/merchant/jobs',
        garageId: 'garage_demo_1',
        eventId: 'job_today_2_ready',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ]);

    _appointments.add(
      AppointmentModel(
        id: 'app_1',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_1',
        customerName: 'Arjun Menon',
        customerPhone: '+91 98460 77112',
        vehicleInfo: '2022 Hyundai Creta',
        preferredDate: now.add(const Duration(days: 3)),
        preferredTime: '10:30 AM',
        issueDescription: 'Battery voltage warning flickering on dashboard.',
        status: 'accepted',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    );
  }

  Future<List<GarageModel>> getNearbyGarages({
    required double latitude,
    required double longitude,
    double radiusKm = AppConstants.defaultNearbyRadiusKm,
    String? searchQuery,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final list = _garages.where((g) {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchName = g.name.toLowerCase().contains(query);
        final matchCity = g.city.toLowerCase().contains(query);
        final matchAddress = g.address.toLowerCase().contains(query);
        if (!matchName && !matchCity && !matchAddress) return false;
      }
      final dist = GeohashHelper.calculateDistanceKm(
        lat1: latitude,
        lon1: longitude,
        lat2: g.latitude,
        lon2: g.longitude,
      );
      return dist <= radiusKm * 2;
    }).toList();

    list.sort((a, b) {
      final distA = GeohashHelper.calculateDistanceKm(
        lat1: latitude,
        lon1: longitude,
        lat2: a.latitude,
        lon2: a.longitude,
      );
      final distB = GeohashHelper.calculateDistanceKm(
        lat1: latitude,
        lon1: longitude,
        lat2: b.latitude,
        lon2: b.longitude,
      );
      return distA.compareTo(distB);
    });

    return list.take(limit).toList();
  }

  Future<GarageModel?> getGarageDetails(String garageId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _garages.cast<GarageModel?>().firstWhere(
          (g) => g?.id == garageId,
          orElse: () => null,
        );
  }

  Future<void> updateGarageProfile(GarageModel updated) async {
    final index = _garages.indexWhere((g) => g.id == updated.id);
    if (index >= 0) {
      _garages[index] = updated;
    } else {
      _garages.add(updated);
    }
  }

  Future<List<ServiceJobModel>> getServiceJobs({
    String? garageId,
    String? customerId,
    String? status,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    var query = _jobs.where((j) {
      if (garageId != null && j.garageId != garageId) return false;
      if (customerId != null && j.customerId != customerId) return false;
      if (status != null && status.isNotEmpty && j.status != status) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchJobNo = j.jobNumber.toLowerCase().contains(q);
        final matchVehicle = j.vehicleDisplay.toLowerCase().contains(q);
        final matchCustomer = j.customerName.toLowerCase().contains(q);
        if (!matchJobNo && !matchVehicle && !matchCustomer) return false;
      }
      return true;
    }).toList();

    query.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<ServiceJobModel> createServiceJob(ServiceJobModel job) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final newJob = job.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _jobs.insert(0, newJob);

    _jobHistory.insert(
      0,
      JobStatusHistoryModel(
        id: const Uuid().v4(),
        jobId: newJob.id,
        fromStatus: 'none',
        toStatus: newJob.status,
        notes: 'Job created',
        updatedBy: 'Staff',
        timestamp: DateTime.now(),
      ),
    );

    return newJob;
  }

  Future<void> updateJobStatus({
    required String jobId,
    required String newStatus,
    required String notes,
    required String updatedBy,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index >= 0) {
      final old = _jobs[index];
      _jobs[index] = old.copyWith(
        status: newStatus,
        customerNotes: notes.isNotEmpty ? notes : old.customerNotes,
        updatedAt: DateTime.now(),
      );

      _jobHistory.insert(
        0,
        JobStatusHistoryModel(
          id: const Uuid().v4(),
          jobId: jobId,
          fromStatus: old.status,
          toStatus: newStatus,
          notes: notes,
          updatedBy: updatedBy,
          timestamp: DateTime.now(),
        ),
      );

      _notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: old.customerId,
          title: 'Status Updated: ${old.vehicleDisplay}',
          body: notes.isNotEmpty
              ? notes
              : 'Your vehicle repair status is now $newStatus.',
          type: 'job_status',
          referenceId: jobId,
          referenceType: 'service_job',
          imageUrl: newStatus == 'readyForCollection'
              ? 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80'
              : 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
          deepLink: '/customer/jobs/$jobId',
          garageId: old.garageId,
          eventId: 'job_${jobId}_$newStatus',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<List<JobStatusHistoryModel>> getJobHistory(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _jobHistory.where((h) => h.jobId == jobId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<CustomerModel>> getCustomers({
    required String garageId,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    var query = _customers.where((c) {
      if (c.garageId != garageId) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchName = c.name.toLowerCase().contains(q);
        final matchPhone = c.phone.toLowerCase().contains(q);
        final matchEmail = c.email.toLowerCase().contains(q);
        if (!matchName && !matchPhone && !matchEmail) return false;
      }
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final newCust = customer.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _customers.insert(0, newCust);
    return newCust;
  }

  Future<List<VehicleModel>> getVehicles({
    String? garageId,
    String? customerId,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    var query = _vehicles.where((v) {
      if (garageId != null && v.garageId != garageId) return false;
      if (customerId != null && v.customerId != customerId) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchPlate = v.licensePlate.toLowerCase().contains(q);
        final matchMake = v.make.toLowerCase().contains(q);
        final matchModel = v.model.toLowerCase().contains(q);
        if (!matchPlate && !matchMake && !matchModel) return false;
      }
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final newVeh = vehicle.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _vehicles.insert(0, newVeh);
    return newVeh;
  }

  Future<List<EstimateModel>> getEstimates({
    String? garageId,
    String? customerId,
    int page = 0,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    var query = _estimates.where((e) {
      if (garageId != null && e.garageId != garageId) return false;
      if (customerId != null && e.customerId != customerId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<EstimateModel> createEstimate(EstimateModel estimate) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final newEst = estimate.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _estimates.insert(0, newEst);
    return newEst;
  }

  Future<bool> approveEstimate(String estimateId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _estimates.indexWhere((e) => e.id == estimateId);
    if (index >= 0) {
      final est = _estimates[index];
      _estimates[index] = est.copyWith(
        status: 'approved',
        approvedAt: DateTime.now(),
      );

      final jobId = est.jobId;
      final jobIdx = _jobs.indexWhere((j) => j.id == jobId);
      if (jobIdx >= 0) {
        _jobs[jobIdx] = _jobs[jobIdx].copyWith(status: 'estimateApproved');
      }

      _notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: 'user_merchant_1',
          title: 'Estimate Approved by Customer',
          body:
              'Customer approved estimate ${est.estimateNumber}. Ready to start work.',
          type: 'estimateApproved',
          referenceId: estimateId,
          referenceType: 'estimate',
          imageUrl:
              'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
          deepLink: '/merchant/estimates',
          garageId: est.garageId,
          eventId: 'est_${estimateId}_approved',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );

      return true;
    }
    return false;
  }

  Future<bool> rejectEstimate(String estimateId, String reason) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _estimates.indexWhere((e) => e.id == estimateId);
    if (index >= 0) {
      final est = _estimates[index];
      _estimates[index] = est.copyWith(
        status: 'rejected',
        rejectionReason: reason,
      );

      _notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: 'user_merchant_1',
          title: 'Estimate Declined',
          body: 'Customer declined estimate ${est.estimateNumber}: $reason',
          type: 'estimateRejected',
          referenceId: estimateId,
          referenceType: 'estimate',
          imageUrl:
              'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
          deepLink: '/merchant/estimates',
          garageId: est.garageId,
          eventId: 'est_${estimateId}_rejected',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );

      return true;
    }
    return false;
  }

  Future<List<InvoiceModel>> getInvoices({
    String? garageId,
    String? customerId,
    int page = 0,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    var query = _invoices.where((inv) {
      if (garageId != null && inv.garageId != garageId) return false;
      if (customerId != null && inv.customerId != customerId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<InvoiceModel> createInvoiceFromEstimate(EstimateModel estimate) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final inv = InvoiceModel(
      id: const Uuid().v4(),
      garageId: estimate.garageId,
      jobId: estimate.jobId,
      estimateId: estimate.id,
      customerId: estimate.customerId,
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch % 100000}',
      items: estimate.items,
      subtotal: estimate.subtotal,
      taxRate: estimate.taxRate,
      taxAmount: estimate.taxAmount,
      discountAmount: estimate.discountAmount,
      totalAmount: estimate.totalAmount,
      paidAmount: 0.0,
      balanceDue: estimate.totalAmount,
      currencyCode: estimate.currencyCode,
      status: 'unpaid',
      issuedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    _invoices.insert(0, inv);

    _notifications.insert(
      0,
      NotificationModel(
        id: const Uuid().v4(),
        recipientUid: estimate.customerId,
        title: 'New Service Invoice Issued',
        body:
            'Invoice ${inv.invoiceNumber} has been generated and is ready for payment.',
        type: 'invoiceIssued',
        referenceId: inv.id,
        referenceType: 'invoice',
        imageUrl:
            'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80',
        deepLink: '/customer/invoices',
        garageId: estimate.garageId,
        eventId: 'inv_${inv.id}_issued',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    return inv;
  }

  Future<PaymentModel> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    required String referenceNumber,
    required String notes,
    required String recordedByUid,
    double discountAdjustment = 0.0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final invIndex = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (invIndex < 0) {
      throw Exception('Invoice not found');
    }

    final currentInv = _invoices[invIndex];
    final updatedDiscount = currentInv.discountAmount + discountAdjustment;
    final updatedTotal =
        (currentInv.totalAmount - discountAdjustment).clamp(0.0, double.infinity);
    final updatedPaid = currentInv.paidAmount + amount;
    final updatedBalance =
        (updatedTotal - updatedPaid).clamp(0.0, double.infinity);
    final updatedStatus = updatedBalance <= 0.0 ? 'paid' : 'partially_paid';

    _invoices[invIndex] = currentInv.copyWith(
      discountAmount: updatedDiscount,
      totalAmount: updatedTotal,
      paidAmount: updatedPaid,
      balanceDue: updatedBalance,
      status: updatedStatus,
    );

    final payment = PaymentModel(
      id: const Uuid().v4(),
      garageId: currentInv.garageId,
      invoiceId: invoiceId,
      customerId: currentInv.customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      recordedByUid: recordedByUid,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _payments.insert(0, payment);

    _notifications.insert(
      0,
      NotificationModel(
        id: const Uuid().v4(),
        recipientUid: currentInv.customerId,
        title: 'Payment Received',
        body:
            'Payment of ₹${amount.toStringAsFixed(0)} recorded for invoice ${currentInv.invoiceNumber}. Balance: ₹${updatedBalance.toStringAsFixed(0)}',
        type: 'paymentRecorded',
        referenceId: payment.id,
        referenceType: 'payment',
        imageUrl:
            'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80',
        deepLink: '/customer/invoices',
        garageId: currentInv.garageId,
        eventId: 'pay_${payment.id}_recorded',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    return payment;
  }

  Future<List<PaymentModel>> getPayments({
    String? garageId,
    String? invoiceId,
    int page = 0,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    var query = _payments.where((p) {
      if (garageId != null && p.garageId != garageId) return false;
      if (invoiceId != null && p.invoiceId != invoiceId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<List<ServiceReminderModel>> getReminders({
    String? garageId,
    String? customerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _reminders.where((r) {
      if (garageId != null && r.garageId != garageId) return false;
      if (customerId != null && r.customerId != customerId) return false;
      return true;
    }).toList();
  }

  Future<ServiceReminderModel> createReminder(ServiceReminderModel reminder) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final newRem = reminder.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _reminders.insert(0, newRem);
    return newRem;
  }

  Future<List<NotificationModel>> getNotifications({
    required String recipientUid,
    int page = 0,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final list = _notifications.where((n) => n.recipientUid == recipientUid).toList();
    final start = page * limit;
    if (start >= list.length) return [];
    final end = (start + limit) > list.length ? list.length : (start + limit);
    return list.sublist(start, end);
  }

  Future<NotificationModel> createNotification(NotificationModel notification) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _notifications.insert(0, notification);
    return notification;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  Future<List<AppointmentModel>> getAppointments({
    String? garageId,
    String? customerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _appointments.where((a) {
      if (garageId != null && a.garageId != garageId) return false;
      if (customerId != null && a.customerId != customerId) return false;
      return true;
    }).toList();
  }

  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final newApp = appointment.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _appointments.insert(0, newApp);

    _notifications.insert(
      0,
      NotificationModel(
        id: const Uuid().v4(),
        recipientUid: 'user_merchant_1',
        title: 'New Service Request Received',
        body:
            '${appointment.customerName} requested an appointment for ${appointment.vehicleInfo}.',
        type: 'serviceRequestSubmitted',
        referenceId: newApp.id,
        referenceType: 'appointment',
        imageUrl:
            'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
        deepLink: '/merchant/jobs',
        garageId: appointment.garageId,
        eventId: 'app_${newApp.id}_submitted',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    return newApp;
  }

  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx >= 0) {
      _appointments[idx] = _appointments[idx].copyWith(status: newStatus);
    }
  }

  Future<List<VehicleInspectionModel>> getInspections(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _inspections.where((i) => i.jobId == jobId).toList();
  }

  Future<void> saveInspection(VehicleInspectionModel inspection) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _inspections.removeWhere((i) => i.id == inspection.id);
    _inspections.add(inspection);

    final job = _jobs.where((j) => j.id == inspection.jobId).firstOrNull;
    if (job != null) {
      _notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: job.customerId,
          title: 'Digital Inspection Completed',
          body:
              'Vehicle health check completed for ${job.vehicleDisplay}. Tap to view items.',
          type: 'inspectionCompleted',
          referenceId: inspection.id,
          referenceType: 'inspection',
          imageUrl:
              'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
          deepLink: '/customer/jobs/${job.id}',
          garageId: job.garageId,
          eventId: 'insp_${inspection.id}_saved',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepository();
});

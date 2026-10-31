import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/location/geohash_helper.dart';
import 'package:garage_card/core/pagination/paginated_result.dart';

import '../models/appointment_model.dart';
import '../models/customer_model.dart';
import '../models/estimate_model.dart';
import '../models/garage_model.dart';
import '../models/invoice_model.dart';
import '../models/job_status_history_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../models/garage_service_model.dart';
import '../models/garage_search_result_model.dart';
import '../pricing/smart_pricing_engine.dart';
import '../models/line_item_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/review_model.dart';
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
  final List<GarageServiceModel> _services = [];
  final List<ReviewModel> _reviews = [];
  final List<ConversationModel> _conversations = [];
  final List<ChatMessageModel> _messages = [];

  void _initData() {
    final now = DateTime.now();

    final g1 = GarageModel(
      id: 'garage_demo_1',
      name: 'Apex Speed Auto Care',
      logoUrl: 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?w=300&q=80',
      coverImageUrl: 'https://images.unsplash.com/photo-1613214149922-f1809c99b414?w=1200&q=80',
      address: 'Near MG Road, Ravipuram, Kochi, Kerala',
      phone: '+91 98460 12345',
      email: 'service@apexprecision.com',
      currencyCode: 'INR',
      latitude: 9.9674,
      longitude: 76.2891,
      city: 'Kochi',
      rating: 4.9,
      reviewCount: 38,
      openHours: '8:30 AM - 7:30 PM',
      isVerified: true,
      ownerUid: 'merchant_demo_1',
      taxNumber: '32AAACH7890Q1ZS',
      servicesOffered: const [
        'Periodic Service',
        'Water Service & Wash',
        'Brake System Overhaul',
        'Engine Diagnostic & Tuning',
        'Suspension Repair',
        'AC Service & Gas Refill',
      ],
      createdAt: now.subtract(const Duration(days: 120)),
    );

    final g2 = GarageModel(
      id: 'garage_demo_2',
      name: 'Royal Auto Works & Body Care',
      logoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300&q=80',
      coverImageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=1200&q=80',
      address: 'Kaloor - Kadavanthra Road, Kochi, Kerala',
      phone: '+91 98471 54321',
      email: 'info@royalautoworks.in',
      currencyCode: 'INR',
      latitude: 9.9880,
      longitude: 76.2940,
      city: 'Kochi',
      rating: 4.7,
      reviewCount: 24,
      openHours: '9:00 AM - 8:00 PM',
      isVerified: true,
      ownerUid: 'merchant_demo_2',
      taxNumber: '32BBBCH4321P1ZT',
      servicesOffered: const [
        'Periodic Service',
        'Water Service & Wash',
        'Body Painting & Detailing',
        'Engine Overhaul',
      ],
      createdAt: now.subtract(const Duration(days: 90)),
    );

    final g3 = GarageModel(
      id: 'garage_demo_3',
      name: 'SpeedX Hybrid & EV Garage',
      logoUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=300&q=80',
      coverImageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=1200&q=80',
      address: 'Edappally Toll, Kochi, Kerala',
      phone: '+91 97450 99887',
      email: 'contact@speedxgarage.com',
      currencyCode: 'INR',
      latitude: 10.0234,
      longitude: 76.3082,
      city: 'Kochi',
      rating: 4.8,
      reviewCount: 19,
      openHours: '9:00 AM - 7:00 PM',
      isVerified: true,
      ownerUid: 'merchant_demo_3',
      taxNumber: '32CCCCH1122K1ZU',
      servicesOffered: const [
        'Periodic Service',
        'Water Service & Wash',
        'Hybrid Battery Diagnostics',
        'High Voltage Systems',
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

    final cVishnu = CustomerModel(
      id: 'cust_vishnu',
      garageId: 'garage_demo_1',
      userId: 'vishnushaji431@gmail.com',
      name: 'Vishnu Shaji',
      phone: '+91 98460 77889',
      email: 'vishnushaji431@gmail.com',
      address: 'Panampilly Nagar, Kochi, Kerala',
      notes: 'Valued VIP customer.',
      vehicleIds: const [
        'veh_vishnu_1',
        'veh_vishnu_2',
        'veh_vishnu_3',
        'veh_vishnu_4',
      ],
      createdAt: now.subtract(const Duration(days: 90)),
    );

    _customers.addAll([c1, c2, c3, cVishnu]);

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
      licensePlate: 'KL 07 CC 773',
      currentOdometer: 89000,
      fuelType: 'Diesel',
      color: 'Super White',
      lastServiceDate: now.subtract(const Duration(days: 15)),
      nextServiceDue: now.add(const Duration(days: 165)),
      createdAt: now.subtract(const Duration(days: 30)),
    );

    final vishnuVehicles = getVishnuDummyVehicles(
      customerId: 'vishnushaji431@gmail.com',
    );

    _vehicles.addAll([v1, v2, v3, v4, ...vishnuVehicles]);

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
      customerNotes: 'Front brake rotor resurfacing and suspension bush replacement in progress. Expected delivery by 5:00 PM tomorrow.',
      internalNotes: 'Front right disc rotor warped by 0.2mm. Turning on lathe approved. New Bosch semi-metallic pads ready.',
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
      customerNotes:
          'Vehicle washed, sanitized and ready for pickup at billing counter.',
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
      customerNotes:
          'Service complete. Bike washed and ready for delivery today.',
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

    final jVishnu1 = ServiceJobModel(
      id: 'job_vishnu_1',
      garageId: 'garage_demo_1',
      customerId: 'vishnushaji431@gmail.com',
      vehicleId: 'veh_vishnu_1',
      jobNumber: 'JOB-2026-077',
      status: 'inProgress',
      odometerReading: 14250,
      complaints: const [
        'Annual inspection & synthetic oil service',
        'Brake pad wear check and diagnostic scan',
      ],
      customerNotes: 'Synthetic engine oil replacement and multi-point inspection underway. Ready by 4:00 PM.',
      internalNotes:
          'Castrol Edge 0W-20 LL-17FE+ oil change done. Front pad wear 15%.',
      technicianName: 'Arun Varma (Lead European Specialist)',
      estimatedCompletionDate: now.add(const Duration(hours: 3)),
      vehicleDisplay: '2023 BMW 330i M Sport (KL 07 CZ 0007)',
      customerName: 'Vishnu Shaji',
      createdAt: now.subtract(const Duration(hours: 4)),
      updatedAt: now.subtract(const Duration(hours: 1)),
    );

    final jVishnu2 = ServiceJobModel(
      id: 'job_vishnu_2',
      garageId: 'garage_demo_1',
      customerId: 'vishnushaji431@gmail.com',
      vehicleId: 'veh_vishnu_2',
      jobNumber: 'JOB-2026-082',
      status: 'readyForCollection',
      odometerReading: 41200,
      complaints: const [
        '40,000 KM Periodic Service & 4x4 Drivetrain Inspection',
        'Wheel alignment and dynamic balancing',
      ],
      customerNotes: 'All 4WD transfer case oils replaced, air filter and cabin filter replaced. Vehicle detailed and sanitised.',
      internalNotes: 'Propeller shaft greased. Alignment zeroed. Test drive completed without vibrations.',
      technicianName: 'Suresh Kumar (SUV & 4x4 Specialist)',
      estimatedCompletionDate: now.subtract(const Duration(hours: 1)),
      completedDate: now.subtract(const Duration(hours: 1)),
      vehicleDisplay: '2022 Toyota Fortuner Legender 4x4 (KL 07 BY 4455)',
      customerName: 'Vishnu Shaji',
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 1)),
    );

    final jVishnu3 = ServiceJobModel(
      id: 'job_vishnu_3',
      garageId: 'garage_demo_1',
      customerId: 'vishnushaji431@gmail.com',
      vehicleId: 'veh_vishnu_3',
      jobNumber: 'JOB-2026-065',
      status: 'completed',
      odometerReading: 18900,
      complaints: const [
        'DSG 7-Speed Transmission Software Calibration',
        'Annual scheduled maintenance & AC filter',
      ],
      customerNotes: 'Transmission adaptation values reset and road tested. Air conditioning disinfectant treatment applied.',
      internalNotes: 'DSG clutch slip parameters within factory tolerances. Bill settled in full.',
      technicianName: 'Arun Varma (Lead European Specialist)',
      estimatedCompletionDate: now.subtract(const Duration(days: 2)),
      completedDate: now.subtract(const Duration(days: 2)),
      vehicleDisplay: '2023 Volkswagen Virtus GT Plus (KL 07 CB 1122)',
      customerName: 'Vishnu Shaji',
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now.subtract(const Duration(days: 2)),
    );

    final jVishnu4 = ServiceJobModel(
      id: 'job_vishnu_4',
      garageId: 'garage_demo_1',
      customerId: 'vishnushaji431@gmail.com',
      vehicleId: 'veh_vishnu_4',
      jobNumber: 'JOB-2026-091',
      status: 'received',
      odometerReading: 8400,
      complaints: const [
        'Twin-cylinder valve clearance check and throttle body balance',
        'Chain slack adjustment and lubing',
      ],
      customerNotes: 'Cold start valve noise check requested. Throttle balance to eliminate low-RPM hesitation.',
      internalNotes: 'Motorcycle checked in at collection bay 2. Awaiting cold engine temperature for valve check.',
      technicianName: 'Rajesh Pillai (Motorcycle Specialist)',
      estimatedCompletionDate: now.add(const Duration(days: 1, hours: 4)),
      vehicleDisplay: '2021 Royal Enfield Continental GT 650 (KL 07 BW 6500)',
      customerName: 'Vishnu Shaji',
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    _jobs.addAll([
      j1,
      j2,
      j3,
      j4,
      j5,
      j6,
      j7,
      jVishnu1,
      jVishnu2,
      jVishnu3,
      jVishnu4,
    ]);

    _jobHistory.addAll([
      JobStatusHistoryModel(
        id: 'hist_1',
        jobId: 'job_demo_1',
        fromStatus: 'received',
        toStatus: 'inspectionPending',
        notes:
            'Vehicle received at front desk, preliminary checklist generated.',
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

    final estPending = EstimateModel(
      id: 'est_demo_pending',
      garageId: 'garage_demo_1',
      jobId: 'job_demo_1',
      customerId: 'cust_demo_1',
      estimateNumber: 'EST-2026-089',
      items: const [
        LineItemModel(
          id: 'li_p1',
          description: 'Front Brake Disc Rotor Lathe Turning & Balancing',
          type: 'labor',
          quantity: 2,
          unitPrice: 600.0,
        ),
        LineItemModel(
          id: 'li_p2',
          description: 'Bosch High-Performance Front Brake Pad Set',
          type: 'part',
          quantity: 1,
          unitPrice: 2400.0,
        ),
        LineItemModel(
          id: 'li_p3',
          description: 'Front Suspension Bushing Replacement & Wheel Alignment',
          type: 'labor',
          quantity: 1,
          unitPrice: 1500.0,
        ),
      ],
      subtotal: 5100.0,
      taxRate: 18.0,
      taxAmount: 918.0,
      discountAmount: 250.0,
      totalAmount: 5768.0,
      currencyCode: 'INR',
      status: 'sent',
      version: 1,
      expiresAt: now.add(const Duration(days: 5)),
      createdAt: now.subtract(const Duration(hours: 4)),
    );

    _estimates.add(estPending);

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
      ServiceReminderModel(
        id: 'rem_vishnu_1',
        garageId: 'garage_demo_1',
        customerId: 'vishnushaji431@gmail.com',
        vehicleId: 'veh_vishnu_2',
        vehicleDisplay: '2022 Toyota Fortuner Legender (KL 07 BY 4455)',
        title: 'Tire Rotation & 40,000 km Service',
        serviceType: 'Tire & Maintenance',
        dueDate: now.add(const Duration(days: 20)),
        dueMileage: 40000,
        status: 'pending',
        isCustomerReported: false,
        notes: 'Scheduled tire rotation, wheel alignment, and engine oil inspection for Fortuner Legender.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    _notifications.addAll([
      NotificationModel(
        id: 'notif_1',
        recipientUid: 'customer_demo_uid',
        title: 'Vehicle Ready for Collection!',
        body: 'All service tasks completed on your Hyundai Creta (JOB-2026-001). Ready for pickup.',
        type: 'readyForCollection',
        referenceId: 'job_demo_1',
        referenceType: 'service_job',
        imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
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

    _services.addAll([
      GarageServiceModel(
        id: 'srv_1',
        garageId: 'garage_demo_1',
        name: 'Engine Oil & Filter Service',
        description: 'Complete engine flush, grade-specific oil change and OEM filter replacement.',
        category: 'Maintenance',
        pricingMethod: 'attribute',
        estimatedDuration: '1 hour',
        terms: 'Includes 10-point fluid level inspection.',
        attributeRules: const [
          PricingAttributeRule(
            label: 'Motorcycle up to 150cc',
            vehicleType: 'motorcycle',
            minCc: 0,
            maxCc: 150,
            price: 350.0,
          ),
          PricingAttributeRule(
            label: 'Motorcycle 151cc - 350cc',
            vehicleType: 'motorcycle',
            minCc: 151,
            maxCc: 350,
            price: 550.0,
          ),
          PricingAttributeRule(
            label: 'Motorcycle 351cc & above',
            vehicleType: 'motorcycle',
            minCc: 351,
            maxCc: 2000,
            price: 850.0,
          ),
          PricingAttributeRule(
            label: 'Car (Hatchback/Sedan)',
            vehicleType: 'car',
            price: 1500.0,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      GarageServiceModel(
        id: 'srv_2',
        garageId: 'garage_demo_1',
        name: 'Periodic Comprehensive Service',
        description: 'Full inspection, spark plug clean/replace, brake adjustment, lubrication and throttle tuning.',
        category: 'General',
        pricingMethod: 'category',
        estimatedDuration: '3-4 hours',
        categoryPrices: const {
          'scooter': 350.0,
          'motorcycle': 450.0,
          'car': 1200.0,
          'commercial': 2200.0,
        },
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      GarageServiceModel(
        id: 'srv_3',
        garageId: 'garage_demo_1',
        name: 'Foam Wash & Polish',
        description: 'High pressure underbody wash, active foam bath, tyre shine and dashboard polishing.',
        category: 'Washing',
        pricingMethod: 'fixed',
        fixedPrice: 250.0,
        estimatedDuration: '45 mins',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      GarageServiceModel(
        id: 'srv_4',
        garageId: 'garage_demo_1',
        name: 'Brake Disc Resurfacing & Pad Fitting',
        description: 'Precision lathe turning of warped rotors, calliper grease and anti-squeal pad fitting.',
        category: 'Mechanical',
        pricingMethod: 'startingPrice',
        startingPrice: 450.0,
        estimatedDuration: '2 hours',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      GarageServiceModel(
        id: 'srv_5',
        garageId: 'garage_demo_1',
        name: 'Dent Removal & Panel Painting',
        description: 'Computerized shade matching, spot putty repair and infrared heated booth curing.',
        category: 'Bodywork',
        pricingMethod: 'quotation',
        estimatedDuration: '1-2 days',
        terms: 'Exact estimate prepared upon physical inspection.',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ]);

    _reviews.addAll([
      ReviewModel(
        id: 'rev_1',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_1',
        customerName: 'Arjun Menon',
        customerPhotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        rating: 5.0,
        reviewText: 'Superb turnaround time! Fixed front brake vibration smoothly and charges were exactly as per estimate.',
        consentShareName: true,
        consentSharePhoto: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: 'rev_2',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_2',
        customerName: 'Sneha Nambiar',
        rating: 5.0,
        reviewText: 'Very transparent pricing and courteous staff. Highly recommended in Kochi.',
        consentShareName: true,
        consentSharePhoto: false,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      ReviewModel(
        id: 'rev_3',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_3',
        customerName: 'Anonymous Driver',
        rating: 4.5,
        reviewText: 'Clean work on my vehicle. WhatsApp status updates kept me updated throughout.',
        consentShareName: false,
        consentSharePhoto: false,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ]);
  }

  Future<void> seedInitialFirestoreDataIfNeeded() async {
    if (!FirebaseConfig.isInitialized) return;
    try {
      final collection = FirebaseFirestore.instance.collection('garages');
      final checkSnap = await collection
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 4));
      if (checkSnap.docs.isNotEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (final g in _garages) {
        batch.set(collection.doc(g.id), g.toFirestore());
      }
      await batch.commit();

      for (final g in _garages) {
        final services = _generateDefaultPackages(g.id);
        final sBatch = FirebaseFirestore.instance.batch();
        for (final s in services) {
          final doc = collection.doc(g.id).collection('services').doc(s.id);
          sBatch.set(doc, s.toFirestore());
        }
        await sBatch.commit();
      }
    } catch (e) {
      debugPrint('GARAGE_REPO_SEED_ERROR: $e');
    }
  }

  Future<List<GarageModel>> getNearbyGarages({
    required double latitude,
    required double longitude,
    double radiusKm = AppConstants.defaultNearbyRadiusKm,
    String? searchQuery,
    int limit = 20,
  }) async {
    List<GarageModel> source = [];

    if (FirebaseConfig.isInitialized) {
      try {
        final collection = FirebaseFirestore.instance.collection('garages');
        var snapshot = await collection
            .limit(50)
            .get()
            .timeout(const Duration(seconds: 4));
        if (snapshot.docs.isEmpty) {
          await seedInitialFirestoreDataIfNeeded();
          snapshot = await collection
              .limit(50)
              .get()
              .timeout(const Duration(seconds: 4));
        }
        source = snapshot.docs
            .map((d) => GarageModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_NEARBY_GARAGES_ERROR: $e');
        return [];
      }
    } else {
      source = _garages;
    }

    final list = source.where((g) {
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
    if (FirebaseConfig.isInitialized) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .get()
            .timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          return GarageModel.fromFirestore(doc.data()!, doc.id);
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    return _garages.cast<GarageModel?>().firstWhere(
      (g) => g?.id == garageId,
      orElse: () => null,
    );
  }

  Future<GarageModel?> getGarageByOwnerUid(String ownerUid) async {
    if (FirebaseConfig.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('garages')
            .where('ownerUid', isEqualTo: ownerUid)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 4));
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          return GarageModel.fromFirestore(doc.data(), doc.id);
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    return _garages.cast<GarageModel?>().firstWhere(
      (g) => g?.ownerUid == ownerUid,
      orElse: () => null,
    );
  }

  Future<void> updateGarageProfile(GarageModel updated) async {
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(updated.id)
            .set(updated.toFirestore(), SetOptions(merge: true));
      } catch (_) {}
    }

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
    String? userEmail,
    String? status,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
    final effectiveCustomerId = (customerId != null && customerId.isNotEmpty)
        ? customerId
        : (userEmail != null && userEmail.isNotEmpty ? userEmail : null);
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer =
        effectiveCustomerId != null && effectiveCustomerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    String? currentEmail;
    try {
      if (FirebaseConfig.isInitialized) {
        currentEmail = FirebaseAuth.instance.currentUser?.email;
      }
    } catch (_) {}
    final effectiveEmail = (userEmail ?? currentEmail ?? '').toLowerCase();
    final isVishnu =
        effectiveEmail == 'vishnushaji431@gmail.com' ||
        effectiveEmail == '318@gmail.com' ||
        effectiveEmail.contains('vishnu') ||
        effectiveEmail.contains('318') ||
        (hasCustomer &&
            (effectiveCustomerId.toLowerCase() == 'vishnushaji431@gmail.com' ||
                effectiveCustomerId.toLowerCase() == '318@gmail.com' ||
                effectiveCustomerId.toLowerCase().contains('vishnu') ||
                effectiveCustomerId.toLowerCase().contains('318')));

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('serviceJobs');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: effectiveCustomerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('serviceJobs')
              .where('customerId', isEqualTo: effectiveCustomerId);
        }

        if (status != null && status.isNotEmpty) {
          query = query.where('status', isEqualTo: status);
        }

        query = query.limit(limit);
        final snapshot = await query.get().timeout(const Duration(seconds: 3));
        var items = snapshot.docs
            .map((d) => ServiceJobModel.fromFirestore(d.data(), d.id))
            .toList();

        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          items = items.where((j) {
            return j.jobNumber.toLowerCase().contains(q) ||
                j.vehicleDisplay.toLowerCase().contains(q) ||
                j.customerName.toLowerCase().contains(q);
          }).toList();
        }

        items.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

        if (items.isNotEmpty) {
          return items;
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_SERVICE_JOBS_ERROR: $e');
      }
    }

    var query = _jobs.where((j) {
      if (hasGarage && j.garageId != garageId && garageId != 'garage_demo_1') {
        return false;
      }
      if (hasCustomer) {
        if (isVishnu) {
          if (j.customerId == 'vishnushaji431@gmail.com' ||
              j.id.startsWith('job_vishnu_') ||
              j.customerId == effectiveCustomerId) {
            if (status != null && status.isNotEmpty && j.status != status) {
              return false;
            }
            return true;
          }
        }
        if (j.customerId != effectiveCustomerId &&
            j.customerId != 'cust_demo_1') {
          return false;
        }
      }
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

    query.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<PaginatedResult<ServiceJobModel>> getServiceJobsPaginated({
    String? garageId,
    String? customerId,
    String? status,
    String? search,
    int limit = 10,
    Object? lastDocument,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return const PaginatedResult<ServiceJobModel>(
        items: [],
        lastDocument: null,
        hasMore: false,
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('serviceJobs');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('serviceJobs')
              .where('customerId', isEqualTo: customerId);
        }

        if (status != null && status.isNotEmpty) {
          query = query.where('status', isEqualTo: status);
        }

        query = query.limit(limit);

        if (lastDocument is DocumentSnapshot<Map<String, dynamic>>) {
          query = query.startAfterDocument(lastDocument);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 3));
        var items = snapshot.docs
            .map((d) => ServiceJobModel.fromFirestore(d.data(), d.id))
            .toList();

        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          items = items.where((j) {
            return j.jobNumber.toLowerCase().contains(q) ||
                j.vehicleDisplay.toLowerCase().contains(q) ||
                j.customerName.toLowerCase().contains(q);
          }).toList();
        }

        if (items.isNotEmpty) {
          final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          final hasMore = snapshot.docs.length >= limit;

          return PaginatedResult<ServiceJobModel>(
            items: items,
            lastDocument: lastDoc,
            hasMore: hasMore,
          );
        }
      } catch (_) {}
    }

    final isVishnu =
        hasCustomer &&
        (customerId.toLowerCase().contains('vishnu') ||
            customerId.toLowerCase().contains('318') ||
            customerId.toLowerCase() == 'vishnushaji431@gmail.com' ||
            customerId.toLowerCase() == '318@gmail.com');

    var query = _jobs.where((j) {
      if (hasGarage && j.garageId != garageId && garageId != 'garage_demo_1') {
        return false;
      }
      if (hasCustomer) {
        if (isVishnu) {
          return j.customerId.toLowerCase().contains('vishnu') ||
              j.customerId.toLowerCase().contains('318') ||
              j.customerName.toLowerCase().contains('vishnu') ||
              j.id.startsWith('job_vishnu_');
        }
        if (j.customerId != customerId && j.customerId != 'cust_demo_1') {
          return false;
        }
      }
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

    final startIndex = (lastDocument != null && lastDocument is int)
        ? lastDocument
        : 0;
    if (startIndex >= query.length) {
      return const PaginatedResult<ServiceJobModel>(
        items: [],
        lastDocument: null,
        hasMore: false,
      );
    }
    final endIndex = (startIndex + limit) > query.length
        ? query.length
        : (startIndex + limit);
    final items = query.sublist(startIndex, endIndex);
    return PaginatedResult<ServiceJobModel>(
      items: items,
      lastDocument: endIndex,
      hasMore: endIndex < query.length,
    );
  }

  Future<ServiceJobModel> createServiceJob(ServiceJobModel job) async {
    final id = job.id.isNotEmpty ? job.id : const Uuid().v4();
    final newJob = job.copyWith(
      id: id,
      createdAt: job.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (FirebaseConfig.isInitialized && newJob.garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newJob.garageId)
            .collection('serviceJobs')
            .doc(newJob.id)
            .set(newJob.toFirestore(), SetOptions(merge: true));

        final history = JobStatusHistoryModel(
          id: const Uuid().v4(),
          jobId: newJob.id,
          fromStatus: 'none',
          toStatus: newJob.status,
          notes: 'Job created',
          updatedBy: 'Staff',
          timestamp: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newJob.garageId)
            .collection('serviceJobs')
            .doc(newJob.id)
            .collection('history')
            .doc(history.id)
            .set(history.toFirestore());
      } catch (_) {}
    }

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
    final index = _jobs.indexWhere((j) => j.id == jobId);
    ServiceJobModel? targetJob;
    if (index >= 0) {
      final old = _jobs[index];
      targetJob = old.copyWith(
        status: newStatus,
        customerNotes: notes.isNotEmpty ? notes : old.customerNotes,
        updatedAt: DateTime.now(),
      );
      _jobs[index] = targetJob;

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

      final isCompletion = newStatus == 'completed';
      final deepLink = isCompletion
          ? '/customer/garages/${old.garageId}?action=review&jobId=$jobId'
          : '/customer/jobs/$jobId';
      final notifTitle = isCompletion
          ? 'Service Completed: ${old.vehicleDisplay}'
          : 'Status Updated: ${old.vehicleDisplay}';
      final notifBody = isCompletion
          ? (notes.isNotEmpty
                ? notes
                : 'Your vehicle service is complete! Tap to rate your experience.')
          : (notes.isNotEmpty
                ? notes
                : 'Your vehicle repair status is now $newStatus.');

      _notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: old.customerId,
          title: notifTitle,
          body: notifBody,
          type: 'job_status',
          referenceId: jobId,
          referenceType: 'service_job',
          imageUrl: isCompletion
              ? 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80'
              : 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
          deepLink: deepLink,
          garageId: old.garageId,
          eventId: 'job_${jobId}_$newStatus',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (FirebaseConfig.isInitialized && targetJob != null) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(targetJob.garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .update({
              'status': newStatus,
              if (notes.isNotEmpty) 'customerNotes': notes,
              'updatedAt': DateTime.now().toIso8601String(),
            });

        final historyId = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(targetJob.garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .collection('history')
            .doc(historyId)
            .set({
              'id': historyId,
              'jobId': jobId,
              'fromStatus': targetJob.status,
              'toStatus': newStatus,
              'notes': notes,
              'updatedBy': updatedBy,
              'timestamp': DateTime.now().toIso8601String(),
            });

        final isCompletion = newStatus == 'completed';
        final deepLink = isCompletion
            ? '/customer/garages/${targetJob.garageId}?action=review&jobId=$jobId'
            : '/customer/jobs/$jobId';
        final notifTitle = isCompletion
            ? 'Service Completed: ${targetJob.vehicleDisplay}'
            : 'Status Updated: ${targetJob.vehicleDisplay}';
        final notifBody = isCompletion
            ? (notes.isNotEmpty
                  ? notes
                  : 'Your vehicle service is complete! Tap to rate your experience.')
            : (notes.isNotEmpty
                  ? notes
                  : 'Your vehicle repair status is now $newStatus.');

        final notifId = 'job_${jobId}_$newStatus';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetJob.customerId)
            .collection('notifications')
            .doc(notifId)
            .set({
              'recipientUid': targetJob.customerId,
              'title': notifTitle,
              'body': notifBody,
              'type': 'job_status',
              'referenceId': jobId,
              'referenceType': 'service_job',
              'imageUrl': isCompletion
                  ? 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80'
                  : 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
              'deepLink': deepLink,
              'garageId': targetJob.garageId,
              'eventId': notifId,
              'isRead': false,
              'createdAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<List<JobStatusHistoryModel>> getJobHistory(String jobId) async {
    if (FirebaseConfig.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collectionGroup('history')
            .where('jobId', isEqualTo: jobId)
            .get()
            .timeout(const Duration(seconds: 3));
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs
              .map((d) => JobStatusHistoryModel.fromFirestore(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        }
      } catch (_) {}
    }
    return _jobHistory.where((h) => h.jobId == jobId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<CustomerModel>> getCustomers({
    required String garageId,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
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
    final newCust = customer.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _customers.insert(0, newCust);
    return newCust;
  }

  static List<VehicleModel> getVishnuDummyVehicles({
    required String customerId,
  }) {
    final now = DateTime.now();
    return [
      VehicleModel(
        id: 'veh_vishnu_1',
        garageId: 'garage_demo_1',
        customerId: customerId,
        make: 'BMW',
        model: '3 Series 330i M Sport',
        year: 2023,
        licensePlate: 'KL 07 CZ 0007',
        vehicleType: 'car',
        engineCc: 1998,
        vin: 'WBA5R1109NFP78234',
        currentOdometer: 14250,
        fuelType: 'Petrol',
        color: 'Portimao Blue Metallic',
        lastServiceDate: now.subtract(const Duration(days: 60)),
        nextServiceDue: now.add(const Duration(days: 120)),
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      VehicleModel(
        id: 'veh_vishnu_2',
        garageId: 'garage_demo_1',
        customerId: customerId,
        make: 'Toyota',
        model: 'Fortuner Legender 4x4 AT',
        year: 2022,
        licensePlate: 'KL 07 BY 4455',
        vehicleType: 'car',
        engineCc: 2755,
        vin: 'MBJ11B61N01089241',
        currentOdometer: 38800,
        fuelType: 'Diesel',
        color: 'Platinum White Pearl',
        lastServiceDate: now.subtract(const Duration(days: 40)),
        nextServiceDue: now.add(const Duration(days: 140)),
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      VehicleModel(
        id: 'veh_vishnu_3',
        garageId: 'garage_demo_1',
        customerId: customerId,
        make: 'Volkswagen',
        model: 'Virtus GT Plus 1.5 TSI DSG',
        year: 2023,
        licensePlate: 'KL 07 CB 1122',
        vehicleType: 'car',
        engineCc: 1498,
        vin: 'MEXG12345PK998811',
        currentOdometer: 21500,
        fuelType: 'Petrol',
        color: 'Wild Cherry Red',
        lastServiceDate: now.subtract(const Duration(days: 15)),
        nextServiceDue: now.add(const Duration(days: 165)),
        createdAt: now.subtract(const Duration(days: 75)),
      ),
      VehicleModel(
        id: 'veh_vishnu_4',
        garageId: 'garage_demo_1',
        customerId: customerId,
        make: 'Royal Enfield',
        model: 'Continental GT 650',
        year: 2024,
        licensePlate: 'KL 07 BW 6500',
        vehicleType: 'motorcycle',
        engineCc: 648,
        vin: 'ME3U3S5F0L1029481',
        currentOdometer: 4200,
        fuelType: 'Petrol',
        color: 'Apex Grey',
        lastServiceDate: now.subtract(const Duration(days: 25)),
        nextServiceDue: now.add(const Duration(days: 155)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  Future<List<VehicleModel>> getVehicles({
    String? garageId,
    String? customerId,
    String? userEmail,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
    final effectiveCustomerId = (customerId != null && customerId.isNotEmpty)
        ? customerId
        : (userEmail != null && userEmail.isNotEmpty ? userEmail : null);
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer =
        effectiveCustomerId != null && effectiveCustomerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    String? currentEmail;
    try {
      if (FirebaseConfig.isInitialized) {
        currentEmail = FirebaseAuth.instance.currentUser?.email;
      }
    } catch (_) {}
    final effectiveEmail = (userEmail ?? currentEmail ?? '').toLowerCase();
    final isVishnu =
        effectiveEmail == 'vishnushaji431@gmail.com' ||
        (hasCustomer &&
            (effectiveCustomerId.toLowerCase() == 'vishnushaji431@gmail.com' ||
                effectiveCustomerId.toLowerCase().contains('vishnu')));

    if (FirebaseConfig.isInitialized &&
        FirebaseConfig.isFirestoreDatabaseReady &&
        hasCustomer) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(effectiveCustomerId)
            .collection('vehicles')
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 3));

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((d) => VehicleModel.fromFirestore(d.data(), d.id))
              .toList();
        }

        final groupSnap = await FirebaseFirestore.instance
            .collectionGroup('vehicles')
            .where('customerId', isEqualTo: effectiveCustomerId)
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 3));

        if (groupSnap.docs.isNotEmpty) {
          return groupSnap.docs
              .map((d) => VehicleModel.fromFirestore(d.data(), d.id))
              .toList();
        }

        if (isVishnu) {
          final seeded = getVishnuDummyVehicles(
            customerId: effectiveCustomerId,
          );
          for (final veh in seeded) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(effectiveCustomerId)
                  .collection('vehicles')
                  .doc(veh.id)
                  .set(veh.toFirestore(), SetOptions(merge: true))
                  .timeout(const Duration(seconds: 2));
            } catch (_) {}
          }
          return seeded;
        }
      } on FirebaseException catch (e) {
        if (e.code == 'not-found' ||
            (e.message?.contains('database (default) does not exist') ==
                true)) {
          FirebaseConfig.markFirestoreUnavailable();
        }
      } catch (_) {}
    }

    if (isVishnu) {
      final seeded = getVishnuDummyVehicles(
        customerId: effectiveCustomerId ?? 'vishnushaji431@gmail.com',
      );
      for (final s in seeded) {
        if (!_vehicles.any((v) => v.id == s.id)) {
          _vehicles.add(s);
        }
      }
    }

    var query = _vehicles.where((v) {
      if (hasGarage && v.garageId != garageId) return false;
      if (hasCustomer) {
        if (isVishnu) {
          if (v.id.startsWith('veh_vishnu_') ||
              v.customerId == effectiveCustomerId ||
              v.customerId == 'vishnushaji431@gmail.com') {
            return true;
          }
        }
        if (v.customerId != effectiveCustomerId &&
            v.customerId != 'cust_demo_1') {
          return false;
        }
      }
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
    final id = vehicle.id.isNotEmpty ? vehicle.id : const Uuid().v4();
    final newVeh = vehicle.copyWith(
      id: id,
      createdAt: vehicle.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized &&
        FirebaseConfig.isFirestoreDatabaseReady) {
      try {
        if (newVeh.garageId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('garages')
              .doc(newVeh.garageId)
              .collection('vehicles')
              .doc(newVeh.id)
              .set(newVeh.toFirestore(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }
        if (newVeh.customerId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(newVeh.customerId)
              .collection('vehicles')
              .doc(newVeh.id)
              .set(newVeh.toFirestore(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }
      } on FirebaseException catch (e) {
        if (e.code == 'not-found' ||
            (e.message?.contains('database (default) does not exist') ==
                true)) {
          FirebaseConfig.markFirestoreUnavailable();
        }
      } catch (_) {}
    }

    _vehicles.insert(0, newVeh);
    return newVeh;
  }

  Future<List<EstimateModel>> getEstimates({
    String? garageId,
    String? customerId,
    int page = 0,
    int limit = 20,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('estimates');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('estimates')
              .where('customerId', isEqualTo: customerId);
        }

        final snapshot = await query
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 3));

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((d) => EstimateModel.fromFirestore(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }

    var query = _estimates.where((e) {
      if (hasGarage && e.garageId != garageId) return false;
      if (hasCustomer && e.customerId != customerId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<EstimateModel> createEstimate(EstimateModel estimate) async {
    final newEst = estimate.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _estimates.insert(0, newEst);
    return newEst;
  }

  Future<bool> approveEstimate(String estimateId) async {
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
          imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
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
          imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
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
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('invoices');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('invoices')
              .where('customerId', isEqualTo: customerId);
        }

        final snapshot = await query
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 3));

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((d) => InvoiceModel.fromFirestore(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }

    var query = _invoices.where((inv) {
      if (hasGarage && inv.garageId != garageId) return false;
      if (hasCustomer && inv.customerId != customerId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<InvoiceModel> createInvoiceFromEstimate(EstimateModel estimate) async {
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
        imageUrl: 'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80',
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
    final invIndex = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (invIndex < 0) {
      throw Exception('Invoice not found');
    }

    final currentInv = _invoices[invIndex];
    final updatedDiscount = currentInv.discountAmount + discountAdjustment;
    final updatedTotal = (currentInv.totalAmount - discountAdjustment).clamp(
      0.0,
      double.infinity,
    );
    final updatedPaid = currentInv.paidAmount + amount;
    final updatedBalance = (updatedTotal - updatedPaid).clamp(
      0.0,
      double.infinity,
    );
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
        imageUrl: 'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80',
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
    String? customerId,
    int page = 0,
    int limit = 20,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasInvoice = invoiceId != null && invoiceId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasInvoice && !hasCustomer) {
      return [];
    }

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('payments');
          if (hasInvoice) {
            query = query.where('invoiceId', isEqualTo: invoiceId);
          }
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else if (hasCustomer) {
          query = FirebaseFirestore.instance
              .collectionGroup('payments')
              .where('customerId', isEqualTo: customerId);
          if (hasInvoice) {
            query = query.where('invoiceId', isEqualTo: invoiceId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('payments')
              .where('invoiceId', isEqualTo: invoiceId);
        }

        final snapshot = await query
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 3));

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((d) => PaymentModel.fromFirestore(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }

    var query = _payments.where((p) {
      if (hasGarage && p.garageId != garageId) return false;
      if (hasInvoice && p.invoiceId != invoiceId) return false;
      if (hasCustomer && p.customerId != customerId) return false;
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
    String? userEmail,
  }) async {
    final effectiveCustomerId = (customerId != null && customerId.isNotEmpty)
        ? customerId
        : (userEmail != null && userEmail.isNotEmpty ? userEmail : null);
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer =
        effectiveCustomerId != null && effectiveCustomerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    String? currentEmail;
    try {
      if (FirebaseConfig.isInitialized) {
        currentEmail = FirebaseAuth.instance.currentUser?.email;
      }
    } catch (_) {}
    final effectiveEmail = (userEmail ?? currentEmail ?? '').toLowerCase();
    final isVishnu =
        effectiveEmail == 'vishnushaji431@gmail.com' ||
        (hasCustomer &&
            (effectiveCustomerId.toLowerCase() == 'vishnushaji431@gmail.com' ||
                effectiveCustomerId.toLowerCase().contains('vishnu')));

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('reminders');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: effectiveCustomerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('reminders')
              .where('customerId', isEqualTo: effectiveCustomerId);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 3));

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((d) => ServiceReminderModel.fromFirestore(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }

    return _reminders.where((r) {
      if (hasGarage && r.garageId != garageId) return false;
      if (hasCustomer) {
        if (isVishnu) {
          if (r.customerId == 'vishnushaji431@gmail.com' ||
              r.id.startsWith('rem_vishnu_') ||
              r.customerId == effectiveCustomerId) {
            return true;
          }
        }
        if (r.customerId != effectiveCustomerId &&
            r.customerId != 'cust_demo_1') {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<ServiceReminderModel> createReminder(
    ServiceReminderModel reminder,
  ) async {
    final id = reminder.id.isNotEmpty ? reminder.id : const Uuid().v4();
    final newRem = reminder.copyWith(
      id: id,
      createdAt: reminder.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized) {
      try {
        if (newRem.garageId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('garages')
              .doc(newRem.garageId)
              .collection('reminders')
              .doc(newRem.id)
              .set(newRem.toFirestore(), SetOptions(merge: true));
        }
      } catch (_) {}
    }

    _reminders.insert(0, newRem);
    return newRem;
  }

  Future<List<NotificationModel>> getNotifications({
    required String recipientUid,
    int page = 0,
    int limit = 20,
  }) async {
    if (FirebaseConfig.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 3));

        return snapshot.docs
            .map((d) => NotificationModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (_) {}
    }

    final list = _notifications
        .where((n) => n.recipientUid == recipientUid)
        .toList();
    final start = page * limit;
    if (start >= list.length) return [];
    final end = (start + limit) > list.length ? list.length : (start + limit);
    return list.sublist(start, end);
  }

  Future<PaginatedResult<NotificationModel>> getNotificationsPaginated({
    required String recipientUid,
    Object? lastDocument,
    int limit = 20,
  }) async {
    if (FirebaseConfig.isInitialized && recipientUid.isNotEmpty) {
      try {
        Query query = FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(limit);

        if (lastDocument is DocumentSnapshot) {
          query = query.startAfterDocument(lastDocument);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 3));
        final items = snapshot.docs
            .map(
              (d) => NotificationModel.fromFirestore(
                d.data() as Map<String, dynamic>,
                d.id,
              ),
            )
            .toList();

        final hasMore = snapshot.docs.length >= limit;
        final nextLastDoc = snapshot.docs.isNotEmpty
            ? snapshot.docs.last
            : null;

        return PaginatedResult(
          items: items,
          hasMore: hasMore,
          lastDocument: nextLastDoc,
        );
      } catch (_) {}
    }

    final local = _notifications
        .where((n) => n.recipientUid == recipientUid)
        .toList();
    return PaginatedResult(
      items: local.take(limit).toList(),
      hasMore: local.length > limit,
      lastDocument: null,
    );
  }

  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    final id = notification.id.isNotEmpty ? notification.id : const Uuid().v4();
    final newNotif = notification.copyWith(id: id);

    if (FirebaseConfig.isInitialized &&
        FirebaseConfig.isFirestoreDatabaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newNotif.recipientUid)
            .collection('notifications')
            .doc(newNotif.id)
            .set(newNotif.toFirestore(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    _notifications.insert(0, newNotif);
    return newNotif;
  }

  Future<void> markNotificationAsRead(
    String notificationId, {
    String? recipientUid,
  }) async {
    if (FirebaseConfig.isInitialized &&
        recipientUid != null &&
        recipientUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
      } catch (_) {}
    }

    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  Future<void> deleteNotification({
    required String notificationId,
    required String recipientUid,
  }) async {
    if (FirebaseConfig.isInitialized && recipientUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .doc(notificationId)
            .delete();
      } catch (_) {}
    }

    _notifications.removeWhere((n) => n.id == notificationId);
  }

  Future<void> deleteNotifications({
    required List<String> notificationIds,
    required String recipientUid,
  }) async {
    if (FirebaseConfig.isInitialized &&
        recipientUid.isNotEmpty &&
        notificationIds.isNotEmpty) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final col = FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications');
        for (final id in notificationIds) {
          batch.delete(col.doc(id));
        }
        await batch.commit();
      } catch (_) {}
    }

    _notifications.removeWhere((n) => notificationIds.contains(n.id));
  }

  Future<List<AppointmentModel>> getAppointments({
    String? garageId,
    String? customerId,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('appointments');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('appointments')
              .where('customerId', isEqualTo: customerId);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 3));

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((d) => AppointmentModel.fromFirestore(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }

    return _appointments.where((a) {
      if (hasGarage && a.garageId != garageId) return false;
      if (hasCustomer && a.customerId != customerId) return false;
      return true;
    }).toList();
  }

  Future<AppointmentModel> createAppointment(
    AppointmentModel appointment,
  ) async {
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
        imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
        deepLink: '/merchant/jobs',
        garageId: appointment.garageId,
        eventId: 'app_${newApp.id}_submitted',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    return newApp;
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx >= 0) {
      _appointments[idx] = _appointments[idx].copyWith(status: newStatus);
    }
  }

  Future<List<VehicleInspectionModel>> getInspections(String jobId) async {
    return _inspections.where((i) => i.jobId == jobId).toList();
  }

  Future<void> saveInspection(VehicleInspectionModel inspection) async {
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
          imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
          deepLink: '/customer/jobs/${job.id}',
          garageId: job.garageId,
          eventId: 'insp_${inspection.id}_saved',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  List<GarageServiceModel> _generateDefaultPackages(String garageId) {
    final now = DateTime.now();
    return [
      GarageServiceModel(
        id: 'pkg_periodic_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'Standard Periodic Maintenance Package',
        description: 'Engine oil replacement, OEM oil filter, 25-point electronic & mechanical inspection, spark plug service, fluid top-ups and battery check.',
        category: 'Periodic Service',
        pricingMethod: 'category',
        pricingType: 'vehicle_specific',
        fixedPrice: 1499.0,
        estimatedDuration: '2-3 hrs',
        terms: 'Includes complimentary 25-point vehicle health report.',
        supportedVehicleTypes: const [
          'car',
          'motorcycle',
          'scooter',
          'electric_scooter',
          'electric_motorcycle',
        ],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'car',
            pricingType: 'fixed',
            fixedPrice: 2499.0,
          ),
          VehiclePricingTier(
            vehicleType: 'motorcycle',
            pricingType: 'fixed',
            fixedPrice: 799.0,
          ),
          VehiclePricingTier(
            vehicleType: 'scooter',
            pricingType: 'fixed',
            fixedPrice: 599.0,
          ),
          VehiclePricingTier(
            vehicleType: 'electric_scooter',
            pricingType: 'fixed',
            fixedPrice: 499.0,
          ),
          VehiclePricingTier(
            vehicleType: 'electric_motorcycle',
            pricingType: 'fixed',
            fixedPrice: 699.0,
          ),
        ],
        includedItems: const [
          'Engine oil replacement',
          'OEM oil filter replacement',
          '25-point electronic scan',
          'Fluid top-ups',
        ],
        excludedItems: const [
          'Major engine overhaul',
          'Body panel denting/painting',
        ],
        requiredParts: const ['Synthetic engine oil', 'OEM filter cartridge'],
        specialInstructions:
            'Please arrive 10 minutes prior to scheduled slot.',
        isActive: true,
        createdAt: now,
      ),
      GarageServiceModel(
        id: 'pkg_water_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'Foam Water Service & Deep Detailing',
        description: 'High-pressure underbody blast, active snow foam bath, interior carpet vacuum, dashboard UV polish, glass cleaning and tyre dressing.',
        category: 'Water Service & Wash',
        pricingMethod: 'category',
        pricingType: 'vehicle_specific',
        fixedPrice: 499.0,
        estimatedDuration: '1 hr',
        terms: 'Complete interior vacuum and high-pressure underchassis wash included.',
        supportedVehicleTypes: const [
          'car',
          'motorcycle',
          'scooter',
          'electric_scooter',
        ],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'car',
            pricingType: 'fixed',
            fixedPrice: 499.0,
          ),
          VehiclePricingTier(
            vehicleType: 'motorcycle',
            pricingType: 'fixed',
            fixedPrice: 250.0,
          ),
          VehiclePricingTier(
            vehicleType: 'scooter',
            pricingType: 'fixed',
            fixedPrice: 200.0,
          ),
          VehiclePricingTier(
            vehicleType: 'electric_scooter',
            pricingType: 'fixed',
            fixedPrice: 200.0,
          ),
        ],
        includedItems: const [
          'High-pressure underchassis blast',
          'Snow foam exterior wash',
          'Interior vacuuming',
        ],
        isActive: true,
        createdAt: now,
      ),
      GarageServiceModel(
        id: 'pkg_brake_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'Precision Brake System Overhaul',
        description: 'Front & rear disc rotor precision lathe resurfacing, caliper slide pin greasing, DOT4 fluid flush and anti-squeal pad fitting.',
        category: 'Mechanical',
        pricingMethod: 'category',
        pricingType: 'vehicle_specific',
        fixedPrice: 850.0,
        estimatedDuration: '2 hrs',
        supportedVehicleTypes: const ['car', 'motorcycle', 'scooter'],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'car',
            pricingType: 'range',
            minPrice: 1500.0,
            maxPrice: 3000.0,
          ),
          VehiclePricingTier(
            vehicleType: 'motorcycle',
            pricingType: 'range',
            minPrice: 350.0,
            maxPrice: 600.0,
          ),
          VehiclePricingTier(
            vehicleType: 'scooter',
            pricingType: 'range',
            minPrice: 250.0,
            maxPrice: 450.0,
          ),
        ],
        includedItems: const [
          'Brake pad inspection & fitting',
          'Caliper pin greasing',
          'Brake fluid flush',
        ],
        isActive: true,
        createdAt: now,
      ),
      GarageServiceModel(
        id: 'pkg_scooter_oil_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'Scooter Oil Change & Inspection',
        description: 'Specialized 4-stroke scooter engine oil change, air filter cleaning, gear oil inspection, and brake responsiveness tuning.',
        category: 'Periodic Service',
        pricingMethod: 'range',
        pricingType: 'range',
        minPrice: 250.0,
        maxPrice: 450.0,
        estimatedDuration: '30 mins',
        supportedVehicleTypes: const ['scooter'],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'scooter',
            pricingType: 'range',
            minPrice: 250.0,
            maxPrice: 450.0,
          ),
        ],
        includedItems: const [
          'Engine oil replacement',
          'Air filter clean',
          'Tyre pressure check',
        ],
        isActive: true,
        createdAt: now,
      ),
      GarageServiceModel(
        id: 'pkg_bike_oil_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'Motorcycle Oil Change & Chain Lube',
        description: 'Full synthetic motorcycle engine oil replacement, drive chain cleaning, tension adjustment, and high-adhesion chain lube application.',
        category: 'Periodic Service',
        pricingMethod: 'range',
        pricingType: 'range',
        minPrice: 350.0,
        maxPrice: 600.0,
        estimatedDuration: '40 mins',
        supportedVehicleTypes: const ['motorcycle'],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'motorcycle',
            pricingType: 'range',
            minPrice: 350.0,
            maxPrice: 600.0,
          ),
        ],
        includedItems: const [
          'Engine oil replacement',
          'Chain degreasing & lubing',
          'Clutch cable adjustment',
        ],
        isActive: true,
        createdAt: now,
      ),
      GarageServiceModel(
        id: 'pkg_diag_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'OBD-II Computerized Scan & Electrical Check',
        description: 'Full ECU computerized error scan, live sensor telemetry analysis, battery health analysis, and high-voltage circuit test.',
        category: 'Inspections & Diagnostics',
        pricingMethod: 'fixed',
        pricingType: 'fixed',
        fixedPrice: 699.0,
        estimatedDuration: '45 mins',
        supportedVehicleTypes: const [
          'car',
          'motorcycle',
          'electric_scooter',
          'electric_motorcycle',
        ],
        isActive: true,
        createdAt: now,
      ),
      GarageServiceModel(
        id: 'pkg_express_wash_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'Express Bike Wash',
        description: 'Exterior body high-pressure rinse, active foam wash, and microfiber towel dry.',
        category: 'Water Service & Wash',
        pricingMethod: 'fixed',
        pricingType: 'fixed',
        fixedPrice: 150.0,
        estimatedDuration: '20 mins',
        supportedVehicleTypes: const ['motorcycle', 'scooter'],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'motorcycle',
            pricingType: 'fixed',
            fixedPrice: 150.0,
          ),
          VehiclePricingTier(
            vehicleType: 'scooter',
            pricingType: 'fixed',
            fixedPrice: 150.0,
          ),
        ],
        isActive: true,
        createdAt: now,
      ),
      GarageServiceModel(
        id: 'pkg_car_wash_$garageId',
        garageId: garageId,
        merchantId: 'merchant_demo_1',
        name: 'Car Wash & Vacuum',
        description: 'Exterior foam wash, wheel arches jet wash, and interior footmat cleaning.',
        category: 'Water Service & Wash',
        pricingMethod: 'fixed',
        pricingType: 'fixed',
        fixedPrice: 350.0,
        estimatedDuration: '45 mins',
        supportedVehicleTypes: const ['car'],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'car',
            pricingType: 'fixed',
            fixedPrice: 350.0,
          ),
        ],
        isActive: true,
        createdAt: now,
      ),
    ];
  }

  Future<List<GarageServiceModel>> getGarageServices(String garageId) async {
    if (FirebaseConfig.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .get()
            .timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => GarageServiceModel.fromFirestore(d.data(), d.id))
              .toList();
        }

        final catSnap = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceCatalog')
            .get()
            .timeout(const Duration(seconds: 4));
        if (catSnap.docs.isNotEmpty) {
          return catSnap.docs
              .map((d) => GarageServiceModel.fromFirestore(d.data(), d.id))
              .toList();
        }

        final defaults = _generateDefaultPackages(garageId);
        final batch = FirebaseFirestore.instance.batch();
        for (final s in defaults) {
          final doc = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('services')
              .doc(s.id);
          batch.set(doc, s.toFirestore());
        }
        await batch.commit();
        return defaults;
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_SERVICES_ERROR: $e');
        return [];
      }
    }
    final existing = _services.where((s) => s.garageId == garageId).toList();
    if (existing.isNotEmpty) {
      return existing;
    }
    final generated = _generateDefaultPackages(garageId);
    _services.addAll(generated);
    return generated;
  }

  Future<void> saveGarageService(
    String garageId,
    GarageServiceModel service,
  ) async {
    final idx = _services.indexWhere((s) => s.id == service.id);
    if (idx >= 0) {
      _services[idx] = service;
    } else {
      _services.add(service);
    }
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .doc(service.id)
            .set(service.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_SAVE_SERVICE_ERROR: $e');
      }
    }
  }

  Future<void> toggleServiceActive(
    String garageId,
    String serviceId,
    bool isActive,
  ) async {
    final idx = _services.indexWhere((s) => s.id == serviceId);
    if (idx >= 0) {
      _services[idx] = _services[idx].copyWith(isActive: isActive);
    }
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .doc(serviceId)
            .update({'isActive': isActive});
      } catch (e) {
        debugPrint('GARAGE_REPO_TOGGLE_SERVICE_ERROR: $e');
      }
    }
  }

  Future<void> deleteGarageService(String garageId, String serviceId) async {
    _services.removeWhere((s) => s.id == serviceId);
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .doc(serviceId)
            .delete();
      } catch (e) {
        debugPrint('GARAGE_REPO_DELETE_SERVICE_ERROR: $e');
      }
    }
  }

  Future<List<GarageSearchResultModel>> searchGaragesAndServices({
    String? query,
    String? category,
    String? vehicleType,
    double? maxDistanceKm,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'nearest',
    double userLat = 9.9674,
    double userLon = 76.2891,
    int limit = 30,
  }) async {
    final garages = await getNearbyGarages(
      latitude: userLat,
      longitude: userLon,
      radiusKm: maxDistanceKm ?? 50.0,
      limit: 50,
    );

    final results = <GarageSearchResultModel>[];
    final q = query?.trim().toLowerCase() ?? '';
    final cat = (category != null && category.toLowerCase() != 'all')
        ? category.toLowerCase()
        : null;
    final veh = (vehicleType != null && vehicleType.toLowerCase() != 'all')
        ? vehicleType.toLowerCase()
        : null;

    for (final garage in garages) {
      final distance = GeohashHelper.calculateDistanceKm(
        lat1: userLat,
        lon1: userLon,
        lat2: garage.latitude,
        lon2: garage.longitude,
      );

      if (maxDistanceKm != null && distance > maxDistanceKm) {
        continue;
      }

      final services = await getGarageServices(garage.id);
      final activeServices = services.where((s) => s.isActive).toList();

      final garageTextMatch =
          q.isEmpty ||
          garage.name.toLowerCase().contains(q) ||
          garage.city.toLowerCase().contains(q) ||
          garage.address.toLowerCase().contains(q);

      final matchingServices = activeServices.where((s) {
        if (cat != null && s.category.toLowerCase() != cat) {
          return false;
        }

        if (veh != null && !s.supportsVehicle(veh)) {
          return false;
        }

        final evaluated = SmartPricingEngine.evaluate(
          service: s,
          vehicleType: veh,
          currencyCode: garage.currencyCode,
        );

        if (minPrice != null &&
            (evaluated.amount == null || evaluated.amount! < minPrice)) {
          return false;
        }
        if (maxPrice != null &&
            (evaluated.amount == null || evaluated.amount! > maxPrice)) {
          return false;
        }

        if (q.isNotEmpty && !garageTextMatch) {
          final sName = s.name.toLowerCase();
          final sDesc = s.description.toLowerCase();
          final sCat = s.category.toLowerCase();
          if (!sName.contains(q) && !sDesc.contains(q) && !sCat.contains(q)) {
            return false;
          }
        }

        return true;
      }).toList();

      if (q.isNotEmpty && !garageTextMatch && matchingServices.isEmpty) {
        continue;
      }

      if (cat != null && matchingServices.isEmpty) {
        continue;
      }

      if (veh != null && matchingServices.isEmpty) {
        continue;
      }

      if ((minPrice != null || maxPrice != null) && matchingServices.isEmpty) {
        continue;
      }

      GarageServiceModel? topService;
      EvaluatedPrice? topPrice;

      if (matchingServices.isNotEmpty) {
        topService = matchingServices.first;
        topPrice = SmartPricingEngine.evaluate(
          service: topService,
          vehicleType: veh,
          currencyCode: garage.currencyCode,
        );
      } else if (activeServices.isNotEmpty) {
        topService = activeServices.first;
        topPrice = SmartPricingEngine.evaluate(
          service: topService,
          vehicleType: veh,
          currencyCode: garage.currencyCode,
        );
      }

      results.add(
        GarageSearchResultModel(
          garage: garage,
          distanceKm: distance,
          matchedService: topService,
          evaluatedPrice: topPrice,
        ),
      );
    }

    if (sortBy == 'nearest') {
      results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (sortBy == 'price_asc') {
      results.sort((a, b) {
        final pa = a.evaluatedPrice?.amount ?? double.infinity;
        final pb = b.evaluatedPrice?.amount ?? double.infinity;
        return pa.compareTo(pb);
      });
    } else if (sortBy == 'price_desc') {
      results.sort((a, b) {
        final pa = a.evaluatedPrice?.amount ?? -1.0;
        final pb = b.evaluatedPrice?.amount ?? -1.0;
        return pb.compareTo(pa);
      });
    } else if (sortBy == 'rating') {
      results.sort((a, b) => b.garage.rating.compareTo(a.garage.rating));
    }

    return results.take(limit).toList();
  }

  Future<void> submitGarageReview(ReviewModel review) async {
    _reviews.insert(0, review);
    final garageIdx = _garages.indexWhere((g) => g.id == review.garageId);
    if (garageIdx >= 0) {
      final g = _garages[garageIdx];
      final newCount = g.reviewCount + 1;
      final newRating = ((g.rating * g.reviewCount) + review.rating) / newCount;
      _garages[garageIdx] = g.copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: newCount,
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final garageRef = FirebaseFirestore.instance
            .collection('garages')
            .doc(review.garageId);
        final reviewRef = garageRef.collection('reviews').doc(review.id);

        await FirebaseFirestore.instance.runTransaction((tx) async {
          final gSnap = await tx.get(garageRef);
          if (gSnap.exists) {
            final data = gSnap.data()!;
            final currentCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
            final currentRating = (data['rating'] as num?)?.toDouble() ?? 4.8;
            final newCount = currentCount + 1;
            final newRating =
                ((currentRating * currentCount) + review.rating) / newCount;

            tx.set(reviewRef, review.toFirestore());
            tx.update(garageRef, {
              'rating': double.parse(newRating.toStringAsFixed(1)),
              'reviewCount': newCount,
            });
          } else {
            tx.set(reviewRef, review.toFirestore());
          }
        });
      } catch (_) {}
    }
  }

  Future<PaginatedResult<ReviewModel>> getGarageReviewsPaginated(
    String garageId, {
    int limit = 10,
    Object? lastDocument,
  }) async {
    if (FirebaseConfig.isInitialized) {
      try {
        var query = FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .limit(limit);

        if (lastDocument is DocumentSnapshot) {
          query = query.startAfterDocument(lastDocument);
        }

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final items = snap.docs
              .map((d) => ReviewModel.fromFirestore(d.data(), d.id))
              .toList();
          return PaginatedResult(
            items: items,
            lastDocument: snap.docs.last,
            hasMore: snap.docs.length >= limit,
          );
        }
      } catch (_) {}
    }

    final local = _reviews.where((r) => r.garageId == garageId).toList();
    return PaginatedResult(items: local, hasMore: false);
  }

  Future<ConversationModel> getOrCreateConversation({
    required String customerId,
    required String customerName,
    required String garageId,
    required String garageName,
    String? customerPhone,
    String? garagePhone,
    String? serviceJobId,
    String? serviceJobTitle,
  }) async {
    final existingLocal = _conversations
        .where((c) => c.customerId == customerId && c.garageId == garageId)
        .firstOrNull;
    if (existingLocal != null) {
      if ((customerPhone != null && existingLocal.customerPhone == null) ||
          (garagePhone != null && existingLocal.garagePhone == null)) {
        final updated = existingLocal.copyWith(
          customerPhone: customerPhone ?? existingLocal.customerPhone,
          garagePhone: garagePhone ?? existingLocal.garagePhone,
        );
        final idx = _conversations.indexOf(existingLocal);
        _conversations[idx] = updated;
        return updated;
      }
      return existingLocal;
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('conversations')
            .where('customerId', isEqualTo: customerId)
            .where('garageId', isEqualTo: garageId)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final d = query.docs.first;
          final existing = ConversationModel.fromFirestore(d.data(), d.id);
          if ((customerPhone != null && existing.customerPhone == null) ||
              (garagePhone != null && existing.garagePhone == null)) {
            final updated = existing.copyWith(
              customerPhone: customerPhone ?? existing.customerPhone,
              garagePhone: garagePhone ?? existing.garagePhone,
            );
            await d.reference.set(
              updated.toFirestore(),
              SetOptions(merge: true),
            );
            return updated;
          }
          return existing;
        }

        final docRef = FirebaseFirestore.instance
            .collection('conversations')
            .doc();
        final newConv = ConversationModel(
          id: docRef.id,
          customerId: customerId,
          customerName: customerName,
          garageId: garageId,
          garageName: garageName,
          customerPhone: customerPhone,
          garagePhone: garagePhone,
          serviceJobId: serviceJobId,
          serviceJobTitle: serviceJobTitle,
          createdAt: DateTime.now(),
        );
        await docRef.set(newConv.toFirestore());
        _conversations.insert(0, newConv);
        return newConv;
      } catch (_) {}
    }

    final newConv = ConversationModel(
      id: const Uuid().v4(),
      customerId: customerId,
      customerName: customerName,
      garageId: garageId,
      garageName: garageName,
      customerPhone: customerPhone,
      garagePhone: garagePhone,
      serviceJobId: serviceJobId,
      serviceJobTitle: serviceJobTitle,
      createdAt: DateTime.now(),
    );
    _conversations.insert(0, newConv);
    return newConv;
  }

  Stream<List<ConversationModel>> streamUserConversations(
    String userId, {
    required bool isMerchant,
    int limit = 25,
  }) {
    if (userId.isEmpty) {
      return Stream.value(const []);
    }
    if (FirebaseConfig.isInitialized) {
      final field = isMerchant ? 'garageId' : 'customerId';
      return FirebaseFirestore.instance
          .collection('conversations')
          .where(field, isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => ConversationModel.fromFirestore(d.data(), d.id))
                .toList(),
          );
    }
    final fieldFilter = isMerchant
        ? (ConversationModel c) => c.garageId == userId
        : (ConversationModel c) => c.customerId == userId;
    return Stream.value(_conversations.where(fieldFilter).toList());
  }

  Stream<List<ChatMessageModel>> streamConversationMessages(
    String conversationId, {
    int limit = 40,
  }) {
    if (conversationId.isEmpty) {
      return Stream.value(const []);
    }
    if (FirebaseConfig.isInitialized) {
      return FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => ChatMessageModel.fromFirestore(d.data(), d.id))
                .toList(),
          );
    }
    return Stream.value(
      _messages.where((m) => m.conversationId == conversationId).toList()..sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      ),
    );
  }

  Future<void> sendChatMessage({
    required String conversationId,
    required String senderId,
    required String senderRole,
    required String text,
    String? attachmentUrl,
  }) async {
    final now = DateTime.now();
    final messageId = const Uuid().v4();
    final msg = ChatMessageModel(
      id: messageId,
      conversationId: conversationId,
      senderId: senderId,
      senderRole: senderRole,
      text: text,
      attachmentUrl: attachmentUrl,
      createdAt: now,
      isRead: false,
    );
    _messages.insert(0, msg);

    final convIdx = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIdx >= 0) {
      final c = _conversations[convIdx];
      _conversations[convIdx] = c.copyWith(
        lastMessage: text,
        lastMessageTime: now,
        lastSenderId: senderId,
        unreadCountCustomer: senderRole == 'merchant'
            ? c.unreadCountCustomer + 1
            : c.unreadCountCustomer,
        unreadCountMerchant: senderRole == 'customer'
            ? c.unreadCountMerchant + 1
            : c.unreadCountMerchant,
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final convRef = FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId);
        final msgRef = convRef.collection('messages').doc(messageId);

        final batch = FirebaseFirestore.instance.batch();
        batch.set(msgRef, msg.toFirestore());

        final isCustomer = senderRole == 'customer';
        batch.update(convRef, {
          'lastMessage': text,
          'lastMessageTime': now.toIso8601String(),
          'lastSenderId': senderId,
          if (isCustomer)
            'unreadCountMerchant': FieldValue.increment(1)
          else
            'unreadCountCustomer': FieldValue.increment(1),
        });

        await batch.commit();

        final convSnap = await convRef.get();
        if (convSnap.exists && convSnap.data() != null) {
          final data = convSnap.data()!;
          final recipientUid = isCustomer
              ? (data['garageId'] as String? ?? '')
              : (data['customerId'] as String? ?? '');
          final senderTitle = isCustomer
              ? (data['customerName'] as String? ?? 'Customer')
              : (data['garageName'] as String? ?? 'Garage');
          if (recipientUid.isNotEmpty) {
            final notifId =
                'chat_${conversationId}_${now.millisecondsSinceEpoch}';
            await FirebaseFirestore.instance
                .collection('users')
                .doc(recipientUid)
                .collection('notifications')
                .doc(notifId)
                .set({
                  'recipientUid': recipientUid,
                  'title': 'New message from $senderTitle',
                  'body': text,
                  'type': 'chat',
                  'referenceId': conversationId,
                  'deepLink': '/chat/$conversationId',
                  'eventId': notifId,
                  'isRead': false,
                  'createdAt': now.toIso8601String(),
                }, SetOptions(merge: true));
          }
        }
      } catch (_) {}
    }
  }

  Future<void> markConversationRead(
    String conversationId, {
    required bool isMerchant,
  }) async {
    final convIdx = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIdx >= 0) {
      final c = _conversations[convIdx];
      _conversations[convIdx] = isMerchant
          ? c.copyWith(unreadCountMerchant: 0)
          : c.copyWith(unreadCountCustomer: 0);
    }

    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId)
            .update({
              isMerchant ? 'unreadCountMerchant' : 'unreadCountCustomer': 0,
            });
      } catch (_) {}
    }
  }

  void clearCache() {
    _notifications.clear();
    _conversations.clear();
    _messages.clear();
  }
}

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepository();
});

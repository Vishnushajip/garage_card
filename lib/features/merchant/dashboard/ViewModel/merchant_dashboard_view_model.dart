import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/pagination/paginated_result.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/appointment_model.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/mechanic_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/dashboard_analytics_models.dart';
import '../Model/merchant_dashboard_state.dart';

class MerchantDashboardViewModel extends Notifier<MerchantDashboardState> {
  List<ServiceJobModel> _cachedJobs = const [];
  List<CustomerModel> _cachedCustomers = const [];
  List<EstimateModel> _cachedEstimates = const [];
  List<InvoiceModel> _cachedInvoices = const [];
  List<AppointmentModel> _cachedAppointments = const [];
  List<MechanicModel> _cachedMechanics = const [];

  @override
  MerchantDashboardState build() {
    Future.microtask(_loadDashboardData);
    return const MerchantDashboardState(isLoading: true);
  }

  Future<void> _loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = ref.read(authViewModelProvider).userProfile;
      final repo = ref.read(garageRepositoryProvider);

      GarageModel? garage;
      if (user?.garageId != null && user!.garageId!.isNotEmpty) {
        garage = await repo.getGarageDetails(user.garageId!);
      } else if (user != null) {
        garage = await repo.getGarageByOwnerUid(user.uid);
      }

      if (garage == null) {
        state = state.copyWith(
          isLoading: false,
          garage: null,
          recentJobs: const [],
          recentCustomers: const [],
          pendingEstimates: const [],
          unpaidInvoices: const [],
          appointments: const [],
        );
        return;
      }

      final garageId = garage.id;

      final results = await Future.wait([
        repo.getServiceJobs(garageId: garageId, limit: 200),
        repo.getCustomers(garageId: garageId, limit: 200),
        repo.getEstimates(garageId: garageId, limit: 100),
        repo.getInvoices(garageId: garageId, limit: 200),
        repo.getAppointments(garageId: garageId),
        repo.getMechanicsPaginated(garageId: garageId, limit: 100),
      ]);

      _cachedJobs = results[0] as List<ServiceJobModel>;
      _cachedCustomers = results[1] as List<CustomerModel>;
      _cachedEstimates = results[2] as List<EstimateModel>;
      _cachedInvoices = results[3] as List<InvoiceModel>;
      _cachedAppointments = results[4] as List<AppointmentModel>;
      final mechanicsPaginated = results[5] as PaginatedResult<MechanicModel>;
      _cachedMechanics = mechanicsPaginated.items;

      _recalculateDashboard(garage: garage);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setTimeRange(
    DashboardTimeRange range, [
    DateTime? customStart,
    DateTime? customEnd,
  ]) {
    state = state.copyWith(
      selectedTimeRange: range,
      customStartDate: customStart,
      customEndDate: customEnd,
    );
    if (state.garage != null) {
      _recalculateDashboard(garage: state.garage!);
    }
  }

  void setJobFilter(String filter) {
    state = state.copyWith(selectedJobFilter: filter);
  }

  Future<void> refresh() async {
    await _loadDashboardData();
  }

  void _recalculateDashboard({required GarageModel garage}) {
    final now = DateTime.now();
    final timeBounds = _resolveTimeBounds(
      state.selectedTimeRange,
      now,
      state.customStartDate,
      state.customEndDate,
    );

    final start = timeBounds.$1;
    final end = timeBounds.$2;
    final prevStart = timeBounds.$3;
    final prevEnd = timeBounds.$4;

    final financialMetrics = _computeFinancialMetrics(
      invoices: _cachedInvoices,
      start: start,
      end: end,
      prevStart: prevStart,
      prevEnd: prevEnd,
      now: now,
    );

    final operationalMetrics = _computeOperationalMetrics(
      jobs: _cachedJobs,
      estimates: _cachedEstimates,
      appointments: _cachedAppointments,
      start: start,
      end: end,
      prevStart: prevStart,
      prevEnd: prevEnd,
      now: now,
    );

    final mechanicMetrics = _computeMechanicMetrics(
      mechanics: _cachedMechanics,
      jobs: _cachedJobs,
      start: start,
      end: end,
    );

    final customerMetrics = _computeCustomerMetrics(
      customers: _cachedCustomers,
      jobs: _cachedJobs,
      invoices: _cachedInvoices,
      start: start,
      end: end,
    );

    final recentTransactions = _extractRecentTransactions(
      invoices: _cachedInvoices,
    );

    final smartAlerts = _generateSmartAlerts(
      jobs: _cachedJobs,
      invoices: _cachedInvoices,
      appointments: _cachedAppointments,
      mechanics: mechanicMetrics,
      now: now,
    );

    final activeJobs = _cachedJobs.where((j) => j.isActiveRepair).toList();
    final completedCount = _cachedJobs.where((j) => j.isCompletedRepair).length;
    final unpaidInvoices = _cachedInvoices.where((i) => !i.isPaid).toList();
    final totalUnpaid = unpaidInvoices.fold<double>(
      0.0,
      (sum, item) => sum + item.balanceDue,
    );

    state = state.copyWith(
      isLoading: false,
      garage: garage,
      financialMetrics: financialMetrics,
      operationalMetrics: operationalMetrics,
      mechanicMetrics: mechanicMetrics,
      customerMetrics: customerMetrics,
      recentTransactions: recentTransactions,
      smartAlerts: smartAlerts,
      totalActiveJobs: activeJobs.length,
      totalCompletedJobs: completedCount,
      totalClientsCount: _cachedCustomers.length,
      totalRevenue: financialMetrics.totalCollected,
      totalUnpaidAmount: totalUnpaid,
      jobsAwaitingInspection: operationalMetrics.jobsAwaitingInspection,
      estimatesAwaitingApproval: operationalMetrics.estimatesAwaitingApproval,
      jobsInProgress: operationalMetrics.jobsInProgress,
      vehiclesReady: operationalMetrics.jobsReadyForPickup,
      recentJobs: _cachedJobs.take(15).toList(),
      recentCustomers: _cachedCustomers.take(5).toList(),
      pendingEstimates: _cachedEstimates
          .where((e) => e.status == 'sent')
          .take(5)
          .toList(),
      unpaidInvoices: unpaidInvoices.take(5).toList(),
      appointments: _cachedAppointments.take(5).toList(),
    );
  }

  (DateTime, DateTime, DateTime, DateTime) _resolveTimeBounds(
    DashboardTimeRange range,
    DateTime now,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (range) {
      case DashboardTimeRange.today:
        final prevStart = todayStart.subtract(const Duration(days: 1));
        final prevEnd = DateTime(
          prevStart.year,
          prevStart.month,
          prevStart.day,
          23,
          59,
          59,
        );
        return (todayStart, todayEnd, prevStart, prevEnd);

      case DashboardTimeRange.last7Days:
        final start = todayStart.subtract(const Duration(days: 6));
        final prevEnd = start.subtract(const Duration(seconds: 1));
        final prevStart = start.subtract(const Duration(days: 7));
        return (start, todayEnd, prevStart, prevEnd);

      case DashboardTimeRange.last30Days:
        final start = todayStart.subtract(const Duration(days: 29));
        final prevEnd = start.subtract(const Duration(seconds: 1));
        final prevStart = start.subtract(const Duration(days: 30));
        return (start, todayEnd, prevStart, prevEnd);

      case DashboardTimeRange.last90Days:
        final start = todayStart.subtract(const Duration(days: 89));
        final prevEnd = start.subtract(const Duration(seconds: 1));
        final prevStart = start.subtract(const Duration(days: 90));
        return (start, todayEnd, prevStart, prevEnd);

      case DashboardTimeRange.thisYear:
        final start = DateTime(now.year, 1, 1);
        final prevStart = DateTime(now.year - 1, 1, 1);
        final prevEnd = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        return (start, todayEnd, prevStart, prevEnd);

      case DashboardTimeRange.custom:
        final start =
            customStart ?? todayStart.subtract(const Duration(days: 30));
        final end = customEnd ?? todayEnd;
        final duration = end.difference(start);
        final prevEnd = start.subtract(const Duration(seconds: 1));
        final prevStart = start.subtract(duration);
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(end.year, end.month, end.day, 23, 59, 59),
          DateTime(prevStart.year, prevStart.month, prevStart.day),
          prevEnd,
        );
    }
  }

  DashboardFinancialMetrics _computeFinancialMetrics({
    required List<InvoiceModel> invoices,
    required DateTime start,
    required DateTime end,
    required DateTime prevStart,
    required DateTime prevEnd,
    required DateTime now,
  }) {
    double totalCollected = 0.0;
    double previousPeriodCollected = 0.0;
    double totalInvoiced = 0.0;
    double previousPeriodInvoiced = 0.0;
    double totalOutstanding = 0.0;
    double overdueOutstanding = 0.0;
    double revenueToday = 0.0;
    double revenueThisWeek = 0.0;
    double revenueThisMonth = 0.0;

    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final Map<String, double> paymentMethods = {
      'Cash': 0.0,
      'UPI': 0.0,
      'Card': 0.0,
      'Bank Transfer': 0.0,
      'Other': 0.0,
    };

    for (final inv in invoices) {
      if (!inv.isPaid) {
        totalOutstanding += inv.balanceDue;
        if (inv.dueDate != null && inv.dueDate!.isBefore(now)) {
          overdueOutstanding += inv.balanceDue;
        }
      }

      final invoiceDate = inv.issuedAt ?? inv.createdAt ?? now;
      if (_isInRange(invoiceDate, start, end)) {
        totalInvoiced += inv.totalAmount;
      } else if (_isInRange(invoiceDate, prevStart, prevEnd)) {
        previousPeriodInvoiced += inv.totalAmount;
      }

      if (inv.paymentRecords.isNotEmpty) {
        for (final record in inv.paymentRecords) {
          final recordDate = record.recordedAt ?? invoiceDate;
          if (_isInRange(recordDate, start, end)) {
            totalCollected += record.amount;
            _tallyPaymentMethod(paymentMethods, record.method, record.amount);
          } else if (_isInRange(recordDate, prevStart, prevEnd)) {
            previousPeriodCollected += record.amount;
          }

          if (recordDate.isAfter(todayStart) ||
              recordDate.isAtSameMomentAs(todayStart)) {
            revenueToday += record.amount;
          }
          if (recordDate.isAfter(weekStart) ||
              recordDate.isAtSameMomentAs(weekStart)) {
            revenueThisWeek += record.amount;
          }
          if (recordDate.isAfter(monthStart) ||
              recordDate.isAtSameMomentAs(monthStart)) {
            revenueThisMonth += record.amount;
          }
        }
      } else if (inv.paidAmount > 0) {
        if (_isInRange(invoiceDate, start, end)) {
          totalCollected += inv.paidAmount;
          _tallyPaymentMethod(paymentMethods, 'Cash', inv.paidAmount);
        } else if (_isInRange(invoiceDate, prevStart, prevEnd)) {
          previousPeriodCollected += inv.paidAmount;
        }

        if (invoiceDate.isAfter(todayStart) ||
            invoiceDate.isAtSameMomentAs(todayStart)) {
          revenueToday += inv.paidAmount;
        }
        if (invoiceDate.isAfter(weekStart) ||
            invoiceDate.isAtSameMomentAs(weekStart)) {
          revenueThisWeek += inv.paidAmount;
        }
        if (invoiceDate.isAfter(monthStart) ||
            invoiceDate.isAtSameMomentAs(monthStart)) {
          revenueThisMonth += inv.paidAmount;
        }
      }
    }

    double? collectedGrowthRate;
    if (previousPeriodCollected > 0) {
      collectedGrowthRate =
          ((totalCollected - previousPeriodCollected) /
              previousPeriodCollected) *
          100;
    } else if (totalCollected > 0) {
      collectedGrowthRate = 100.0;
    }

    double? invoicedGrowthRate;
    if (previousPeriodInvoiced > 0) {
      invoicedGrowthRate =
          ((totalInvoiced - previousPeriodInvoiced) / previousPeriodInvoiced) *
          100;
    } else if (totalInvoiced > 0) {
      invoicedGrowthRate = 100.0;
    }

    final Map<String, double> paymentPercentages = {};
    if (totalCollected > 0) {
      paymentMethods.forEach((key, val) {
        paymentPercentages[key] = (val / totalCollected) * 100;
      });
    }

    final dailyPoints = _generateDailyRevenuePoints(
      invoices: invoices,
      start: start,
      end: end,
      now: now,
    );

    return DashboardFinancialMetrics(
      totalCollected: totalCollected,
      previousPeriodCollected: previousPeriodCollected,
      collectedGrowthRate: collectedGrowthRate,
      totalInvoiced: totalInvoiced,
      previousPeriodInvoiced: previousPeriodInvoiced,
      invoicedGrowthRate: invoicedGrowthRate,
      totalOutstanding: totalOutstanding,
      overdueOutstanding: overdueOutstanding,
      revenueToday: revenueToday,
      revenueThisWeek: revenueThisWeek,
      revenueThisMonth: revenueThisMonth,
      paymentMethodBreakdown: paymentMethods,
      paymentMethodPercentages: paymentPercentages,
      dailyRevenuePoints: dailyPoints,
    );
  }

  void _tallyPaymentMethod(
    Map<String, double> map,
    String rawMethod,
    double amount,
  ) {
    final m = rawMethod.trim().toLowerCase();
    if (m.contains('cash')) {
      map['Cash'] = (map['Cash'] ?? 0.0) + amount;
    } else if (m.contains('upi') ||
        m.contains('gpay') ||
        m.contains('phonepe') ||
        m.contains('paytm')) {
      map['UPI'] = (map['UPI'] ?? 0.0) + amount;
    } else if (m.contains('card') ||
        m.contains('razorpay') ||
        m.contains('pos')) {
      map['Card'] = (map['Card'] ?? 0.0) + amount;
    } else if (m.contains('bank') ||
        m.contains('neft') ||
        m.contains('rtgs') ||
        m.contains('transfer')) {
      map['Bank Transfer'] = (map['Bank Transfer'] ?? 0.0) + amount;
    } else {
      map['Other'] = (map['Other'] ?? 0.0) + amount;
    }
  }

  List<DashboardChartPoint> _generateDailyRevenuePoints({
    required List<InvoiceModel> invoices,
    required DateTime start,
    required DateTime end,
    required DateTime now,
  }) {
    final diffDays = end.difference(start).inDays;
    final count = diffDays <= 1 ? 1 : (diffDays <= 7 ? diffDays + 1 : 7);
    final intervalDuration = Duration(
      milliseconds:
          (end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) ~/ count,
    );

    final List<DashboardChartPoint> points = [];

    for (int i = 0; i < count; i++) {
      final pointStart = start.add(intervalDuration * i);
      final pointEnd = (i == count - 1)
          ? end
          : start.add(intervalDuration * (i + 1));

      double billed = 0.0;
      double collected = 0.0;

      for (final inv in invoices) {
        final invDate = inv.issuedAt ?? inv.createdAt ?? now;
        if (_isInRange(invDate, pointStart, pointEnd)) {
          billed += inv.totalAmount;
        }

        if (inv.paymentRecords.isNotEmpty) {
          for (final rec in inv.paymentRecords) {
            final recDate = rec.recordedAt ?? invDate;
            if (_isInRange(recDate, pointStart, pointEnd)) {
              collected += rec.amount;
            }
          }
        } else if (inv.paidAmount > 0) {
          if (_isInRange(invDate, pointStart, pointEnd)) {
            collected += inv.paidAmount;
          }
        }
      }

      final label = diffDays <= 1
          ? '${pointStart.hour.toString().padLeft(2, '0')}:00'
          : '${pointStart.day}/${pointStart.month}';

      points.add(
        DashboardChartPoint(
          date: pointStart,
          label: label,
          invoiced: billed,
          collected: collected,
        ),
      );
    }

    return points;
  }

  DashboardOperationalMetrics _computeOperationalMetrics({
    required List<ServiceJobModel> jobs,
    required List<EstimateModel> estimates,
    required List<AppointmentModel> appointments,
    required DateTime start,
    required DateTime end,
    required DateTime prevStart,
    required DateTime prevEnd,
    required DateTime now,
  }) {
    int totalJobsReceived = 0;
    int previousPeriodJobsReceived = 0;
    int jobsInProgress = 0;
    int jobsAwaitingAssignment = 0;
    int jobsAwaitingInspection = 0;
    int jobsAwaitingParts = 0;
    int jobsReadyForPickup = 0;
    int jobsCompleted = 0;
    int jobsCancelled = 0;
    int jobsOverdue = 0;

    final Map<String, int> statusDist = {};
    final Map<String, int> vehicleTypeDist = {
      'Cars': 0,
      'Bikes': 0,
      'Scooters': 0,
      'Other': 0,
    };
    final Map<String, int> serviceCategoryDist = {};

    for (final job in jobs) {
      final jobDate = job.createdAt ?? now;
      if (_isInRange(jobDate, start, end)) {
        totalJobsReceived++;
      } else if (_isInRange(jobDate, prevStart, prevEnd)) {
        previousPeriodJobsReceived++;
      }

      final s = job.status.toLowerCase();
      statusDist[job.status] = (statusDist[job.status] ?? 0) + 1;

      if (job.isActiveRepair) {
        jobsInProgress++;
      }
      if (job.isCompletedRepair) {
        if (_isInRange(job.completedDate ?? jobDate, start, end)) {
          jobsCompleted++;
        }
      }
      if (job.isCancelled) {
        jobsCancelled++;
      }
      if (job.technicianName.trim().isEmpty &&
          !job.isCompletedRepair &&
          !job.isCancelled) {
        jobsAwaitingAssignment++;
      }
      if (s.contains('inspection')) {
        jobsAwaitingInspection++;
      }
      if (s.contains('part')) {
        jobsAwaitingParts++;
      }
      if (s.contains('ready')) {
        jobsReadyForPickup++;
      }
      if (!job.isCompletedRepair &&
          !job.isCancelled &&
          job.estimatedCompletionDate != null &&
          job.estimatedCompletionDate!.isBefore(now)) {
        jobsOverdue++;
      }

      final vDisplay = job.vehicleDisplay.toLowerCase();
      if (vDisplay.contains('activa') ||
          vDisplay.contains('jupiter') ||
          vDisplay.contains('access') ||
          vDisplay.contains('scooter') ||
          vDisplay.contains('dio') ||
          vDisplay.contains('vespa') ||
          vDisplay.contains('aerox')) {
        vehicleTypeDist['Scooters'] = (vehicleTypeDist['Scooters'] ?? 0) + 1;
      } else if (vDisplay.contains('enfield') ||
          vDisplay.contains('bike') ||
          vDisplay.contains('motorcycle') ||
          vDisplay.contains('pulsar') ||
          vDisplay.contains('ktm') ||
          vDisplay.contains('yamaha') ||
          vDisplay.contains('splendor') ||
          vDisplay.contains('apache') ||
          vDisplay.contains('himalayan') ||
          vDisplay.contains('bullet')) {
        vehicleTypeDist['Bikes'] = (vehicleTypeDist['Bikes'] ?? 0) + 1;
      } else if (vDisplay.contains('car') ||
          vDisplay.contains('swift') ||
          vDisplay.contains('hyundai') ||
          vDisplay.contains('honda') ||
          vDisplay.contains('maruti') ||
          vDisplay.contains('tata') ||
          vDisplay.contains('mahindra') ||
          vDisplay.contains('toyota') ||
          vDisplay.contains('kia') ||
          vDisplay.contains('creta') ||
          vDisplay.contains('sedan') ||
          vDisplay.contains('suv')) {
        vehicleTypeDist['Cars'] = (vehicleTypeDist['Cars'] ?? 0) + 1;
      } else {
        vehicleTypeDist['Other'] = (vehicleTypeDist['Other'] ?? 0) + 1;
      }

      if (job.complaints.isNotEmpty) {
        for (final c in job.complaints) {
          final normalized = _categorizeComplaint(c);
          serviceCategoryDist[normalized] =
              (serviceCategoryDist[normalized] ?? 0) + 1;
        }
      } else {
        serviceCategoryDist['General Maintenance'] =
            (serviceCategoryDist['General Maintenance'] ?? 0) + 1;
      }
    }

    final estimatesAwaitingApproval = estimates
        .where((e) => e.status == 'sent')
        .length;

    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayAppointments = appointments.where((a) {
      final aDate = a.preferredDate;
      return _isInRange(aDate, todayStart, todayEnd);
    }).length;

    double? jobsGrowthRate;
    if (previousPeriodJobsReceived > 0) {
      jobsGrowthRate =
          ((totalJobsReceived - previousPeriodJobsReceived) /
              previousPeriodJobsReceived) *
          100;
    } else if (totalJobsReceived > 0) {
      jobsGrowthRate = 100.0;
    }

    return DashboardOperationalMetrics(
      totalJobsReceived: totalJobsReceived,
      previousPeriodJobsReceived: previousPeriodJobsReceived,
      jobsGrowthRate: jobsGrowthRate,
      jobsInProgress: jobsInProgress,
      jobsAwaitingAssignment: jobsAwaitingAssignment,
      jobsAwaitingInspection: jobsAwaitingInspection,
      estimatesAwaitingApproval: estimatesAwaitingApproval,
      jobsAwaitingParts: jobsAwaitingParts,
      jobsReadyForPickup: jobsReadyForPickup,
      jobsCompleted: jobsCompleted,
      jobsCancelled: jobsCancelled,
      jobsOverdue: jobsOverdue,
      todayAppointments: todayAppointments,
      vehiclesCurrentlyUnderService: jobsInProgress,
      statusDistribution: statusDist,
      vehicleTypeDistribution: vehicleTypeDist,
      serviceCategoryDistribution: serviceCategoryDist,
    );
  }

  String _categorizeComplaint(String complaint) {
    final c = complaint.toLowerCase();
    if (c.contains('oil') || c.contains('filter') || c.contains('lube')) {
      return 'Oil & Fluid Service';
    } else if (c.contains('brake') ||
        c.contains('pad') ||
        c.contains('disc') ||
        c.contains('drum')) {
      return 'Brake System';
    } else if (c.contains('engine') ||
        c.contains('clutch') ||
        c.contains('gear') ||
        c.contains('transmission')) {
      return 'Engine & Powertrain';
    } else if (c.contains('battery') ||
        c.contains('wiring') ||
        c.contains('light') ||
        c.contains('horn') ||
        c.contains('starter')) {
      return 'Electrical & Lighting';
    } else if (c.contains('tire') ||
        c.contains('wheel') ||
        c.contains('puncture') ||
        c.contains('alignment')) {
      return 'Tires & Wheels';
    } else if (c.contains('ac') ||
        c.contains('cool') ||
        c.contains('heater') ||
        c.contains('radiator')) {
      return 'AC & Cooling';
    } else if (c.contains('paint') ||
        c.contains('dent') ||
        c.contains('wash') ||
        c.contains('polish')) {
      return 'Body & Detailing';
    }
    return 'General Servicing';
  }

  List<MechanicPerformanceMetric> _computeMechanicMetrics({
    required List<MechanicModel> mechanics,
    required List<ServiceJobModel> jobs,
    required DateTime start,
    required DateTime end,
  }) {
    if (mechanics.isEmpty) {
      final names = jobs
          .map((j) => j.technicianName.trim())
          .where((name) => name.isNotEmpty)
          .toSet();

      return names.map((name) {
        return _buildMetricForTechnician(
          id: name.toLowerCase().replaceAll(' ', '_'),
          name: name,
          specialization: 'Technician',
          jobs: jobs,
          start: start,
          end: end,
        );
      }).toList();
    }

    return mechanics.map((m) {
      return _buildMetricForTechnician(
        id: m.id,
        name: m.name,
        specialization: m.specialization.isNotEmpty
            ? m.specialization
            : 'Master Mechanic',
        jobs: jobs,
        start: start,
        end: end,
        phone: m.phone,
        isActive: m.isActive,
      );
    }).toList();
  }

  MechanicPerformanceMetric _buildMetricForTechnician({
    required String id,
    required String name,
    required String specialization,
    required List<ServiceJobModel> jobs,
    required DateTime start,
    required DateTime end,
    String phone = '',
    bool isActive = true,
  }) {
    final lowerName = name.trim().toLowerCase();
    final techJobs = jobs
        .where((j) => j.technicianName.trim().toLowerCase() == lowerName)
        .toList();

    int assignedCount = techJobs.length;
    int activeCount = 0;
    int completedCount = 0;
    double totalDurationHours = 0.0;
    int durationCount = 0;

    for (final j in techJobs) {
      if (j.isActiveRepair) {
        activeCount++;
      } else if (j.isCompletedRepair) {
        completedCount++;
        if (j.actualStartTime != null && j.completedDate != null) {
          final hrs =
              j.completedDate!.difference(j.actualStartTime!).inMinutes / 60.0;
          if (hrs > 0 && hrs < 240) {
            totalDurationHours += hrs;
            durationCount++;
          }
        }
      }
    }

    final completionRate = assignedCount > 0
        ? (completedCount / assignedCount) * 100
        : 0.0;

    final avgHours = durationCount > 0
        ? totalDurationHours / durationCount
        : null;

    final workloadStatus = activeCount == 0
        ? 'Available'
        : (activeCount <= 2 ? 'Normal' : 'High Workload');

    return MechanicPerformanceMetric(
      mechanicId: id,
      name: name,
      phone: phone,
      specialization: specialization,
      isActive: isActive,
      assignedJobsCount: assignedCount,
      activeJobsCount: activeCount,
      completedJobsCount: completedCount,
      completionRate: completionRate,
      averageCompletionHours: avgHours,
      workloadStatus: workloadStatus,
    );
  }

  CustomerRetentionMetrics _computeCustomerMetrics({
    required List<CustomerModel> customers,
    required List<ServiceJobModel> jobs,
    required List<InvoiceModel> invoices,
    required DateTime start,
    required DateTime end,
  }) {
    final Map<String, int> customerJobCounts = {};
    final Map<String, double> customerSpent = {};
    final Map<String, double> customerPending = {};
    final Map<String, String> customerNames = {};
    final Map<String, String> customerPhones = {};
    final Map<String, String> customerVehicles = {};

    for (final j in jobs) {
      final key = j.customerId.isNotEmpty
          ? j.customerId
          : (j.customerPhone.isNotEmpty ? j.customerPhone : j.customerName);
      if (key.trim().isEmpty) continue;

      customerJobCounts[key] = (customerJobCounts[key] ?? 0) + 1;
      if (j.customerName.isNotEmpty) customerNames[key] = j.customerName;
      if (j.customerPhone.isNotEmpty) customerPhones[key] = j.customerPhone;
      if (j.vehicleDisplay.isNotEmpty) customerVehicles[key] = j.vehicleDisplay;
    }

    for (final inv in invoices) {
      final key = inv.customerId.isNotEmpty ? inv.customerId : inv.jobId;
      customerSpent[key] = (customerSpent[key] ?? 0.0) + inv.paidAmount;
      if (inv.balanceDue > 0) {
        customerPending[key] = (customerPending[key] ?? 0.0) + inv.balanceDue;
      }
    }

    int newInPeriod = 0;
    int returningInPeriod = 0;

    for (final entry in customerJobCounts.entries) {
      if (entry.value > 1) {
        returningInPeriod++;
      } else {
        newInPeriod++;
      }
    }

    final totalActiveInPeriod = customerJobCounts.length;
    final repeatRate = totalActiveInPeriod > 0
        ? (returningInPeriod / totalActiveInPeriod) * 100
        : 0.0;

    final sortedEntries = customerJobCounts.entries.toList()
      ..sort((a, b) {
        final spentA = customerSpent[a.key] ?? 0.0;
        final spentB = customerSpent[b.key] ?? 0.0;
        return spentB.compareTo(spentA);
      });

    final topCustomers = sortedEntries.take(5).map((e) {
      return TopCustomerMetric(
        customerId: e.key,
        name: customerNames[e.key] ?? 'Customer',
        phone: customerPhones[e.key] ?? '',
        vehicleDisplay: customerVehicles[e.key] ?? '',
        jobCount: e.value,
        totalSpent: customerSpent[e.key] ?? 0.0,
        pendingBalance: customerPending[e.key] ?? 0.0,
      );
    }).toList();

    return CustomerRetentionMetrics(
      totalCustomers: customers.isNotEmpty
          ? customers.length
          : customerJobCounts.length,
      newCustomersInPeriod: newInPeriod,
      returningCustomersInPeriod: returningInPeriod,
      repeatCustomerRate: repeatRate,
      customersWithPendingBalance: customerPending.length,
      topCustomers: topCustomers,
    );
  }

  List<DashboardTransactionItem> _extractRecentTransactions({
    required List<InvoiceModel> invoices,
  }) {
    final List<DashboardTransactionItem> items = [];

    for (final inv in invoices) {
      if (inv.paymentRecords.isNotEmpty) {
        for (final rec in inv.paymentRecords) {
          items.add(
            DashboardTransactionItem(
              id: rec.id.isNotEmpty ? rec.id : '${inv.id}_${rec.recordedAt}',
              invoiceId: inv.id,
              invoiceNumber: inv.invoiceNumber,
              customerName: inv.customerId,
              amount: rec.amount,
              method: rec.method,
              recordedAt: rec.recordedAt ?? inv.createdAt ?? DateTime.now(),
              isSuccess: true,
            ),
          );
        }
      } else if (inv.paidAmount > 0) {
        items.add(
          DashboardTransactionItem(
            id: inv.id,
            invoiceId: inv.id,
            invoiceNumber: inv.invoiceNumber,
            customerName: inv.customerId,
            amount: inv.paidAmount,
            method: 'Cash',
            recordedAt: inv.issuedAt ?? inv.createdAt ?? DateTime.now(),
            isSuccess: true,
          ),
        );
      }
    }

    items.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return items.take(8).toList();
  }

  List<DashboardSmartAlert> _generateSmartAlerts({
    required List<ServiceJobModel> jobs,
    required List<InvoiceModel> invoices,
    required List<AppointmentModel> appointments,
    required List<MechanicPerformanceMetric> mechanics,
    required DateTime now,
  }) {
    final List<DashboardSmartAlert> alerts = [];

    final unassigned = jobs
        .where(
          (j) =>
              j.technicianName.trim().isEmpty &&
              !j.isCompletedRepair &&
              !j.isCancelled,
        )
        .length;
    if (unassigned > 0) {
      alerts.add(
        DashboardSmartAlert(
          id: 'unassigned_jobs',
          title: '$unassigned Jobs Awaiting Assignment',
          message: 'Vehicle service requests are checked in and waiting for a mechanic to be assigned.',
          severity: SmartAlertSeverity.warning,
          count: unassigned,
          actionLabel: 'Assign Mechanics',
          actionRoute: '/merchant/jobs',
        ),
      );
    }

    final overdue = jobs
        .where(
          (j) =>
              !j.isCompletedRepair &&
              !j.isCancelled &&
              j.estimatedCompletionDate != null &&
              j.estimatedCompletionDate!.isBefore(now),
        )
        .length;
    if (overdue > 0) {
      alerts.add(
        DashboardSmartAlert(
          id: 'overdue_jobs',
          title: '$overdue Delayed Vehicle Repairs',
          message: 'Active jobs have surpassed their estimated completion timeline. Check repair bottlenecks.',
          severity: SmartAlertSeverity.danger,
          count: overdue,
          actionLabel: 'Review Overdue',
          actionRoute: '/merchant/jobs',
        ),
      );
    }

    final overdueInvoices = invoices
        .where(
          (i) => !i.isPaid && i.dueDate != null && i.dueDate!.isBefore(now),
        )
        .toList();
    if (overdueInvoices.isNotEmpty) {
      final totalOverdueSum = overdueInvoices.fold<double>(
        0.0,
        (sum, item) => sum + item.balanceDue,
      );
      alerts.add(
        DashboardSmartAlert(
          id: 'overdue_invoices',
          title: '${overdueInvoices.length} Overdue Customer Invoices',
          message:
              'Total ${CurrencyFormatter.format(totalOverdueSum)} in outstanding balances requires customer follow-up.',
          severity: SmartAlertSeverity.warning,
          count: overdueInvoices.length,
          actionLabel: 'View Invoices',
          actionRoute: '/merchant/invoices',
        ),
      );
    }

    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayAppts = appointments.where((a) {
      final aDate = a.preferredDate;
      return _isInRange(aDate, todayStart, todayEnd);
    }).length;
    if (todayAppts > 0) {
      alerts.add(
        DashboardSmartAlert(
          id: 'today_appointments',
          title: '$todayAppts Service Bookings Scheduled Today',
          message: 'Customers are expected to arrive at the garage bays for scheduled maintenance today.',
          severity: SmartAlertSeverity.info,
          count: todayAppts,
          actionLabel: 'View Schedule',
          actionRoute: '/merchant/jobs',
        ),
      );
    }

    for (final m in mechanics) {
      if (m.activeJobsCount >= 4) {
        alerts.add(
          DashboardSmartAlert(
            id: 'heavy_load_${m.mechanicId}',
            title: '${m.name} has ${m.activeJobsCount} Active Jobs',
            message: 'Technician bay workload is high. Consider redistributing pending tasks to avoid delays.',
            severity: SmartAlertSeverity.info,
            count: m.activeJobsCount,
            actionLabel: 'Balance Bay Load',
            actionRoute: '/merchant/jobs',
          ),
        );
        break;
      }
    }

    return alerts;
  }

  bool _isInRange(DateTime date, DateTime start, DateTime end) {
    return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
        (date.isBefore(end) || date.isAtSameMomentAs(end));
  }
}

final merchantDashboardViewModelProvider =
    NotifierProvider<MerchantDashboardViewModel, MerchantDashboardState>(
      MerchantDashboardViewModel.new,
    );

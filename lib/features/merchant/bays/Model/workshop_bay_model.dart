class WorkshopBayModel {
  const WorkshopBayModel({
    required this.id,
    required this.garageId,
    required this.name,
    this.type = 'general',
    this.status = 'available',
    this.currentJobId,
    this.currentVehicleDisplay,
    this.currentMechanic,
    this.assignedAt,
    this.updatedAt,
  });

  final String id;
  final String garageId;
  final String name;
  final String type;
  final String status;
  final String? currentJobId;
  final String? currentVehicleDisplay;
  final String? currentMechanic;
  final DateTime? assignedAt;
  final DateTime? updatedAt;

  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isOccupied => status.toLowerCase() == 'occupied';
  bool get isMaintenance => status.toLowerCase() == 'maintenance';

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'name': name,
      'type': type,
      'status': status,
      'currentJobId': currentJobId,
      'currentVehicleDisplay': currentVehicleDisplay,
      'currentMechanic': currentMechanic,
      'assignedAt': assignedAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory WorkshopBayModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WorkshopBayModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      status: data['status'] as String? ?? 'available',
      currentJobId: data['currentJobId'] as String?,
      currentVehicleDisplay: data['currentVehicleDisplay'] as String?,
      currentMechanic: data['currentMechanic'] as String?,
      assignedAt: data['assignedAt'] != null
          ? DateTime.tryParse(data['assignedAt'] as String)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'] as String)
          : null,
    );
  }

  WorkshopBayModel copyWith({
    String? id,
    String? garageId,
    String? name,
    String? type,
    String? status,
    String? currentJobId,
    String? currentVehicleDisplay,
    String? currentMechanic,
    DateTime? assignedAt,
    DateTime? updatedAt,
  }) {
    return WorkshopBayModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      currentJobId: currentJobId ?? this.currentJobId,
      currentVehicleDisplay:
          currentVehicleDisplay ?? this.currentVehicleDisplay,
      currentMechanic: currentMechanic ?? this.currentMechanic,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkshopBaysState {
  const WorkshopBaysState({
    this.isLoading = false,
    this.bays = const [],
    this.filterStatus = 'all',
    this.errorMessage,
  });

  final bool isLoading;
  final List<WorkshopBayModel> bays;
  final String filterStatus;
  final String? errorMessage;

  int get totalBays => bays.length;
  int get availableBays => bays.where((b) => b.isAvailable).length;
  int get occupiedBays => bays.where((b) => b.isOccupied).length;
  int get maintenanceBays => bays.where((b) => b.isMaintenance).length;

  List<WorkshopBayModel> get filteredBays {
    if (filterStatus == 'all') return bays;
    return bays.where((b) => b.status.toLowerCase() == filterStatus).toList();
  }

  WorkshopBaysState copyWith({
    bool? isLoading,
    List<WorkshopBayModel>? bays,
    String? filterStatus,
    String? errorMessage,
  }) {
    return WorkshopBaysState(
      isLoading: isLoading ?? this.isLoading,
      bays: bays ?? this.bays,
      filterStatus: filterStatus ?? this.filterStatus,
      errorMessage: errorMessage,
    );
  }
}

class QCChecklistModel {
  static const List<String> standardChecklistItems = [
    'Engine Oil Level & Viscosity',
    'Brake Fluid & Coolant Levels',
    'Tire Pressure & Tread Depth',
    'Wheel Lug Nuts Torqued',
    'Headlights, Tail Lights & Horn',
    'Battery Terminals & Cranking Voltage',
    'Diagnostic OBD Scan Cleared',
    'Cabin Cleanliness & Vacuum',
    'Road Test Drive Completed',
  ];

  static Map<String, bool> defaultChecklist() {
    return {for (final item in standardChecklistItems) item: false};
  }

  static int passedCount(Map<String, bool> checklist) {
    return checklist.values.where((v) => v == true).length;
  }

  static int totalCount(Map<String, bool> checklist) {
    return checklist.isEmpty ? standardChecklistItems.length : checklist.length;
  }

  static double progress(Map<String, bool> checklist) {
    if (checklist.isEmpty) return 0.0;
    return passedCount(checklist) / totalCount(checklist);
  }

  static bool isAllPassed(Map<String, bool> checklist) {
    if (checklist.isEmpty) return false;
    for (final item in standardChecklistItems) {
      if (checklist[item] != true) return false;
    }
    return true;
  }
}

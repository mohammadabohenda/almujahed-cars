// ============================================================================
// ملف: maintenance_record.dart  (Domain Entity)
// الوظيفة: يمثل سجل صيانة واحد مرتبط بسيارة معيّنة (تاريخ + وصف + تكلفة).
// ============================================================================

class MaintenanceRecord {
  final String id;
  final DateTime date;
  final String description;
  final double cost;

  const MaintenanceRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.cost,
  });
}

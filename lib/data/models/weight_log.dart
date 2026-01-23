import 'package:cloud_firestore/cloud_firestore.dart';

class WeightLog {
  final String id;
  final double kg;
  final DateTime createdAt;

  const WeightLog({
    required this.id,
    required this.kg,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "kg": kg,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  static WeightLog fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data["createdAt"];
    DateTime created = DateTime.now();
    if (ts is Timestamp) created = ts.toDate();

    final rawKg = data["kg"];
    final kg = (rawKg is int) ? rawKg.toDouble() : (rawKg as num?)?.toDouble() ?? 0.0;

    return WeightLog(
      id: doc.id,
      kg: kg,
      createdAt: created,
    );
  }
}

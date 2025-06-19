
class Drug {
  late final int? id;
  final String name;
  final String dosage;
  final String hour;
  final String frequency;
  final bool isTaken;

  Drug({
    this.id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.frequency,
    this.isTaken = false,
  });

  // This to convert Drug to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'hour': hour,
      'frequency': frequency,
      'is_taken': isTaken ? 1 : 0,
    };
  }


  factory Drug.fromMap(Map<String, dynamic> map) {
    return Drug(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      hour: map['hour'],
      frequency: map['frequency'],
      isTaken: map['is_taken'] == 1,
    );
  }


  Drug copyWith({
    int? id,
    String? name,
    String? dosage,
    String? hour,
    String? frequency,
    bool? isTaken,
  }) {
    return Drug(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      hour: hour ?? this.hour,
      frequency: frequency ?? this.frequency,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
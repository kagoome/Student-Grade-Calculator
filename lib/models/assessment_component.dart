class AssessmentComponent {
  final String id;
  final String name;
  final double score;
  final double weight;

  const AssessmentComponent({
    required this.id,
    required this.name,
    required this.score,
    required this.weight,
  });

  /// Mengubah data komponen menjadi Map.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'score': score, 'weight': weight};
  }

  /// Membuat komponen dari data Map.
  factory AssessmentComponent.fromMap(Map<String, dynamic> map) {
    return AssessmentComponent(
      id: map['id'] as String,
      name: map['name'] as String,
      score: (map['score'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }

  /// Membuat salinan komponen dengan data yang diperbarui.
  AssessmentComponent copyWith({
    String? id,
    String? name,
    double? score,
    double? weight,
  }) {
    return AssessmentComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      weight: weight ?? this.weight,
    );
  }
}

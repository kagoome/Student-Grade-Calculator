import 'dart:convert';

class GradeBand {
  final String grade;
  final int minScore;
  final int maxScore;
  final double weight;
  final String description;

  const GradeBand({
    required this.grade,
    required this.minScore,
    required this.maxScore,
    required this.weight,
    required this.description,
  });

  // Mengubah satu grade menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'min_score': minScore,
      'max_score': maxScore,
      'weight': weight,
      'description': description,
    };
  }

  // Membaca satu grade dari Map.
  factory GradeBand.fromMap(Map<String, dynamic> map) {
    return GradeBand(
      grade: map['grade'] as String,
      minScore: (map['min_score'] as num).toInt(),
      maxScore: (map['max_score'] as num).toInt(),
      weight: (map['weight'] as num).toDouble(),
      description: map['description'] as String,
    );
  }
}

class GradeTemplate {
  final String id;
  final String name;
  final bool isOriginal;
  final List<GradeBand> grades;

  const GradeTemplate({
    required this.id,
    required this.name,
    required this.isOriginal,
    required this.grades,
  });

  // Original Template bawaan aplikasi.
  factory GradeTemplate.original() {
    return const GradeTemplate(
      id: 'original_template',
      name: 'Original Template',
      isOriginal: true,
      grades: [
        GradeBand(
          grade: 'A',
          minScore: 81,
          maxScore: 100,
          weight: 4.0,
          description: 'Istimewa',
        ),
        GradeBand(
          grade: 'B+',
          minScore: 76,
          maxScore: 80,
          weight: 3.5,
          description: 'Baik sekali',
        ),
        GradeBand(
          grade: 'B',
          minScore: 66,
          maxScore: 75,
          weight: 3.0,
          description: 'Baik',
        ),
        GradeBand(
          grade: 'C+',
          minScore: 61,
          maxScore: 65,
          weight: 2.5,
          description: 'Cukup baik',
        ),
        GradeBand(
          grade: 'C',
          minScore: 51,
          maxScore: 60,
          weight: 2.0,
          description: 'Cukup',
        ),
        GradeBand(
          grade: 'D',
          minScore: 31,
          maxScore: 50,
          weight: 1.0,
          description: 'Kurang',
        ),
        GradeBand(
          grade: 'E',
          minScore: 0,
          maxScore: 30,
          weight: 0.0,
          description: 'Gagal',
        ),
      ],
    );
  }

  // Mengubah seluruh template menjadi Map.
  // Daftar grade disimpan dalam bentuk JSON String.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_original': isOriginal ? 1 : 0,
      'grades': jsonEncode(grades.map((grade) => grade.toMap()).toList()),
    };
  }

  // Membaca template dari Map.
  factory GradeTemplate.fromMap(Map<String, dynamic> map) {
    final decodedGrades = jsonDecode(map['grades'] as String) as List;

    return GradeTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      isOriginal: (map['is_original'] as num).toInt() == 1,
      grades: decodedGrades.map((item) {
        return GradeBand.fromMap(Map<String, dynamic>.from(item as Map));
      }).toList(),
    );
  }
}

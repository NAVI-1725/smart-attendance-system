// mobile_app/lib/features/faculty/models/classroom.dart

class Classroom {
  final int id;
  final String name;

  const Classroom({
    required this.id,
    required this.name,
  });

  factory Classroom.fromJson(
    Map<String, dynamic> json,
  ) {
    return Classroom(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
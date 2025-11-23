class UserModel {
  final String id;
  final String email;
  final String firstName;
  final int age;
  final String weightGoal;
  final List<String> dietaryRestrictions;
  final String defaultBudget;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.age,
    required this.weightGoal,
    required this.dietaryRestrictions,
    required this.defaultBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'age': age,
      'weight_goal': weightGoal,
      'dietary_restrictions': dietaryRestrictions,
      'default_budget': defaultBudget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['first_name'] as String,
      age: map['age'] as int,
      weightGoal: map['weight_goal'] as String,
      dietaryRestrictions: List<String>.from(map['dietary_restrictions'] as List? ?? []),
      defaultBudget: map['default_budget'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    int? age,
    String? weightGoal,
    List<String>? dietaryRestrictions,
    String? defaultBudget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
      weightGoal: weightGoal ?? this.weightGoal,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      defaultBudget: defaultBudget ?? this.defaultBudget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
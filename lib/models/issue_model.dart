// lib/models/issue_model.dart
import 'dart:typed_data';

class Issue {
  final String id;
  final String name; // User name
  final String email;
  final String? phone;
  final String title;
  final String description;
  final String? category;
  final String? priority;
  final String? location;
  final Uint8List? attachment;
  final DateTime date;

  Issue({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.title,
    required this.description,
    this.category,
    this.priority,
    this.location,
    this.attachment,
    required this.date,
  });

  /// Convert Issue object to a Map (for database or JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'location': location,
      'attachment': attachment,
      'date': date.toIso8601String(),
    };
  }

  /// Create Issue object from a Map (from database or JSON)
  factory Issue.fromMap(Map<String, dynamic> map) {
    return Issue(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'],
      priority: map['priority'],
      location: map['location'],
      attachment: map['attachment'],
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

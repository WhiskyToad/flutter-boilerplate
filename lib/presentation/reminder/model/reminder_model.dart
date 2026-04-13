import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final DateTime scheduledDateTime;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledDateTime,
  });

  @override
  List<Object?> get props => [id, title, description, scheduledDateTime];
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, approved, completed, cancelled }

class AppointmentModel {
  final String? id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String doctorName;
  final DateTime date;
  final String timeSlot;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;

  AppointmentModel({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.date,
    required this.timeSlot,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      notes: data['notes'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'notes': notes,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
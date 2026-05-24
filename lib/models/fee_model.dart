// lib/models/fee_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum FeeStatus { paid, pending, overdue }

extension FeeStatusExtension on FeeStatus {
  String get label {
    switch (this) {
      case FeeStatus.paid:    return 'Paid';
      case FeeStatus.pending: return 'Pending';
      case FeeStatus.overdue: return 'Overdue';
    }
  }

  static FeeStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'paid':    return FeeStatus.paid;
      case 'overdue': return FeeStatus.overdue;
      default:        return FeeStatus.pending;
    }
  }
}

class FeeModel extends Equatable {
  final String    id;
  final String    studentId;
  final String    studentName;
  final double    totalFees;
  final double    paidAmount;
  final DateTime  academicYear;
  final String?   batchId;
  final String?   course;
  final DateTime  createdAt;
  final DateTime  updatedAt;

  double get remaining  => totalFees - paidAmount;
  double get paidPercent => totalFees > 0 ? (paidAmount / totalFees * 100).clamp(0, 100) : 0;

  FeeStatus get overallStatus {
    if (paidAmount >= totalFees) return FeeStatus.paid;
    return FeeStatus.pending;
  }

  const FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.totalFees,
    required this.paidAmount,
    required this.academicYear,
    this.batchId,
    this.course,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeeModel.fromMap(Map<String, dynamic> map, String id) {
    return FeeModel(
      id:           id,
      studentId:    map['studentId']    as String? ?? '',
      studentName:  map['studentName']  as String? ?? '',
      totalFees:   (map['totalFees']    as num?)?.toDouble() ?? 0,
      paidAmount:  (map['paidAmount']   as num?)?.toDouble() ?? 0,
      academicYear:(map['academicYear'] as Timestamp?)?.toDate() ?? DateTime.now(),
      batchId:      map['batchId']      as String?,
      course:       map['course']       as String?,
      createdAt:   (map['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:   (map['updatedAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory FeeModel.fromDoc(DocumentSnapshot doc) {
    return FeeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'studentId':   studentId,
    'studentName': studentName,
    'totalFees':   totalFees,
    'paidAmount':  paidAmount,
    'academicYear':Timestamp.fromDate(academicYear),
    'batchId':     batchId,
    'course':      course,
    'createdAt':   Timestamp.fromDate(createdAt),
    'updatedAt':   Timestamp.fromDate(updatedAt),
  };

  @override
  List<Object?> get props => [id, studentId, totalFees, paidAmount];
}

// ── Installment Model ──────────────────────────────────────────────────────────
class InstallmentModel extends Equatable {
  final String    id;
  final String    feeId;
  final String    studentId;
  final int       installmentNo;
  final double    amount;
  final DateTime  dueDate;
  final DateTime? paidDate;
  final FeeStatus status;
  final String?   notes;

  bool get isDueSoon {
    if (status == FeeStatus.paid) return false;
    final days = dueDate.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 5;
  }

  const InstallmentModel({
    required this.id,
    required this.feeId,
    required this.studentId,
    required this.installmentNo,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.notes,
  });

  factory InstallmentModel.fromMap(Map<String, dynamic> map, String id) {
    return InstallmentModel(
      id:             id,
      feeId:          map['feeId']         as String? ?? '',
      studentId:      map['studentId']     as String? ?? '',
      installmentNo: (map['installmentNo'] as int?) ?? 1,
      amount:        (map['amount']        as num?)?.toDouble() ?? 0,
      dueDate:       (map['dueDate']       as Timestamp?)?.toDate() ?? DateTime.now(),
      paidDate:      (map['paidDate']      as Timestamp?)?.toDate(),
      status:         FeeStatusExtension.fromString(map['status'] as String? ?? 'pending'),
      notes:          map['notes']         as String?,
    );
  }

  factory InstallmentModel.fromDoc(DocumentSnapshot doc) {
    return InstallmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'feeId':         feeId,
    'studentId':     studentId,
    'installmentNo': installmentNo,
    'amount':        amount,
    'dueDate':       Timestamp.fromDate(dueDate),
    'paidDate':      paidDate != null ? Timestamp.fromDate(paidDate!) : null,
    'status':        status.label.toLowerCase(),
    'notes':         notes,
  };

  @override
  List<Object?> get props => [id, feeId, installmentNo];
}

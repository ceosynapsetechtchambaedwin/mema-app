
// lib/models/donation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, Timestamp;

class Donation{
  final String userId;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final DateTime createdAt;
  final String status;

  Donation({
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'amount': amount,
        'payementmethod': paymentMethod,
        'transactionId': transactionId,
        'created_at': Timestamp.fromDate(createdAt),
        'status': status,
      };

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Donation(
      userId: data['userId'],
      amount: (data['amount'] as num).toDouble(),
      paymentMethod: data['payementmethod'],
      transactionId: data['transactionId'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      status: data['status'],
    );
  }
}



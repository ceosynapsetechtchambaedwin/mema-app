
import 'package:flutter/material.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:provider/provider.dart';

import '../../core/services/stream_service.dart';
import '../../models/donation_model.dart';
import '../../view_models/langue_view_model.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Historiques'),
      ),
      body: StreamBuilder<List<Donation>>(
        stream: StreamService().getDonationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                isFrench
                    ? 'Aucune transaction trouvée.'
                    : 'No transaction found.',
              ),
            );
          }

          final donations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        donation.status == "success" ? Colors.green : Colors.red,
                    child: Icon(
                      donation.status == "success" ? Icons.check : Icons.error,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    "${donation.amount.toStringAsFixed(0)} FCFA - ${donation.paymentMethod}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrench
                            ? "ID de transaction : ${donation.transactionId}"
                            : "Transaction ID: ${donation.transactionId}",
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${isFrench ? "Date" : "Date"} : ${_formatDate(donation.createdAt)}",
                      ),
                    ],
                  ),
                  trailing: Text(
                    isFrench
                        ? _statusLabelFr(donation.status)
                        : _statusLabelEn(donation.status),
                    style: TextStyle(
                      color:
                          donation.status == "success" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} - "
        "${date.hour.toString().padLeft(2, '0')}:" 
        "${date.minute.toString().padLeft(2, '0')}";
  }

  String _statusLabelFr(String status) {
    switch (status) {
      case 'success':
        return 'RÉUSSIE';
      case 'pending':
        return 'EN ATTENTE';
      case 'failed':
        return 'ÉCHOUÉE';
      default:
        return status.toUpperCase();
    }
  }

  String _statusLabelEn(String status) {
    switch (status) {
      case 'success':
        return 'SUCCESS';
      case 'pending':
        return 'PENDING';
      case 'failed':
        return 'FAILED';
      default:
        return status.toUpperCase();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../view_models/langue_view_model.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _amountController = TextEditingController();
  final uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFrench ? "Faire un don" : "Make a Donation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isFrench
                  ? "Soutenez notre initiative avec un don."
                  : "Support our initiative with a donation.",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isFrench ? "Montant (FCFA)" : "Amount (XAF)",
                prefixIcon: const Icon(Icons.money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _initiatePayment,
              icon: const Icon(Icons.payment),
              label:
                  Text(isFrench ? "Payer avec CinetPay" : "Pay with CinetPay"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initiatePayment() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount < 100) {
      _showSnackBar(
          "Veuillez entrer un montant valide (min 100 FCFA)");
      return;
    }

    final transactionId = uuid.v4();
    final apiKey = 'YOUR_API_KEY'; // À remplacer
    final siteId = 'YOUR_SITE_ID'; // À remplacer
    final notifyUrl = 'https://yourdomain.com/cinetpay/callback';

    final url =
        'https://checkout.cinetpay.com?transaction_id=$transactionId'
        '&amount=$amount'
        '&currency=XAF'
        '&apikey=$apiKey'
        '&site_id=$siteId'
        '&description=Donation'
        '&notify_url=$notifyUrl'
        '&customer_name=Anonymous'
        '&customer_email=anonymous@example.com';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar("Impossible d’ouvrir le lien de paiement.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}

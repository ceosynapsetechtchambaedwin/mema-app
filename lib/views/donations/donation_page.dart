import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../view_models/langue_view_model.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final uuid = const Uuid();

  bool _isLaunching = false;

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFrench ? "Faire un don" : "Make a Donation"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isFrench
                  ? "Soutenez notre mission. Chaque don compte !"
                  : "Support our mission. Every donation matters!",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _nameController,
              label: isFrench ? "Nom du donateur (facultatif)" : "Donor name (optional)",
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: "Email (optionnel)",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _amountController,
              label: isFrench ? "Montant (min 100 FCFA)" : "Amount (min 100 XAF)",
              icon: Icons.money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLaunching ? null : _initiatePayment,
              icon: const Icon(Icons.payment),
              label: Text(isFrench ? "Payer avec CinetPay" : "Pay with CinetPay"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLaunching)
              const CircularProgressIndicator(),
            if (!_isLaunching) ...[
              Text("Veuillez confirmer votre don de $_amountController.text XAF"),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _initiatePayment() async {
    final amount = double.tryParse(_amountController.text.trim());
    final name = _nameController.text.trim().isEmpty
        ? "Anonymous"
        : _nameController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? "anonymous@example.com"
        : _emailController.text.trim();

    if (amount == null || amount < 100) {
      _showSnackBar("Veuillez entrer un montant valide (min 100 FCFA)");
      return;
    }

    setState(() => _isLaunching = true);

    final transactionId = uuid.v4();

    // ⚠️ À sécuriser dans un backend en production
    const apiKey = '312703280680692c8c3a644.80747994';  // Remplacer par ta clé API
    const siteId = '105892882';  // Remplacer par ton ID site
    const notifyUrl = 'https://yourdomain.com/cinetpay/callback';  // Facultatif
    const returnUrl = 'https://yourdomain.com/cinetpay/return';  // Facultatif

    final body = {
      "apikey": apiKey,
      "site_id": siteId,
      "transaction_id": transactionId,
      "amount": amount.toString(),
      "currency": "XAF",
      "description": "Donation",
      "return_url": returnUrl,
      "notify_url": notifyUrl,
      "customer_name": name,
      "customer_email": email,
      "customer_phone_number": "0000000000",  // Facultatif mais recommandé
      "channels": "ALL"
    };

    try {
      final response = await http.post(
        Uri.parse('https://sandbox.cinetpay.com/v2/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentUrl = data['data']["payment_url"];
        
        setState(() => _isLaunching = false);  // Revenir à l'état normal

        // Afficher l'URL dans un message ou une alerte
        _showSnackBar("Voici le lien pour payer: $paymentUrl");
      } else {
        setState(() => _isLaunching = false);
        _showSnackBar("Erreur CinetPay : ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      setState(() => _isLaunching = false);
      _showSnackBar("Erreur lors de la connexion à CinetPay.");
      print("Erreur: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}

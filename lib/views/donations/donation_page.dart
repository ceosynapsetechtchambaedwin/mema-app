import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faire un don")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Soutenez notre mission. Chaque don compte !",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildTextField(_nameController, "Nom du donateur (facultatif)", Icons.person),
            const SizedBox(height: 20),
            _buildTextField(_emailController, "Email (optionnel)", Icons.email, TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(_amountController, "Montant (min 100 FCFA)", Icons.money, TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _initiatePayment,
              icon: const Icon(Icons.payment),
              label: const Text("Payer avec CinetPay"),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _initiatePayment() async {
    final amount = double.tryParse(_amountController.text.trim());
    final name = _nameController.text.trim().isEmpty ? "Anonymous" : _nameController.text.trim();
    final email = _emailController.text.trim().isEmpty ? "anonymous@example.com" : _emailController.text.trim();

    if (amount == null || amount < 100) {
      _showSnackBar("Veuillez entrer un montant valide (min 100 FCFA)");
      return;
    }

    setState(() => _isLoading = true);

    final transactionId = uuid.v4();

    const apiKey = '7386037226822d93ea4fe84.40769546'; // 🔒 À déplacer côté backend en production
    const siteId = '105894977';

    final body = {
      "apikey": apiKey,
      "site_id": siteId,
      "transaction_id": transactionId,
      "amount": amount.toStringAsFixed(0),
      "currency": "XAF",
      "description": "Donation",
      "customer_name": name,
      "customer_email": email,
      "customer_phone_number": "0000000000",
      "notify_url": "https://example.com/notify",  // Peut être laissé factice pour le sandbox
      "return_url": "https://example.com/return",  // Peut être laissé factice pour le sandbox
      "channels": "ALL",
    };

    try {
      final response = await http.post(
        Uri.parse('https://sandbox.cinetpay.com/api/v1/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data['data'] != null && data['data']['payment_url'] != null) {
          final paymentUrl = data['data']['payment_url'];
          _launchURL(paymentUrl);
        } else {
          _showSnackBar("Erreur : réponse inattendue de CinetPay.${response.body}");
          debugPrint("Réponse inattendue : ${response.body}");
        }
      } else {
        _showSnackBar("Erreur CinetPay : ${response.statusCode} - ${response.body}");
        debugPrint("Erreur HTTP : ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Erreur lors de la connexion à CinetPay.");
      debugPrint("Exception : $e");
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Impossible d'ouvrir le lien de paiement.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

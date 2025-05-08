import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class TemoignageDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final Timestamp date;
  final String url;

  const TemoignageDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(context),
            const SizedBox(height: 40),
            _buildVideoButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      shadowColor: Colors.blueAccent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 10),
            _buildDate(),
            const SizedBox(height: 20),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22, // Réduction de la taille du titre
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDate() {
    return Text(
      "📅 ${"Date: ${truncateWithEllipsis("${date.toDate()}")}"}",
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      description,
      style: const TextStyle(fontSize: 18, color: Colors.black87),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildVideoButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: () async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Impossible d'ouvrir la vidéo.")),
            );
          }
        },
        icon: const Icon(
          Icons.play_arrow,
          size: 32,
          color: Colors.white,
        ),
        label: const Text(
          "Voir la vidéo",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String truncateWithEllipsis(String text, {int cutoff = 16}) {
    if (text.length <= cutoff) return text;
    return '${text.substring(0, cutoff)}';
  }
}

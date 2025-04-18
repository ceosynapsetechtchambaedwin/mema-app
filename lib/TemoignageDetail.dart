import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TemoignageDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
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
      appBar: AppBar(
        title: const Text("Détails du témoignage"),
        backgroundColor: const Color.fromARGB(255, 68, 138, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${date.day}/${date.month}/${date.year}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Voir la vidéo"),
            )
          ],
        ),
      ),
    );
  }
}

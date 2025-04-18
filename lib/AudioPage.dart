import 'package:flutter/material.dart';

class PodcastListPage extends StatelessWidget {
  final List<Map<String, String>> podcasts = List.generate(10, (index) {
    return {
      'title': 'Podcast Inspirant #${index + 1}',
      'date': '0${index + 1} Avril 2025',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text("Tous les Podcasts",style: TextStyle(color: Colors.white),),
      //   backgroundColor: Color.fromARGB(255, 68, 138, 255), // Bleu Cyan
      //   centerTitle: true,
      //   elevation: 2,
      // ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: podcasts.length,
        itemBuilder: (context, index) {
          final podcast = podcasts[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 68, 138, 255), // Bleu cyan
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones, size: 28, color: Colors.white),
              ),
              title: Text(
                podcast['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text("Soumis le ${podcast['date']}"),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'partager') {
                    // Action de partage
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Partager ${podcast['title']}"),
                    ));
                  } else if (value == 'telecharger') {
                    // Action de téléchargement
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Téléchargement de ${podcast['title']}"),
                    ));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'partager',
                    child: Text("Partager"),
                  ),
                  const PopupMenuItem(
                    value: 'telecharger',
                    child: Text("Télécharger"),
                  ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Lecture de ${podcast['title']}"),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}

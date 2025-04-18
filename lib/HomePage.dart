// import 'package:flutter/material.dart';

// class HomePagePrincipal extends StatefulWidget {
//   const HomePagePrincipal({super.key});

//   @override
//   State<HomePagePrincipal> createState() => _HomePagePrincipalState();
// }

// class _HomePagePrincipalState extends State<HomePagePrincipal> {
//   final TextEditingController _searchController = TextEditingController();
//   final List<String> _tags = ["Foi", "Jeunesse", "Guérison", "Prière"];
//   String? _selectedTag;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           children: [
//             const Text(
//               "Bienvenue à l'Église Vivante",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1A237E),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Barre de recherche + Tags
//             _buildSearchBarWithTags(),

//             const SizedBox(height: 20),

//             _buildSectionHeader("Actualités"),
//             const SizedBox(height: 10),
//             Column(
//               children: List.generate(3, (index) {
//                 return _buildNewsCard(
//                   "Retraite Spirituelle",
//                   "Venez vivre une retraite inoubliable du 15 au 20 mai.",
//                   "12 Avril 2025",
//                   14,
//                 );
//               }),
//             ),

//             const SizedBox(height: 24),
//             _buildSectionHeader("Podcasts"),
//             const SizedBox(height: 10),
//             Column(
//               children: List.generate(2, (index) {
//                 return _buildPodcastItem(
//                   "Marcher selon l'Esprit",
//                   "10 Avril 2025",
//                 );
//               }),
//             ),

//             const SizedBox(height: 24),
//             _buildSectionHeader("Témoignages"),
//             const SizedBox(height: 10),
//             _buildHorizontalList(
//               items: List.generate(
//                 4,
//                 (i) => _buildVideoCard("Ma guérison miraculeuse #$i"),
//               ),
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBarWithTags() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Rechercher...",
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: _selectedTag != null
//                       ? IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () {
//                             setState(() {
//                               _selectedTag = null;
//                               _searchController.clear();
//                             });
//                           },
//                         )
//                       : null,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   contentPadding:
//                       const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Action de recherche ici
//               },
//               icon: const Icon(Icons.search, size: 18),
//               label: const Text("Chercher"),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                 backgroundColor: const Color(0xFF1A237E),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 6,
//           children: _tags.map((tag) {
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedTag = tag;
//                   _searchController.text = tag;
//                 });
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.blue),
//                 ),
//                 child: Text(
//                   tag,
//                   style: const TextStyle(
//                     color: Colors.blue,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1A237E),
//                 )),
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 "Voir plus",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ],
//         ),
//         Container(
//           height: 2,
//           width: 40,
//           margin: const EdgeInsets.only(top: 2),
//           color: Colors.deepOrange,
//         ),
//       ],
//     );
//   }

//   Widget _buildNewsCard(String title, String description, String date, int shares) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Icon(Icons.article_outlined, size: 22, color: Colors.deepOrange),
//             const SizedBox(height: 8),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Image.asset(
//                 'assets/news_placeholder.jpeg', 
//                 height: 140,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(title,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(description,
//                 style: const TextStyle(fontSize: 13, color: Colors.black87)),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("📅 $date", style: const TextStyle(fontSize: 12)),
//                 Row(
//                   children: [
//                     const Icon(Icons.share, size: 16, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text("$shares partages", style: const TextStyle(fontSize: 12)),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPodcastItem(String title, String date) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: const Icon(Icons.headphones, size: 32, color: Colors.blueAccent),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: Text("Soumis le $date"),
//         trailing: PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert),
//           itemBuilder: (context) => [
//             const PopupMenuItem(value: 'partager', child: Text("Partager")),
//             const PopupMenuItem(value: 'telecharger', child: Text("Télécharger")),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHorizontalList({required List<Widget> items}) {
//     return SizedBox(
//       height: 190,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) => items[index],
//       ),
//     );
//   }

//   Widget _buildVideoCard(String title) {
//     return Container(
//       width: 180,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.grey[100],
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15),
//             blurRadius: 4,
//             offset: const Offset(2, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 100,
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//               gradient: LinearGradient(
//                 colors: [Colors.indigo, Colors.lightBlue],
//               ),
//             ),
//             child: const Center(
//               child: Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Text(
//               title,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class HomePagePrincipal extends StatefulWidget {
  const HomePagePrincipal({super.key});

  @override
  State<HomePagePrincipal> createState() => _HomePagePrincipalState();
}

class _HomePagePrincipalState extends State<HomePagePrincipal> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _tags = ["Foi", "Jeunesse", "Guérison", "Prière"];
  String? _selectedTag;

  final Color primaryBlue = const Color.fromARGB(255, 68, 138, 255);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            
            const SizedBox(height: 16),
            _buildSearchBarWithTags(),
            const SizedBox(height: 24),
            _buildSectionHeader("Actualités"),
            const SizedBox(height: 10),
            Column(
              children: List.generate(3, (index) {
                return _buildNewsCard(
                  "Retraite Spirituelle",
                  "Venez vivre une retraite inoubliable du 15 au 20 mai.",
                  "12 Avril 2025",
                  14,
                );
              }),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Podcasts"),
            const SizedBox(height: 10),
            Column(
              children: List.generate(2, (index) {
                return _buildPodcastItem("Marcher selon l'Esprit", "10 Avril 2025");
              }),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Témoignages"),
            const SizedBox(height: 10),
            _buildHorizontalList(
              items: List.generate(
                4,
                (i) => _buildVideoCard("Ma guérison miraculeuse #$i", "11 Avril 2025"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarWithTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Rechercher...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: primaryBlue),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _tags.map((tag) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTag = tag;
                  _searchController.text = tag;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryBlue),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            )),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
          ),
          child: const Text("Voir plus"),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, String description, String date, int shares) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/news_placeholder.jpeg',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("📅 $date", style: const TextStyle(fontSize: 12)),
                Row(
                  children: [
                    Icon(Icons.share, size: 16, color: primaryBlue),
                    const SizedBox(width: 4),
                    Text("$shares partages", style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodcastItem(String title, String date) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryBlue.withOpacity(0.9),
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.headphones, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'partager', child: Text("Partager")),
            const PopupMenuItem(value: 'telecharger', child: Text("Télécharger")),
           ],
         ),
      ),
    );
  }

  Widget _buildVideoCard(String title, String date) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.play_circle_fill, size: 40)),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(fontSize: 12)),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.share, color: primaryBlue, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList({required List<Widget> items}) {
    return SizedBox(
      height: 230,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items,
      ),
    );
  }
}

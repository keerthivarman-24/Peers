import 'package:flutter/material.dart';

class BrowseDoubtsScreen extends StatelessWidget {
  const BrowseDoubtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Browse Doubts",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            const SizedBox(height: 30),
            _sectionTitle("Trending Topics 🔥"),
            const SizedBox(height: 14),
            _trendingTopics(),
            const SizedBox(height: 35),
            _sectionTitle("Popular Communities"),
            const SizedBox(height: 14),
            _communitiesGrid(),
          ],
        ),
      ),
    );
  }

  // ---------------- SEARCH BAR ----------------
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF6366F1)),
          hintText: "Search doubts, topics, keywords...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ---------------- TRENDING TOPICS ----------------
  Widget _trendingTopics() {
    final topics = [
      "Calculus",
      "Circuits",
      "Quantum",
      "Python",
      "Flutter",
      "Sem Exams",
      "NEET",
      "JEE",
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                topics[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- COMMUNITIES GRID ----------------
  Widget _communitiesGrid() {
    final communities = [
      {
        "title": "Engineering",
        "subtitle": "Circuits, Maths, Mechanics",
        "icon": Icons.engineering,
      },
      {
        "title": "Medical",
        "subtitle": "Biology, NEET, Anatomy",
        "icon": Icons.biotech,
      },
      {
        "title": "Programming",
        "subtitle": "Python, Java, Flutter",
        "icon": Icons.code,
      },
      {
        "title": "Physics",
        "subtitle": "Quantum, EMFT, Optics",
        "icon": Icons.science,
      },
    ];

    return GridView.builder(
      itemCount: communities.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final community = communities[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  community["icon"] as IconData,
                  size: 34,
                  color: const Color(0xFF6366F1),
                ),
                const SizedBox(height: 14),
                Text(
                  community["title"] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  community["subtitle"] as String,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }
}

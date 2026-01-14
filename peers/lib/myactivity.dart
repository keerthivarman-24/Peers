import 'package:flutter/material.dart';

class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /* ---------------- SAMPLE LOCAL DATA ---------------- */

  final List<Map<String, dynamic>> myDoubts = [
    {
      "title": "Explain Kirchhoff’s Law in simple terms",
      "department": "Electrical Engineering",
      "solved": true,
    },
    {
      "title": "Difference between AC and DC current?",
      "department": "Electrical Engineering",
      "solved": false,
    },
    {
      "title": "What is Laplace Transform used for?",
      "department": "Mathematics",
      "solved": true,
    },
  ];

  final List<Map<String, String>> mySolutions = [
    {
      "title": "Kirchhoff’s Law",
      "content":
          "Kirchhoff’s law is based on conservation of charge and energy.",
    },
    {
      "title": "AC vs DC",
      "content":
          "AC alternates direction periodically, while DC flows in one direction.",
    },
  ];

  /* --------------------------------------------------- */

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: const Text("My Activity"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "My Doubts"),
            Tab(text: "My Solutions"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyDoubts(),
          _buildMySolutions(),
        ],
      ),
    );
  }

  /* ---------------- MY DOUBTS ---------------- */

  Widget _buildMyDoubts() {
    if (myDoubts.isEmpty) {
      return const Center(child: Text("No doubts posted yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myDoubts.length,
      itemBuilder: (context, index) {
        final doubt = myDoubts[index];
        final bool solved = doubt["solved"];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            title: Text(
              doubt["title"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "${doubt["department"]} • ${solved ? "Solved" : "Pending"}",
              style: TextStyle(
                color: solved ? Colors.green : Colors.orange,
              ),
            ),
            trailing: Icon(
              solved ? Icons.check_circle : Icons.hourglass_bottom,
              color: solved ? Colors.green : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  /* ---------------- MY SOLUTIONS ---------------- */

  Widget _buildMySolutions() {
    if (mySolutions.isEmpty) {
      return const Center(child: Text("No solutions added yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mySolutions.length,
      itemBuilder: (context, index) {
        final solution = mySolutions[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lightbulb, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text(
                      "Solution Posted",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  solution["title"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  solution["content"]!,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

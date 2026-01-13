import 'package:flutter/material.dart';

void main() {
  runApp(const DoubtSolverApp());
}

class DoubtSolverApp extends StatelessWidget {
  const DoubtSolverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doubt Solver',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          background: const Color(0xFFFAFAFA),
        ),
      ),
      home: const DoubtScreen(),
    );
  }
}

class DoubtScreen extends StatelessWidget {
  const DoubtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doubt Discussion"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showBottomSheet(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [DoubtCard(), ReplyCard(), ReplyCard()],
      ),
    );
  }
}

/* -------------------- DOUBT CARD -------------------- */

class DoubtCard extends StatelessWidget {
  const DoubtCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Anonymous Student • 10 mins ago",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            const Text(
              "Can someone explain Kirchhoff’s Law in simple terms?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.arrow_upward, color: Colors.indigo, size: 20),
                SizedBox(width: 4),
                Text("42"),
                SizedBox(width: 20),
                Icon(Icons.comment, size: 18),
                SizedBox(width: 4),
                Text("8"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- REPLY CARD -------------------- */

class ReplyCard extends StatelessWidget {
  const ReplyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Anonymous Solver",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                "Kirchhoff’s law is based on conservation of charge. "
                "The sum of currents entering a node equals the sum leaving it.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 6),
              Text(
                "📄 solution.pdf",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------- BOTTOM SHEET -------------------- */

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Ask a Doubt"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Add Solution"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Upload File"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text("Share Link"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}

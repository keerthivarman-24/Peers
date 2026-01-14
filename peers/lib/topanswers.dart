import 'package:flutter/material.dart';

class TopAnswersScreen extends StatelessWidget {
  const TopAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text("Top Answers"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _mockTopAnswers.length,
        itemBuilder: (context, index) {
          final answer = _mockTopAnswers[index];
          return TopAnswerCard(
            rank: index + 1,
            upvotes: answer.upvotes,
            answerText: answer.text,
            subject: answer.subject,
          );
        },
      ),
    );
  }
}

/* -------------------- TOP ANSWER CARD -------------------- */

class TopAnswerCard extends StatelessWidget {
  final int rank;
  final int upvotes;
  final String answerText;
  final String subject;

  const TopAnswerCard({
    super.key,
    required this.rank,
    required this.upvotes,
    required this.answerText,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  "#$rank",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                "$upvotes",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            answerText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "— Anonymous Solver",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/* -------------------- MOCK DATA -------------------- */

class TopAnswer {
  final String text;
  final int upvotes;
  final String subject;

  TopAnswer({required this.text, required this.upvotes, required this.subject});
}

final List<TopAnswer> _mockTopAnswers = [
  TopAnswer(
    text:
        "Kirchhoff’s Current Law states that the algebraic sum of currents at a node is zero. "
        "This comes directly from conservation of charge.",
    upvotes: 214,
    subject: "Circuit Theory",
  ),
  TopAnswer(
    text:
        "In quicksort, choosing a good pivot reduces time complexity significantly. "
        "Randomized pivot selection avoids worst cases.",
    upvotes: 187,
    subject: "Computer Science",
  ),
  TopAnswer(
    text:
        "Quantum entanglement is a physical phenomenon where pairs of particles become linked, ",
    upvotes: 162,
    subject: "Quantum Physics",
  ),
];

import 'package:flutter/material.dart';

class DoubtScreen extends StatelessWidget {
  const DoubtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Answers"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TopAnswerCard(
            rank: 1,
            upvotes: 124,
            subject: "Physics",
            answerText:
                "Kirchhoff’s law states that the total current entering a junction is equal to the total current leaving it.",
          ),
          SizedBox(height: 16),
          TopAnswerCard(
            rank: 2,
            upvotes: 96,
            subject: "Maths",
            answerText:
                "The Laplace Transform converts a time-domain function into a frequency-domain function.",
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------- */
/* ---------------- TOP ANSWER CARD ----------------- */
/* -------------------------------------------------- */

class TopAnswerCard extends StatelessWidget {
  final int rank;
  final int upvotes;
  final String subject;
  final String answerText;

  const TopAnswerCard({
    super.key,
    required this.rank,
    required this.upvotes,
    required this.subject,
    required this.answerText,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = "answer_$rank";

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 450),
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: ChatDetailScreen(
                  heroTag: heroTag,
                  subject: subject,
                  answerText: answerText,
                ),
              );
            },
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
              ),
              borderRadius: BorderRadius.circular(20),
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
                    const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 18,
                    ),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------- */
/* ---------------- CHAT DETAIL SCREEN --------------- */
/* -------------------------------------------------- */

class ChatDetailScreen extends StatelessWidget {
  final String heroTag;
  final String subject;
  final String answerText;

  const ChatDetailScreen({
    super.key,
    required this.heroTag,
    required this.subject,
    required this.answerText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Anonymous Student • 10 mins ago",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        answerText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const ReplyBubble(
            text:
                "Kirchhoff’s current law states that the sum of currents at a junction equals zero.",
          ),
          const ReplyBubble(
            text: "It is derived from conservation of electric charge.",
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------- */
/* ---------------- REPLY BUBBLE --------------------- */
/* -------------------------------------------------- */

class ReplyBubble extends StatelessWidget {
  final String text;
  const ReplyBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

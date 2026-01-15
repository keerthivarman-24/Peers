import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/app_theme.dart';
import 'core/ui.dart';
import 'models/doubt.dart';

class DoubtDetailsScreen extends StatefulWidget {
  const DoubtDetailsScreen({super.key, required this.doubtId});
  final String doubtId;

  @override
  State<DoubtDetailsScreen> createState() => _DoubtDetailsScreenState();
}

class _DoubtDetailsScreenState extends State<DoubtDetailsScreen> {
  Doubt? doubt;
  bool loading = true;
  bool postingAnswer = false;

  String? displayName;
  String? userId;

  bool answerAnonymous = true;
  final answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    displayName = await AppScope.I.session.getDisplayName();
    userId = await AppScope.I.session.getUserId();

    final res = await AppScope.I.doubts.getById(widget.doubtId);
    if (!mounted) return;

    setState(() {
      doubt = res.data;
      loading = false;
    });
  }

  String get voterKey =>
      (userId?.isNotEmpty ?? false) ? userId! : (displayName ?? 'guest');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : doubt == null
          ? Center(
              child: Text(
                'Doubt not found',
                style: TextStyle(color: AppTheme.muted.withValues(alpha: 0.9)),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _doubtCard(doubt!),
                        const SizedBox(height: 14),
                        _answersCard(doubt!),
                        const SizedBox(height: 14),
                        _answerComposer(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 14,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doubt Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Read, upvote, and answer.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doubtCard(Doubt d) {
    return Ui.glassChild(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: Ui.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            if (d.attempt.trim().isNotEmpty)
              Text(
                d.attempt,
                style: const TextStyle(
                  fontSize: 13.2,
                  color: AppTheme.muted,
                  height: 1.25,
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: d.tags
                  .take(4)
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.2,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat(Icons.chat_bubble_outline_rounded, '${d.answers}'),
                const SizedBox(width: 12),
                _stat(Icons.thumb_up_alt_outlined, '${d.upvotes}'),
                const Spacer(),
                Text(
                  Ui.timeAgo(d.createdAt),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12.2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleUpvote,
                    icon: const Icon(
                      Icons.thumb_up_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Upvote',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.muted),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.muted,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleUpvote() async {
    if (doubt == null) return;
    final res = await AppScope.I.doubts.toggleUpvote(
      doubtId: doubt!.id,
      voterKey: voterKey,
    );
    if (!mounted) return;
    if (!res.ok) {
      Ui.snack(context, res.error ?? 'Failed');
      return;
    }
    setState(() => doubt = res.data);
  }

  Widget _answersCard(Doubt d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Ui.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Ui.iconBadge(Icons.question_answer_rounded),
              const SizedBox(width: 10),
              Text(
                'Answers (${d.answers})',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15.5,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (d.answerList.isEmpty)
            const Text(
              'No answers yet. Be the first one!',
              style: TextStyle(color: AppTheme.muted),
            )
          else
            Column(
              children: d.answerList.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              a.isAnonymous
                                  ? Icons.person_off_rounded
                                  : Icons.person_rounded,
                              size: 16,
                              color: AppTheme.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              a.isAnonymous
                                  ? 'Anonymous'
                                  : (a.authorName ?? 'User'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.text,
                                fontSize: 12.8,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              Ui.timeAgo(a.createdAt),
                              style: const TextStyle(
                                color: AppTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.body,
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _answerComposer() {
    return Ui.glassChild(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: Ui.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Ui.iconBadge(Icons.edit_rounded),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Write an Answer',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                Switch(
                  value: answerAnonymous,
                  onChanged: (v) => setState(() => answerAnonymous = v),
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: answerController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your answer…',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: postingAnswer ? null : _postAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(minHeight: 48),
                    child: postingAnswer
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Post Answer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _postAnswer() async {
    final text = answerController.text.trim();
    if (text.isEmpty) {
      Ui.snack(context, 'Answer cannot be empty');
      return;
    }

    if (!answerAnonymous &&
        (displayName == null || displayName!.trim().isEmpty)) {
      Ui.snack(
        context,
        'No name found. Use anonymous or set your name in Login/Guest.',
      );
      return;
    }

    if (doubt == null) return;

    setState(() => postingAnswer = true);
    try {
      final res = await AppScope.I.doubts.addAnswer(
        doubtId: doubt!.id,
        body: text,
        isAnonymous: answerAnonymous,
        authorName: answerAnonymous ? null : displayName,
        authorId: userId,
      );

      if (!mounted) return;
      if (!res.ok) {
        Ui.snack(context, res.error ?? 'Failed');
        return;
      }

      setState(() {
        doubt = res.data;
        answerController.clear();
      });
      Ui.snack(context, 'Answer posted successfully');
    } finally {
      if (mounted) setState(() => postingAnswer = false);
    }
  }
}

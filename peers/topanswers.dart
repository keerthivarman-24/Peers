import 'dart:ui';
import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/app_theme.dart';
import 'core/ui.dart';
import 'doubt_details.dart';
import 'models/doubt.dart';

class TopAnswersScreen extends StatefulWidget {
  const TopAnswersScreen({super.key});

  @override
  State<TopAnswersScreen> createState() => _TopAnswersScreenState();
}

class _TopAnswersScreenState extends State<TopAnswersScreen> {
  bool loading = true;
  List<Doubt> list = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final res = await AppScope.I.doubts.fetchTopAnswers();
    if (!mounted) return;
    setState(() {
      list = res.data ?? [];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            if (loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ),
            if (!loading && list.isEmpty)
              SliverToBoxAdapter(child: _empty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _card(list[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 14, 18, 18),
      decoration: const BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(26), bottomRight: Radius.circular(26)),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Answers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Questions with the most answers.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Doubt d) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoubtDetailsScreen(doubtId: d.id))),
      child: Ui.glassChild(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: Ui.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Ui.iconBadge(Icons.star_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      d.question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppTheme.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _pill('Answers: ${d.answers}'),
                  const SizedBox(width: 8),
                  _pill('Upvotes: ${d.upvotes}'),
                  const Spacer(),
                  Text(Ui.timeAgo(d.createdAt), style: const TextStyle(color: AppTheme.muted, fontSize: 12.2)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w900, fontSize: 12.2)),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFEEF2FF), Color(0xFFEDE7FE)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.star_rounded, color: AppTheme.iconIndigo, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('No data yet',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppTheme.text)),
            const SizedBox(height: 6),
            const Text('Once users answer doubts, this will populate.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


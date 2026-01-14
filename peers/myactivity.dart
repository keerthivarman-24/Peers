import 'dart:ui';
import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/app_theme.dart';
import 'core/ui.dart';
import 'doubt_details.dart';
import 'models/doubt.dart';

class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  bool loading = true;
  List<Doubt> list = const [];

  String? displayName;
  String? userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    displayName = await AppScope.I.session.getDisplayName();
    userId = await AppScope.I.session.getUserId();

    final res = await AppScope.I.doubts.fetchMyActivity(authorId: userId, authorName: displayName);
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Activity', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  displayName == null ? 'Your posts (guest/name not set)' : 'Posts by ${displayName!}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
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
              Text(d.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppTheme.text)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _stat(Icons.chat_bubble_outline_rounded, '${d.answers}'),
                  const SizedBox(width: 12),
                  _stat(Icons.thumb_up_alt_outlined, '${d.upvotes}'),
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

  Widget _stat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.muted),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w900)),
      ],
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
              child: const Icon(Icons.history_rounded, color: AppTheme.iconIndigo, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('No activity yet',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppTheme.text)),
            const SizedBox(height: 6),
            const Text('Post your first doubt to see it here.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


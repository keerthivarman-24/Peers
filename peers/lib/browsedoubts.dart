import 'dart:ui';
import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/app_theme.dart';
import 'core/ui.dart';
import 'doubt_details.dart';
import 'models/doubt.dart';

enum DoubtSort { latest, unanswered, top }

class BrowseDoubtsScreen extends StatefulWidget {
  const BrowseDoubtsScreen({super.key});

  @override
  State<BrowseDoubtsScreen> createState() => _BrowseDoubtsScreenState();
}

class _BrowseDoubtsScreenState extends State<BrowseDoubtsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _topic;
  DoubtSort _sort = DoubtSort.latest;

  bool loading = true;
  List<Doubt> doubts = const [];

  final topics = const [
    'Calculus',
    'Circuits',
    'Quantum',
    'Python',
    'Flutter',
    'Sem Exams',
    'Physics',
    'Programming',
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text.trim()));
    _fetch();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => loading = true);
    final res = await AppScope.I.doubts.fetchFeed(topic: _topic, query: _query);
    if (!mounted) return;

    var list = res.data ?? [];

    switch (_sort) {
      case DoubtSort.latest:
        list = [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DoubtSort.unanswered:
        list = [...list]..sort((a, b) => a.answers.compareTo(b.answers));
        break;
      case DoubtSort.top:
        list = [...list]..sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
    }

    setState(() {
      doubts = list;
      loading = false;
    });
  }

  void _toggleTopic(String t) {
    setState(() {
      _topic = (_topic == t) ? null : t;
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(
        onRefresh: _fetch,
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBar(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Trending Topics 🔥',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.text)),
                        const Spacer(),
                        _sortMenu(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _topicChips(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Doubts Feed',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.text)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                          child: Text('${doubts.length}',
                              style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w900, fontSize: 12.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ),
            if (!loading && doubts.isEmpty)
              SliverToBoxAdapter(child: _empty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                sliver: SliverList.separated(
                  itemCount: doubts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _doubtCard(doubts[i]),
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
                Text('Browse Doubts', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Search, filter, and explore.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: Ui.cardDecoration(radius: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.iconIndigo),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search doubts, topics, keywords...',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _fetch(),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              onPressed: () {
                _search.clear();
                _fetch();
              },
              icon: const Icon(Icons.close_rounded, color: AppTheme.muted),
            ),
        ],
      ),
    );
  }

  Widget _topicChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final t = topics[i];
          final selected = _topic == t;
          return InkWell(
            onTap: () => _toggleTopic(t),
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: selected ? AppTheme.brandGradient : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: selected ? Colors.transparent : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(selected ? Icons.check_circle_rounded : Icons.local_fire_department_rounded,
                      size: 16, color: selected ? Colors.white : AppTheme.iconIndigo),
                  const SizedBox(width: 8),
                  Text(
                    t,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sortMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DoubtSort>(
          value: _sort,
          icon: const Icon(Icons.expand_more_rounded, color: AppTheme.muted),
          items: const [
            DropdownMenuItem(value: DoubtSort.latest, child: Text('Latest')),
            DropdownMenuItem(value: DoubtSort.unanswered, child: Text('Unanswered')),
            DropdownMenuItem(value: DoubtSort.top, child: Text('Top')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _sort = v);
            _fetch();
          },
        ),
      ),
    );
  }

  Widget _doubtCard(Doubt d) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DoubtDetailsScreen(doubtId: d.id)));
      },
      child: Ui.glassChild(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: Ui.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.question,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppTheme.text, height: 1.15),
              ),
              const SizedBox(height: 8),
              Text(
                d.attempt.isEmpty ? 'No attempt added.' : d.attempt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.2, color: AppTheme.muted, height: 1.25),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: d.tags.take(3).map((t) => _tag(t)).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _stat(Icons.chat_bubble_outline_rounded, '${d.answers}'),
                  const SizedBox(width: 12),
                  _stat(Icons.thumb_up_alt_outlined, '${d.upvotes}'),
                  const Spacer(),
                  Text(Ui.timeAgo(d.createdAt), style: const TextStyle(color: AppTheme.muted, fontSize: 12.2)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Open',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5)),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
      child: Text(t, style: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w800, fontSize: 12.2)),
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
              child: const Icon(Icons.search_off_rounded, color: AppTheme.iconIndigo, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('No doubts found',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppTheme.text)),
            const SizedBox(height: 6),
            const Text('Try different keywords or remove filters.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12.5), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _topic = null;
                  _sort = DoubtSort.latest;
                });
                _search.clear();
                _fetch();
              },
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Reset filters'),
            ),
          ],
        ),
      ),
    );
  }
}


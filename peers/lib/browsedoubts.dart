import 'dart:ui';
import 'package:flutter/material.dart';

enum DoubtSort { latest, unanswered, top }

class BrowseDoubtsScreen extends StatefulWidget {
  const BrowseDoubtsScreen({super.key});

  @override
  State<BrowseDoubtsScreen> createState() => _BrowseDoubtsScreenState();
}

class _BrowseDoubtsScreenState extends State<BrowseDoubtsScreen> {
  // ---------- Style constants ----------
  static const Color bg = Color(0xFFF8F9FC);
  static const Color text = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);
  static const Color primary = Color(0xFF4F46E5);
  static const Color accent = Color(0xFF9333EA);
  static const Color iconIndigo = Color(0xFF6366F1);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  // ---------- State ----------
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _query = '';
  String? _selectedTopic;
  DoubtSort _sort = DoubtSort.latest;
  bool _refreshing = false;

  // ---------- Sample data (replace with API/Firebase later) ----------
  final List<String> _topics = const [
    "Calculus",
    "Circuits",
    "Quantum",
    "Python",
    "Flutter",
    "Sem Exams",
    "NEET",
    "JEE",
  ];

  final List<_Community> _communities = const [
    _Community(
      title: "Engineering",
      subtitle: "Circuits, Maths, Mechanics",
      icon: Icons.engineering_rounded,
    ),
    _Community(
      title: "Medical",
      subtitle: "Biology, NEET, Anatomy",
      icon: Icons.biotech_rounded,
    ),
    _Community(
      title: "Programming",
      subtitle: "Python, Java, Flutter",
      icon: Icons.code_rounded,
    ),
    _Community(
      title: "Physics",
      subtitle: "Quantum, EMFT, Optics",
      icon: Icons.science_rounded,
    ),
  ];

  late List<_Doubt> _doubts;

  @override
  void initState() {
    super.initState();
    _doubts = _mockDoubts();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ---------- Filtering / sorting ----------
  List<_Doubt> get _filteredDoubts {
    final q = _query.toLowerCase();
    final topic = _selectedTopic;

    List<_Doubt> list = _doubts.where((d) {
      final matchesQuery =
          q.isEmpty ||
          d.title.toLowerCase().contains(q) ||
          d.body.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q));

      final matchesTopic = topic == null || d.tags.contains(topic);
      return matchesQuery && matchesTopic;
    }).toList();

    switch (_sort) {
      case DoubtSort.latest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DoubtSort.unanswered:
        list.sort(
          (a, b) => a.answers.compareTo(b.answers),
        ); // fewer answers first
        break;
      case DoubtSort.top:
        list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
    }

    return list;
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Simulate "new data"
    _doubts = _mockDoubts()
      ..insert(
        0,
        _Doubt(
          title: "New: How to find Thevenin equivalent quickly?",
          body: "I keep getting wrong Vth. Can someone share a quick method?",
          tags: const ["Circuits", "Engineering"],
          answers: 0,
          upvotes: 2,
          createdAt: DateTime.now(),
        ),
      );

    setState(() => _refreshing = false);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
  }

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopic == topic) {
        _selectedTopic = null;
      } else {
        _selectedTopic = topic;
      }
    });
  }

  void _openCommunity(_Community c) {
    // TODO: Navigate to community page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Open community: ${c.title}")));
  }

  void _openDoubt(_Doubt d) {
    // TODO: Navigate to doubt details page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Open doubt: ${d.title}")));
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final doubts = _filteredDoubts;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBar(),
                    const SizedBox(height: 18),

                    _sectionTitle("Trending Topics 🔥"),
                    const SizedBox(height: 10),
                    _trendingTopics(),
                    const SizedBox(height: 18),

                    _sectionTitle("Popular Communities"),
                    const SizedBox(height: 10),
                    _communitiesGrid(),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _sectionTitle("Latest Doubts"),
                        const SizedBox(width: 10),
                        _countPill("${doubts.length}"),
                        const Spacer(),
                        _sortMenu(),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Doubts list
            if (_refreshing)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 6, 18, 16),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ),

            doubts.isEmpty
                ? SliverToBoxAdapter(child: _emptyState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    sliver: SliverList.separated(
                      itemCount: doubts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _doubtCard(doubts[i]),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 14,
        18,
        18,
      ),
      decoration: BoxDecoration(
        gradient: brandGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
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
                Text(
                  "Browse Doubts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Search, filter, and explore community questions.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              _searchFocus.requestFocus();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.search_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Search Bar ----------
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      child: Row(
        children: [
          const Icon(Icons.search, color: iconIndigo),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: const InputDecoration(
                hintText: "Search doubts, topics, keywords...",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              tooltip: "Clear",
              onPressed: _clearSearch,
              icon: const Icon(Icons.close_rounded, color: muted),
            ),
        ],
      ),
    );
  }

  // ---------- Trending Topics ----------
  Widget _trendingTopics() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final t = _topics[index];
          final selected = _selectedTopic == t;

          return InkWell(
            onTap: () => _toggleTopic(t),
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: selected ? brandGradient : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.local_fire_department_rounded,
                    size: 16,
                    color: selected ? Colors.white : iconIndigo,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t,
                    style: TextStyle(
                      color: selected ? Colors.white : text,
                      fontWeight: FontWeight.w700,
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

  // ---------- Communities Grid ----------
  Widget _communitiesGrid() {
    return GridView.builder(
      itemCount: _communities.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final c = _communities[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openCommunity(c),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFEDE7FE)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(c.icon, size: 22, color: iconIndigo),
                ),
                const SizedBox(height: 12),
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: muted,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Row(
                  children: const [
                    Text(
                      "Explore",
                      style: TextStyle(
                        color: iconIndigo,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: iconIndigo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Sort menu ----------
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
          icon: const Icon(Icons.expand_more_rounded, color: muted),
          items: const [
            DropdownMenuItem(value: DoubtSort.latest, child: Text("Latest")),
            DropdownMenuItem(
              value: DoubtSort.unanswered,
              child: Text("Unanswered"),
            ),
            DropdownMenuItem(value: DoubtSort.top, child: Text("Top")),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _sort = v);
          },
        ),
      ),
    );
  }

  // ---------- Doubt card ----------
  Widget _doubtCard(_Doubt d) {
    final time = _timeAgo(d.createdAt);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openDoubt(d),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  d.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: text,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),

                // Body preview
                Text(
                  d.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.2,
                    color: muted,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: d.tags
                      .take(3)
                      .map((t) => _tagChip(t, selected: t == _selectedTopic))
                      .toList(),
                ),

                const SizedBox(height: 12),

                // Stats row
                Row(
                  children: [
                    _stat(Icons.chat_bubble_outline_rounded, "${d.answers}"),
                    const SizedBox(width: 12),
                    _stat(Icons.thumb_up_alt_outlined, "${d.upvotes}"),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(color: muted, fontSize: 12.2),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // CTA row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: brandGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "Answer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: muted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tagChip(String t, {bool selected = false}) {
    return InkWell(
      onTap: () => _toggleTopic(t),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.10) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? primary.withOpacity(0.35) : Colors.transparent,
          ),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: selected ? primary : const Color(0xFF374151),
            fontWeight: FontWeight.w700,
            fontSize: 12.2,
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(color: muted, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // ---------- Empty state ----------
  Widget _emptyState() {
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFEEF2FF), Color(0xFFEDE7FE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: iconIndigo,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "No doubts found",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
                color: text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try different keywords or remove filters.",
              style: TextStyle(color: muted.withOpacity(0.95), fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedTopic = null;
                  _sort = DoubtSort.latest;
                });
                _clearSearch();
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Reset filters"),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Simple UI helpers ----------
  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: text,
      ),
    );
  }

  Widget _countPill(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: muted,
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
        ),
      ),
    );
  }

  // ---------- Mock data ----------
  List<_Doubt> _mockDoubts() {
    final now = DateTime.now();
    return [
      _Doubt(
        title: "Why does current lead voltage in a capacitor?",
        body:
            "I understand the formula i = C dv/dt, but how do we visualize the phase lead?",
        tags: const ["Circuits", "Physics"],
        answers: 3,
        upvotes: 18,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      _Doubt(
        title: "Best way to solve integration by parts quickly?",
        body:
            "In exams I get stuck choosing u and dv. Any quick rule of thumb?",
        tags: const ["Calculus", "Sem Exams"],
        answers: 1,
        upvotes: 9,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      _Doubt(
        title: "Flutter: setState vs Provider — when to use what?",
        body:
            "I can build UIs but state management confuses me. How do I choose a pattern?",
        tags: const ["Flutter", "Programming"],
        answers: 0,
        upvotes: 6,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      _Doubt(
        title: "Quantum: why is the wavefunction complex?",
        body:
            "Is it just mathematical convenience or is there a physical meaning?",
        tags: const ["Quantum", "Physics"],
        answers: 5,
        upvotes: 22,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      ),
      _Doubt(
        title: "Python: list comprehension vs loops performance?",
        body: "Are comprehensions always faster? What about readability?",
        tags: const ["Python", "Programming"],
        answers: 2,
        upvotes: 11,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
}

// ---------- Models ----------
class _Community {
  final String title;
  final String subtitle;
  final IconData icon;

  const _Community({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _Doubt {
  final String title;
  final String body;
  final List<String> tags;
  final int answers;
  final int upvotes;
  final DateTime createdAt;

  const _Doubt({
    required this.title,
    required this.body,
    required this.tags,
    required this.answers,
    required this.upvotes,
    required this.createdAt,
  });
}

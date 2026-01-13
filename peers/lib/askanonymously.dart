import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:peers/session.dart';

enum PostIdentity { anonymous, named }

class AskAnonymouslyScreen extends StatefulWidget {
  const AskAnonymouslyScreen({super.key, required displayName});

  @override
  State<AskAnonymouslyScreen> createState() => _AskAnonymouslyScreenState();
}

class _AskAnonymouslyScreenState extends State<AskAnonymouslyScreen> {
  final doubtController = TextEditingController();
  final attemptController = TextEditingController();
  final linkController = TextEditingController();

  static const Color bg = Color(0xFFF8F9FC);
  static const Color text = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);
  static const Color primary = Color(0xFF4F46E5);
  static const Color accent = Color(0xFF9333EA);
  static const Color iconIndigo = Color(0xFF6366F1);

  PostIdentity identity = PostIdentity.anonymous;

  String? displayName;
  bool loadingName = true;
  bool submitting = false;

  bool get hasDoubt => doubtController.text.trim().isNotEmpty;
  bool get canUseName => (displayName ?? '').trim().isNotEmpty;

  bool get canSubmit {
    if (!hasDoubt) return false;
    if (identity == PostIdentity.named && !canUseName) return false;
    return !submitting;
  }

  LinearGradient get brandGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  @override
  void initState() {
    super.initState();
    doubtController.addListener(() => setState(() {}));
    _loadName();
  }

  Future<void> _loadName() async {
    setState(() => loadingName = true);
    displayName = await Session.getDisplayName();
    if (!mounted) return;
    setState(() => loadingName = false);
  }

  @override
  void dispose() {
    doubtController.dispose();
    attemptController.dispose();
    linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _topHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 130),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _identityCard(),
                  const SizedBox(height: 14),

                  _sectionCard(
                    icon: Icons.help_outline_rounded,
                    title: "Ask a Doubt",
                    subtitle:
                        "Be specific. Mention what you tried or where you got stuck.",
                    hint:
                        "Example: Why does current lead voltage in a capacitor?",
                    controller: doubtController,
                    maxLines: 5,
                    maxLength: 500,
                    showCounter: true,
                  ),
                  const SizedBox(height: 14),

                  _sectionCard(
                    icon: Icons.edit_note_rounded,
                    title: "Your Attempt (Optional)",
                    subtitle: "Helps others answer faster and more accurately.",
                    hint: "Write steps / formulas / assumptions…",
                    controller: attemptController,
                    maxLines: 4,
                    maxLength: 800,
                  ),
                  const SizedBox(height: 14),

                  _uploadCard(),
                  const SizedBox(height: 14),

                  _sectionCard(
                    icon: Icons.link_rounded,
                    title: "Reference Link (Optional)",
                    subtitle: "YouTube / blog / notes link for context",
                    hint: "Paste a URL here",
                    controller: linkController,
                    maxLines: 1,
                    maxLength: 400,
                    keyboardType: TextInputType.url,
                  ),

                  const SizedBox(height: 10),
                  _guidelinesCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(18, 10, 18, 12 + bottomPadding * 0.25),
        child: _submitBar(),
      ),
    );
  }

  // ---------- Header ----------
  Widget _topHeader(BuildContext context) {
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
                  "Ask a Question",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Choose anonymous or show your name.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _openGuidelines,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Identity ----------
  Widget _identityCard() {
    final isNamed = identity == PostIdentity.named;

    return Container(
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
          Row(
            children: [
              _iconBadge(Icons.person_rounded),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Posting Identity",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Choose how your post appears to others.",
                      style: TextStyle(fontSize: 12.5, color: muted),
                    ),
                  ],
                ),
              ),
              if (loadingName)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              else
                IconButton(
                  tooltip: "Refresh name",
                  onPressed: _loadName,
                  icon: const Icon(Icons.refresh_rounded, color: muted),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // segments
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _segment(
                    selected: identity == PostIdentity.anonymous,
                    label: "Anonymous",
                    icon: Icons.visibility_off_rounded,
                    onTap: () =>
                        setState(() => identity = PostIdentity.anonymous),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _segment(
                    selected: isNamed,
                    label: "Show Name",
                    icon: Icons.badge_rounded,
                    onTap: () {
                      if (!canUseName) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "No name found. Set your name in Login/Guest to use 'Show Name'.",
                            ),
                          ),
                        );
                        setState(() => identity = PostIdentity.anonymous);
                        return;
                      }
                      setState(() => identity = PostIdentity.named);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (isNamed && canUseName) ...[
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: brandGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Posting as: ${displayName ?? ''}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Visible to everyone",
                  style: TextStyle(color: muted, fontSize: 12.5),
                ),
              ],
            ),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: muted),
                SizedBox(width: 6),
                Text(
                  "Your identity will not be visible to others.",
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _segment({
    required bool selected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: selected ? brandGradient : null,
          color: selected ? null : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : muted,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Cards ----------
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String hint,
    required TextEditingController controller,
    required int maxLines,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool showCounter = false,
  }) {
    final len = controller.text.trim().length;

    return ClipRRect(
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
              Row(
                children: [
                  _iconBadge(icon),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: muted,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller,
                maxLines: maxLines,
                maxLength: maxLength,
                keyboardType: keyboardType,
                style: const TextStyle(
                  color: text,
                  fontSize: 14.5,
                  height: 1.35,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: muted.withOpacity(0.85)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  counterText: "",
                ),
              ),

              if (showCounter) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Keep it clear and complete",
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    Text(
                      maxLength == null ? "$len" : "$len/$maxLength",
                      style: TextStyle(
                        color: (maxLength != null && len >= maxLength)
                            ? Colors.redAccent
                            : muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadCard() {
    return Container(
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
      child: Row(
        children: [
          _iconBadge(Icons.upload_file_rounded),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upload File (Optional)",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    color: text,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "PDF/image/notes help others understand faster.",
                  style: TextStyle(fontSize: 12.5, color: muted, height: 1.25),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _pickFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Upload",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _pickFile() {
    // TODO: Add file_picker package later.
    // For now, keep stub.
  }

  Widget _guidelinesCard() {
    return InkWell(
      onTap: _openGuidelines,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: iconIndigo),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Tips: Add subject + unit + what you tried. It increases good answers.",
                style: TextStyle(color: muted, fontSize: 12.5, height: 1.25),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }

  void _openGuidelines() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "How to get better answers",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: text,
                ),
              ),
              SizedBox(height: 10),
              _Tip("Mention subject/unit (e.g., Circuit Theory – AC)."),
              _Tip("Include known values + what you tried."),
              _Tip("Upload image of question if possible."),
              _Tip("Avoid vague titles like “Help” — be specific."),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ---------- Submit Bar ----------
  Widget _submitBar() {
    final isNamed = identity == PostIdentity.named;
    final helper = isNamed
        ? "Your name will be visible on this post"
        : "Your identity stays hidden";
    final btnText = isNamed ? "Post with Name" : "Post Anonymously";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              isNamed ? Icons.badge_outlined : Icons.lock_outline_rounded,
              size: 16,
              color: muted.withOpacity(0.95),
            ),
            const SizedBox(width: 6),
            Text(
              helper,
              style: TextStyle(color: muted.withOpacity(0.95), fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: canSubmit ? _submit : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: canSubmit ? 1.0 : 0.5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: brandGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: iconIndigo.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: submitting
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
                    : Text(
                        btnText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!canSubmit) return;

    setState(() => submitting = true);

    try {
      final isAnonymous = identity == PostIdentity.anonymous;

      final payload = {
        "question": doubtController.text.trim(),
        "attempt": attemptController.text.trim(),
        "link": linkController.text.trim(),
        "isAnonymous": isAnonymous,
        "authorName": isAnonymous ? null : displayName,
        "createdAt": DateTime.now().toIso8601String(),
      };

      // TODO: Send payload to backend/firestore.
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAnonymous
                ? "Posted anonymously ✅"
                : "Posted as ${displayName ?? ''} ✅",
          ),
        ),
      );

      Navigator.pop(context); // go back after posting (optional)
      // print(payload); // debug
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to post. Try again.")),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  // ---------- UI helpers ----------
  Widget _iconBadge(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFEDE7FE)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconIndigo, size: 22),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFF4F46E5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

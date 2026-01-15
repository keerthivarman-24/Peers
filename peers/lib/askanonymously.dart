import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/app_theme.dart';
import 'core/ui.dart';
import 'core/validators.dart';
import 'models/attachment.dart';

enum PostIdentity { anonymous, named }

class AskAnonymouslyScreen extends StatefulWidget {
  const AskAnonymouslyScreen({super.key});

  @override
  State<AskAnonymouslyScreen> createState() => _AskAnonymouslyScreenState();
}

class _AskAnonymouslyScreenState extends State<AskAnonymouslyScreen> {
  final _formKey = GlobalKey<FormState>();

  final doubtController = TextEditingController();
  final attemptController = TextEditingController();
  final linkController = TextEditingController();

  PostIdentity identity = PostIdentity.anonymous;

  String? displayName;
  String? userId;

  bool loadingIdentity = true;
  bool submitting = false;

  final List<Attachment> _attachments = [];
  final Set<String> _tags = {};

  final List<String> availableTags = const [
    'Calculus',
    'Circuits',
    'Quantum',
    'Python',
    'Flutter',
    'Sem Exams',
    'Physics',
    'Programming',
  ];

  bool get canUseName => (displayName ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    doubtController.addListener(() => setState(() {}));
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    setState(() => loadingIdentity = true);
    displayName = await AppScope.I.session.getDisplayName();
    userId = await AppScope.I.session.getUserId();
    if (!mounted) return;
    setState(() => loadingIdentity = false);
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
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _topHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 130),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _identityCard(),
                    const SizedBox(height: 14),
                    _tagsCard(),
                    const SizedBox(height: 14),
                    _sectionCard(
                      icon: Icons.help_outline_rounded,
                      title: 'Ask a Doubt',
                      subtitle: 'Be specific. Mention where you got stuck.',
                      child: TextFormField(
                        controller: doubtController,
                        maxLines: 5,
                        maxLength: 500,
                        validator: (v) => Validators.requiredText(
                          v ?? '',
                          message: 'Enter your doubt',
                        ),
                        decoration: _inputDecoration(
                          hint:
                              'Example: Why does current lead voltage in a capacitor?',
                        ),
                      ),
                      footerRight: '${doubtController.text.trim().length}/500',
                    ),
                    const SizedBox(height: 14),
                    _sectionCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Your Attempt (Optional)',
                      subtitle: 'This helps others answer faster.',
                      child: TextFormField(
                        controller: attemptController,
                        maxLines: 4,
                        maxLength: 800,
                        decoration: _inputDecoration(
                          hint: 'Write steps / formulas / assumptions…',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _attachmentsCard(),
                    const SizedBox(height: 14),
                    _sectionCard(
                      icon: Icons.link_rounded,
                      title: 'Reference Link (Optional)',
                      subtitle: 'YouTube / blog / notes link',
                      child: TextFormField(
                        controller: linkController,
                        keyboardType: TextInputType.url,
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (!Validators.isValidUrl(s)) {
                            return 'Enter a valid URL (https://example.com)';
                          }
                          return null;
                        },
                        decoration: _inputDecoration(hint: 'Paste a URL here'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _guidelinesCard(),
                  ],
                ),
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

  Widget _topHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 14,
        18,
        18,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.22),
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
                  'Ask a Question',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose anonymous or show your name.',
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
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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

  Widget _identityCard() {
    final isNamed = identity == PostIdentity.named;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Ui.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Ui.iconBadge(Icons.person_rounded),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posting Identity',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                        color: AppTheme.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Choose how your post appears to others.',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              if (loadingIdentity)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              else
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _loadIdentity,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
                    label: 'Anonymous',
                    icon: Icons.visibility_off_rounded,
                    onTap: () =>
                        setState(() => identity = PostIdentity.anonymous),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _segment(
                    selected: isNamed,
                    label: 'Show Name',
                    icon: Icons.badge_rounded,
                    onTap: () {
                      if (!canUseName) {
                        Ui.snack(
                          context,
                          "No name found. Set it in Login/Guest to use 'Show Name'.",
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
          if (isNamed && canUseName)
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
                    gradient: AppTheme.brandGradient,
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
                        'Posting as: ${displayName ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Visible to everyone',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12.5),
                ),
              ],
            )
          else
            const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppTheme.muted,
                ),
                SizedBox(width: 6),
                Text(
                  'Your identity will not be visible to others.',
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
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
          gradient: selected ? AppTheme.brandGradient : null,
          color: selected ? null : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppTheme.muted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppTheme.muted,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Ui.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Ui.iconBadge(Icons.tag_rounded),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                        color: AppTheme.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select 1–3 tags for better reach.',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTags.map((t) {
              final selected = _tags.contains(t);
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  setState(() {
                    if (selected) {
                      _tags.remove(t);
                    } else {
                      if (_tags.length >= 3) {
                        Ui.snack(context, 'Select up to 3 tags only.');
                        return;
                      }
                      _tags.add(t);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withValues(alpha: 0.12)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? AppTheme.primary.withValues(alpha: 0.35)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: selected
                          ? AppTheme.primary
                          : const Color(0xFF374151),
                      fontWeight: FontWeight.w800,
                      fontSize: 12.2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Ui.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Ui.iconBadge(Icons.upload_file_rounded),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachments (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                        color: AppTheme.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'UI ready. Picker/storage will be connected later.',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _pickAttachments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              children: _attachments.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file_rounded,
                          color: AppTheme.iconIndigo,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            a.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: () => setState(
                            () => _attachments.removeWhere((x) => x.id == a.id),
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAttachments() async {
    final picked = await AppScope.I.picker.pickFiles();
    if (!mounted) return;

    if (picked.isEmpty) {
      Ui.snack(context, 'File picker not added yet. Will connect later.');
      return;
    }

    setState(() => _attachments.addAll(picked));
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    String? footerRight,
  }) {
    return Ui.glassChild(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: Ui.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Ui.iconBadge(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.muted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
            if (footerRight != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  footerRight,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppTheme.muted.withValues(alpha: 0.85)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      counterText: '',
    );
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
            Icon(Icons.lightbulb_outline_rounded, color: AppTheme.iconIndigo),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tips: Add tag + what you tried. It increases good answers.',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12.5,
                  height: 1.25,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
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
        return const Padding(
          padding: EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to get better answers',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppTheme.text,
                ),
              ),
              SizedBox(height: 10),
              _Tip('Choose 1–3 relevant tags.'),
              _Tip('Include known values + what you tried.'),
              _Tip('Upload an image/PDF (later via Firebase Storage).'),
              _Tip('Avoid vague text like “Help” — be specific.'),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _submitBar() {
    final isNamed = identity == PostIdentity.named;
    final helper = isNamed
        ? 'Your name will be visible on this post'
        : 'Your identity stays hidden';
    final btnText = isNamed ? 'Post with Name' : 'Post Anonymously';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              isNamed ? Icons.badge_outlined : Icons.lock_outline_rounded,
              size: 16,
              color: AppTheme.muted.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 6),
            Text(
              helper,
              style: TextStyle(
                color: AppTheme.muted.withValues(alpha: 0.95),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: submitting
              ? null
              : () async {
                  final ok = _formKey.currentState?.validate() ?? false;
                  if (!ok) return;
                  if (identity == PostIdentity.named && !canUseName) {
                    Ui.snack(
                      context,
                      'No name found. Use Anonymous or set name in Login.',
                    );
                    return;
                  }
                  await _submit();
                },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: submitting ? 0.7 : 1.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.iconIndigo.withValues(alpha: 0.35),
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
    if (submitting) return;
    setState(() => submitting = true);

    try {
      final isAnonymous = identity == PostIdentity.anonymous;

      final res = await AppScope.I.doubts.createDoubt(
        question: doubtController.text.trim(),
        attempt: attemptController.text.trim(),
        link: linkController.text.trim(),
        isAnonymous: isAnonymous,
        authorName: isAnonymous ? null : displayName,
        authorId: userId,
        tags: _tags.isEmpty ? const ['General'] : _tags.toList(),
        attachments: _attachments,
      );

      if (!mounted) return;
      if (!res.ok) {
        Ui.snack(context, res.error ?? 'Failed to post');
        return;
      }

      Ui.snack(context, 'Posted successfully');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      Ui.snack(context, 'Failed to post. Try again.');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
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
            color: AppTheme.primary,
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

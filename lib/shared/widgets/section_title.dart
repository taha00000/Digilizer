import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// `<h4>Sales mix</h4> ... Reports ›` — the section header from the prototype.
/// [trailing] takes either a text link (via [SectionLink]) or a [SegControl].
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: t.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// The `Reports ›` style affordance beside a section title.
class SectionLink extends StatelessWidget {
  const SectionLink(this.label, {super.key, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          '$label ›',
          style: TextStyle(
            color: t.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

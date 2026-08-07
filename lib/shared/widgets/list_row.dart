import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// `.lrow` — the tappable list row used by Modules, Call Reporting and
/// Reports.
///
/// ```css
/// .lrow{display:flex;align-items:center;gap:12px;background:var(--surface);
///       border:1px solid var(--aline);border-radius:16px;padding:13px 14px;
///       margin-bottom:9px}
/// .lrow .ic{width:40px;height:40px;border-radius:12px}
/// .lrow .nm{font-size:13.5px;font-weight:700}
/// .lrow .ds{font-size:11px;color:var(--asub);margin-top:1px}
/// .lrow .chev{margin-left:auto;color:var(--asub);opacity:.5;font-size:17px}
/// ```
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? subtitle;

  /// Replaces the chevron when supplied (e.g. a [StatusBadge]).
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: t.sub, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: trailing,
                  )
                else if (showChevron)
                  Opacity(
                    opacity: 0.5,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: t.sub,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `.grouplbl` — the small uppercase divider label between row groups.
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: t.sub,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.58, // .05em
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// `.appbar` — screen title with optional subtitle, and either a back button
/// or the profile avatar.
///
/// ```css
/// .appbar{padding:6px 20px 12px;display:flex;align-items:center;
///         justify-content:space-between}
/// .appbar .title{font-size:21px;font-weight:800;letter-spacing:-.02em}
/// .appbar .title small{font-size:12px;font-weight:500;color:var(--asub)}
/// .appbar .av{width:38px;height:38px;border-radius:50%;
///             background:var(--av-bg);color:var(--av-tx);font-weight:800}
/// .appbar .back{width:36px;height:36px;border-radius:11px;
///               background:var(--surface);border:1px solid var(--aline)}
/// ```
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.avatarInitials,
    this.onAvatarTap,
  });

  final String title;
  final String? subtitle;

  /// When set, a back chip replaces the leading edge and the avatar is
  /// dropped — matching `appbar(title, sub, back)` in the prototype.
  final VoidCallback? onBack;
  final String? avatarInitials;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border.all(color: t.line),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: t.ink,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
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
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.42, // -.02em
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: t.sub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onBack != null)
            // Keeps the title optically centred against the back chip.
            const SizedBox(width: 36)
          else if (avatarInitials != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onAvatarTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  avatarInitials!,
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

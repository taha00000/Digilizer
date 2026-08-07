import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// `.mod` — a tinted-icon tile in the modules grid.
///
/// ```css
/// .mod{background:var(--surface);border:1px solid var(--aline);
///      border-radius:20px;padding:16px 14px;text-align:left}
/// .mod:active{transform:scale(.97)}
/// .mod .ic{width:44px;height:44px;border-radius:13px;margin-bottom:11px}
/// .mod .mt{font-size:13.5px;font-weight:700}
/// .mod .ms{font-size:10.5px;color:var(--asub);margin-top:3px;line-height:1.35}
/// ```
class ModTile extends StatefulWidget {
  const ModTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  State<ModTile> createState() => _ModTileState();
}

class _ModTileState extends State<ModTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, size: 22, color: widget.iconColor),
              ),
              const SizedBox(height: 11),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: t.ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: t.sub,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

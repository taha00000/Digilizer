import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// One row in an [OptionSheet].
class SheetOption {
  const SheetOption({
    required this.id,
    required this.icon,
    required this.title,
    this.subtitle,
    this.danger = false,
  });

  final String id;
  final IconData icon;
  final String title;
  final String? subtitle;

  /// `.opt.danger` — rose tint, for destructive choices.
  final bool danger;
}

/// `.sheet-pop` with `.opt` rows — the prototype's picker sheet, used by
/// add-visit and export.
///
/// ```css
/// .sheet-pop{background:var(--surface);border-radius:26px 26px 0 0;
///            border-top:1px solid var(--aline);padding:20px 20px 26px;
///            max-height:82%}
/// .sheet-grab{width:42px;height:5px;border-radius:5px;background:var(--aline)}
/// .opt{gap:13px;padding:13px 12px;border-radius:14px}
/// .opt .oic{width:38px;height:38px;border-radius:11px;background:var(--pri-soft)}
/// .opt .otx{font-size:13.5px;font-weight:700}
/// .opt .ots{font-size:11px;color:var(--asub)}
/// ```
class OptionSheet extends StatelessWidget {
  const OptionSheet({
    super.key,
    required this.title,
    required this.options,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<SheetOption> options;

  /// Returns the chosen option's id, or null if dismissed.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<SheetOption> options,
    String? subtitle,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => OptionSheet(
        title: title,
        subtitle: subtitle,
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      // max-height:82%
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: t.line,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: t.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: TextStyle(color: t.sub, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final o in options) _Row(option: o),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.option});
  final SheetOption option;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final iconBg = option.danger ? t.roseSoft : t.primarySoft;
    final iconFg = option.danger ? t.rose : t.primary;
    final titleColor = option.danger ? t.roseText : t.ink;

    return InkWell(
      onTap: () => Navigator.of(context).pop(option.id),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(option.icon, size: 19, color: iconFg),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      option.subtitle!,
                      style: TextStyle(color: t.sub, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.add_rounded, size: 18, color: t.primary),
          ],
        ),
      ),
    );
  }
}

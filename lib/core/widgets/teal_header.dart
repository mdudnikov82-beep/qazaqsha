import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'ornament.dart';

/// The teal top of a tab screen: ornament band, Kazakh title, Russian
/// subtitle, optional actions and content (a search field…) below.
class TealHeader extends StatelessWidget {
  const TealHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.bottom,
    this.bottomPadding = 24,
    this.color = AppColors.primary,
    this.leading,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget? bottom;

  /// Room under the content, e.g. for a card overlapping the header.
  final double bottomPadding;

  /// Teal by default; a topic screen uses its section's colour.
  final Color color;

  /// E.g. a back button, before the title.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 6,
            child: OrnamentBand(
              color: AppColors.gold.withValues(alpha: 0.22),
              height: 40,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 16, 12, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFCDEFF6),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...actions,
                  ],
                ),
                if (bottom != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: bottom,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

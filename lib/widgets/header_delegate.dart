import 'dart:ui';
import 'package:flutter/cupertino.dart';

class HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget headerWidget;
  final double minHeight;
  final double maxHeight;
  HeaderDelegate({
    required this.headerWidget,
    this.minHeight = 35,
    this.maxHeight = 35,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final backgroundColor = overlapsContent
        ? CupertinoColors.secondarySystemBackground
              .resolveFrom(context)
              .withOpacity(0.85)
        : CupertinoColors.systemBackground.resolveFrom(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          alignment: Alignment.centerLeft,
          color: backgroundColor,
          child: headerWidget,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HeaderDelegate oldDelegate) {
    return oldDelegate.headerWidget != headerWidget;
  }
}

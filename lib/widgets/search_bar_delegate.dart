import 'dart:ui';
import 'package:flutter/cupertino.dart';

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String> onChanged;
  SearchBarDelegate({required this.onChanged});

  @override
  double get minExtent => 55;
  @override
  double get maxExtent => 55;

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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: maxExtent,
          color: backgroundColor,
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            placeholder: "Search",
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) => false;
}

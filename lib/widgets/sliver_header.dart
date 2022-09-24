import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SliverHeaderDelegate({required this.child});

  final Widget child;

  static const appBarMaxHeight = 96.0;
  static const appBarMinHeight = 48.0;

  // height from appBarMaxHeight to appBarMinHeight
  double _computeWidth(double height) {
    return max(0.7, 0.93 - (appBarMaxHeight - height) / 256);
  }

  // height from appBarMaxHeight to appBarMinHeight
  double _computeSigma(double height) {
    return max(0, (appBarMaxHeight - height) / 4.8);
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final height = max(appBarMinHeight, appBarMaxHeight - shrinkOffset);
    final sigma = _computeSigma(height);
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Color.fromRGBO(32, 32, 32, sigma / 10 / 2)),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: sigma, sigmaX: sigma),
              child: const SizedBox(),
            ),
          ),
          FractionallySizedBox(
            widthFactor: _computeWidth(height),
            heightFactor: 0.9,
            child: FittedBox(
              child: child,
            ),
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => appBarMaxHeight;

  @override
  double get minExtent => appBarMinHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

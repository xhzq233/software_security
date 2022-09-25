/// pinpin - ext
/// Created by xhz on 02/08/2022

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:boxy/boxy.dart';

class Pair<L, R> {
  Pair(this.l, this.r);

  L l;
  R r;
}

class CapsuleClipper extends CustomClipper<Path> {
  const CapsuleClipper({Listenable? reclip}) : super(reclip: reclip);

  @override
  Path getClip(Size size) {
    final height = size.height;
    final width = size.width;

    final radius = min(height, width);

    return Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset.zero, Offset(width, height)), Radius.circular(radius)));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

extension Rebuild on BuildContext {
  void rebuild() {
    (this as Element).markNeedsBuild();
  }
}

extension WidgetExtensions on Widget {
  Widget bg([double radius = 12]) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: background(
          const ColoredBox(color: Color(0xff262626)),
        ));
  }

  Widget onTap(void Function() function) => GestureDetector(
        onTap: function,
        child: this,
      );

  Widget centralized() => Center(
        child: this,
      );

  // overlaying a widget whose constraints bigger than the background widget
  Widget overlay(Widget content) => CustomBoxy(
        delegate: AdaptiveOverlayDelegate(),
        children: [
          this,
          content,
        ],
      );

  // place a widget with constraints bigger than the overlay widget to background
  Widget background(Widget content) => CustomBoxy(
        delegate: AdaptiveBackgroundDelegate(),
        children: [
          content,
          this,
        ],
      );

  Widget decorated(BoxDecoration boxDecoration) => DecoratedBox(
        decoration: boxDecoration,
        child: this,
      );

  Widget sized({double? width, double? height}) => SizedBox(
        width: width,
        height: height,
        child: this,
      );

  Widget border({EdgeInsets? margin, EdgeInsets? padding, Color color = Colors.blueAccent}) => Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(border: Border.all(color: color)),
        child: this,
      );

  Widget clipped([BorderRadius? borderRadius]) => ClipRRect(
        borderRadius: borderRadius,
        child: this,
      );

  Widget clip([
    CustomClipper<Path> clipper = const CapsuleClipper(),
  ]) =>
      ClipPath(
        clipper: clipper,
        child: this,
      );

  Widget unconstrained() => UnconstrainedBox(
        child: this,
      );
}

class AdaptiveOverlayDelegate extends BoxyDelegate {
  @override
  Size layout() {
    final overlay = children[1];
    final background = children[0];

    final backgroundSize = background.layout(constraints);
    final overlayConstraints = constraints.copyWith(minHeight: backgroundSize.height, minWidth: backgroundSize.width);
    final overlaySize = overlay.layout(overlayConstraints);

    return Size(max(overlaySize.width, backgroundSize.width), max(overlaySize.height, backgroundSize.height));
  }
}

class AdaptiveBackgroundDelegate extends BoxyDelegate {
  @override
  Size layout() {
    final foreground = children[1];
    final background = children[0];
    final foregroundSize = foreground.layout(constraints);
    final backgroundConstraints =
        constraints.copyWith(minHeight: foregroundSize.height, minWidth: foregroundSize.width);
    final backgroundSize = background.layout(backgroundConstraints);

    return Size(max(foregroundSize.width, backgroundSize.width), max(foregroundSize.height, backgroundSize.height));
  }
}

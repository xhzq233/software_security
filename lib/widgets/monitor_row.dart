import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:software_security/constant.dart';

typedef DismissDirectionCallback = void Function(DismissDirection direction);

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

class MonitorRow extends StatelessWidget {
  const MonitorRow({
    required super.key,
    required this.info,
    required this.onDismissed,
  });

  final String info;
  final DismissDirectionCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final text = Text(info);
    final bg = FittedBox(
      child: ClipPath(
        clipper: const CapsuleClipper(),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.black38, boxShadow: [Constant.shadow]),
          child: text.paddingSymmetric(vertical: 1.1, horizontal: 8),
        ),
      ),
    );
    return SizedBox(
        height: 28,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipPath(
            clipper: const CapsuleClipper(),
            child: Dismissible(
                key: key!,
                onDismissed: onDismissed,
                background: const ClipPath(
                  clipper: CapsuleClipper(),
                  child: ColoredBox(
                    color: Colors.red,
                  ),
                ),
                child: bg),
          ),
        ));
  }
}

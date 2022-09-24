import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:software_security/constant.dart';
import 'package:software_security/ffi/ffi_channel.dart';
import 'package:software_security/widgets/ext.dart';

typedef DismissDirectionCallback = void Function(DismissDirection direction);

const _dismissBg = ClipPath(
  clipper: CapsuleClipper(),
  child: ColoredBox(
    color: Colors.red,
  ),
);

class MonitorRow extends StatelessWidget {
  const MonitorRow({
    required super.key,
    required this.info,
    required this.onDismissed,
  });

  final LocalizedSentData info;
  final DismissDirectionCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpan = [];
    textSpan.add(TextSpan(text: info.msgType.name, style: TextStyle(color: info.hintColor, fontWeight: FontWeight.bold)));

    if (info.restrict) {
      textSpan.add(
        const TextSpan(text: '*', style: TextStyle(color: Color(0xffff3535))),
      );
      textSpan.add(TextSpan(text: info.str, style: const TextStyle(color: Color(0xffff3535))));
    } else {
      textSpan.add(TextSpan(text: info.str));
    }

    final text = Text.rich(TextSpan(children: textSpan));

    final bg = FittedBox(
      child: ClipPath(
        clipper: const CapsuleClipper(),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.black38, boxShadow: [Constant.shadow]),
          child: text.paddingSymmetric(vertical: 1.1, horizontal: 8),
        ),
      ),
    );
    final time = DateTime.fromMillisecondsSinceEpoch(info.time);
    final formatted = '${time.hour}:${time.minute}:${time.second}-${time.millisecond}ms';

    final List<Widget> children = [];
    children.add(bg);
    children.add(FractionallySizedBox(
        heightFactor: 0.6,
        child: FittedBox(
          child: Text(
            formatted,
            style: const TextStyle(color: Constant.on, fontStyle: FontStyle.italic),
          ),
        )));

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );

    return SizedBox(
        height: 28,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipPath(
            clipper: const CapsuleClipper(),
            child: Dismissible(key: key!, onDismissed: onDismissed, background: _dismissBg, child: row),
          ),
        ));
  }
}

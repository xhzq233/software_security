import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:software_security/constant.dart';
import 'package:software_security/ffi/ffi_channel.dart';
import 'package:software_security/file_select.dart';
import 'package:software_security/widgets/charts.dart';
import 'package:software_security/widgets/ext.dart';
import 'package:software_security/widgets/monitor_row.dart';
import 'package:software_security/widgets/sliver_header.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(const SoftwareSecurity());
}

const _duration = Duration(
  milliseconds: 500,
);

const _shortDuration = Duration(
  milliseconds: 200,
);

class SoftwareSecurity extends StatelessWidget {
  const SoftwareSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '猫雷とは何ですか？',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(colorScheme: Constant.darkScheme, textTheme: Constant.textTheme),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final globalKey = GlobalKey<AnimatedListState>();

  final RxBool _chartsRefresher = RxBool(false);

  @override
  void initState() {
    ffi_channel_str_list_notification.listen((l) {
      if (l == LIST_INCREASE) {
        globalKey.currentState!.insertItem(0, duration: _duration);
      } else {}
      _chartsRefresher.toggle();
    });
    super.initState();
  }

  void _rmItem(int index) {
    globalKey.currentState!.removeItem(
        index,
        (context, animation) => ScaleTransition(
              scale: animation,
              child: const ColoredBox(color: Colors.red),
            ));
    ffi_channel_list.removeAt(index);
    channelStreamController.add(LIST_DECREASE);
  }

  void _clear() {
    for (int index = ffi_channel_list.length - 1; index >= 0; index--) {
      _rmItem(index);
    }
  }

  void _stop() {
    filePath.value = '';
    stopLib();
  }

  Widget _itemBuilder(BuildContext context, int i, Animation<double> animation) {
    final index = ffi_channel_list.length - 1 - i;
    final info = ffi_channel_list[index];
    final a = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
    final b = Tween(begin: 0.4, end: 1.0).animate(a);
    final c = CurvedAnimation(parent: animation, curve: Curves.ease);
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        return Transform.scale(
          scale: b.value,
          alignment: const Alignment(-0.5, 0),
          child: Opacity(
            opacity: c.value,
            child: child,
          ),
        );
      },
      child: MonitorRow(
        key: UniqueKey(),
        info: info,
        onDismissed: (DismissDirection direction) {
          _rmItem(index);
        },
      ),
    );
  }

  Widget _settingRow(String title, Ref<int> ref, BuildContext ctx) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          CupertinoSwitch(
              value: ref.val >= HCOpen,
              onChanged: (enable) {
                ref.val = enable ? HCOpen : HCClose;
                ctx.rebuild();
              })
        ],
      ).paddingOnly(left: 11, right: 3.3);

  final configs = [
    Pair('File', hookConfig.file),
    Pair('Heap', hookConfig.heap),
    Pair('Network', hookConfig.net),
    Pair('Memory Copy', hookConfig.memcpy),
    Pair('Register', hookConfig.reg),
  ];

  static Widget _defaultLayoutBuilder(Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Positioned(
          key: bottomChildKey,
          left: 0.0,
          top: 0.0,
          right: 0.0,
          child: bottomChild,
        ),
        Positioned(
          key: topChildKey,
          child: topChild,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashBoard = Builder(
        builder: ((ctx) => FractionallySizedBox(
              widthFactor: 0.76,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Hook Config',
                        style: TextStyle(fontSize: 22),
                      ),
                      const Spacer(),
                      Checkbox(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        value: configs.every((e) => e.r.val == HCRestrict),
                        onChanged: (value) {
                          if (value == false) {
                            for (var element in configs) {
                              element.r.val = HCClose;
                            }
                            hookConfig.msgBox.val = HCClose;
                          } else {
                            for (var element in configs) {
                              element.r.val = HCRestrict;
                            }
                            hookConfig.msgBox.val = HCOpen;
                          }
                          ctx.rebuild();
                        },
                      )
                    ],
                  ).paddingSymmetric(vertical: 8),
                  Builder(builder: (ctx) {
                    return _settingRow('Message Box', hookConfig.msgBox, ctx);
                  }).bg().paddingSymmetric(vertical: 16),
                  ...configs.map((e) => Builder(
                      builder: (ctx) => Column(
                            children: [
                              _settingRow(e.l, e.r, ctx),
                              Visibility(
                                visible: e.r.val != HCClose,
                                child: const Divider(
                                  height: 1.2,
                                ),
                              ),
                              AnimatedCrossFade(
                                crossFadeState:
                                    e.r.val != HCClose ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                duration: _shortDuration,
                                layoutBuilder: _defaultLayoutBuilder,
                                // alignment: e.r.val != HCClose ? Alignment.center : Alignment.topCenter,
                                secondChild: Row(
                                  mainAxisSize: MainAxisSize.max,
                                ),
                                firstChild: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Restrict Check'),
                                    CupertinoSwitch(
                                        value: e.r.val == HCRestrict,
                                        onChanged: (enable) {
                                          e.r.val = enable ? HCRestrict : HCOpen;
                                          ctx.rebuild();
                                        })
                                  ],
                                ).paddingOnly(left: 11, right: 3.3),
                              ),
                            ],
                          )).bg().paddingSymmetric(vertical: 16)),
                ],
              ),
            )));

    final left = NestedScrollView(
      body: SingleChildScrollView(
        child: Obx(
          () => AnimatedCrossFade(
              firstChild: SizedBox(
                height: 377,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Colors.white70),
                      ObxValue<RxBool>((obx) {
                        final _ = obx.value;
                        return DeveloperChart(
                          series: [
                            charts.Series(
                                id: "Counts",
                                displayName: 'Counts',
                                data: MsgType.values,
                                domainFn: (MsgType type, _) => type.name,
                                measureFn: (MsgType type, _) =>
                                    ffi_channel_list.where((element) => element.msgType == type).length,
                                colorFn: (MsgType type, _) => charts.ColorUtil.fromDartColor(type.hintColor))
                          ],
                        );
                      }, _chartsRefresher).paddingAll(8)
                    ],
                  ),
                ).paddingSymmetric(horizontal: 10),
              ),
              secondChild: Center(
                child: dashBoard,
              ),
              crossFadeState: filePath.isNotEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: _duration),
        ),
      ),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(child: Obx(() {
            final path = filePath.value;
            final hint = path.isNotEmpty ? 'Select' : 'Click to Select Executable';
            return Row(
              children: [
                Visibility(visible: path.isNotEmpty, child: Text(path)),
                Visibility(
                  visible: path.isNotEmpty,
                  child: const SizedBox(
                    width: 12,
                  ),
                ),
                OutlinedButton(onPressed: selectFile, child: Text(hint)),
              ],
            );
          })),
        ),
      ],
    );

    final right = Stack(
      fit: StackFit.expand,
      children: [
        AnimatedList(reverse: true, key: globalKey, itemBuilder: _itemBuilder),
        Align(
          alignment: const Alignment(0.9, -0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _clear,
                child: const Text('Clear'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _stop,
                child: const Text('Stop '),
              )
            ],
          ),
        )
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'images/1.jpg',
              fit: BoxFit.cover,
            ),
            const ColoredBox(color: Colors.black38),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: RepaintBoundary(
                        child: left,
                      )),
                  Expanded(
                      flex: 3,
                      child: RepaintBoundary(
                        child: right,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:software_security/constant.dart';
import 'package:software_security/ffi/ffi_channel.dart';
import 'package:software_security/file_select.dart';
import 'package:software_security/widgets/monitor_row.dart';
import 'package:software_security/widgets/sliver_header.dart';

void main() {
  runApp(const SoftwareSecurity());
}

const _duration = Duration(
  milliseconds: 500,
);

class SoftwareSecurity extends StatelessWidget {
  const SoftwareSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '猫雷とは何ですか？',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: Constant.darkScheme,
      ),
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

  @override
  void initState() {
    ffi_channel_str_list_notification.listen((l) {
      if (l == LIST_INCREASE) {
        globalKey.currentState!
            .insertItem(0, duration: const Duration(milliseconds: 800));
      } else {}
    });
    super.initState();
  }

  void _rmItem(int index) {
    globalKey.currentState!.removeItem(
        index, (context, animation) => const ColoredBox(color: Colors.red));
    ffi_channel_str_list.removeAt(index);
  }

  void _clear() {
    for (int index = ffi_channel_str_list.length - 1; index >= 0; index--) {
      _rmItem(index);
    }
  }

  Widget _itemBuilder(
      BuildContext context, int i, Animation<double> animation) {
    final b = CurvedAnimation(parent: animation, curve: Curves.bounceOut);
    final a = CurvedAnimation(parent: b, curve: Curves.easeInOutSine);
    final index = ffi_channel_str_list.length - 1 - i;
    final info = ffi_channel_str_list[index];
    return AnimatedBuilder(
      animation: a,
      builder: (_, child) {
        return FractionalTranslation(
          translation: Offset(1 - a.value, 0),
          child: child,
        );
      },
      child: MonitorRow(
        key: Key(info),
        info: info,
        onDismissed: (DismissDirection direction) {
          _rmItem(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0x00ffffff),
      appBar: AppBar(
        title: Obx(() => AnimatedSwitcher(
              duration: _duration,
              child: Text(
                ffi_channel_str.value,
                key: UniqueKey(),
              ),
            )),
      ),
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
                      child: CustomScrollView(
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverHeaderDelegate(child: Obx(() {
                              final path = filePath.value;
                              final hint = path.isNotEmpty
                                  ? 'Select'
                                  : 'Click to Select Executable';
                              return Row(
                                children: [
                                  Visibility(
                                      visible: path.isNotEmpty,
                                      child: Text(path)),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  OutlinedButton(
                                      onPressed: selectFile, child: Text(hint)),
                                ],
                              );
                            })),
                          ),
                          const Text(Constant.meme).sliverBox
                        ],
                      )),
                  Expanded(
                      child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedList(
                          reverse: true,
                          key: globalKey,
                          itemBuilder: _itemBuilder),
                      Align(
                        alignment: const Alignment(0.9, -0.9),
                        child: ElevatedButton(
                          onPressed: _clear,
                          child: const Text('Clear'),
                        ),
                      )
                    ],
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

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:software_security/ffi/ffi_channel.dart';

void main() {
  initFFIChannel();
  runApp(const SoftwareSecurity());
}

class Constant {
  Constant._();

  static const meme = """我三岁练枪，那一年枪一上手就人枪合一😎
爱不释手，九岁悟出夺命十三枪😤
于九天之上我斩杀花果山妖猴😠
二十岁我熟读天下枪谱，纵横江湖再无敌手😔
我这一生只有一个敌人，那就是我自己😃
我去问佛问跟韩信是否有缘🤔？
佛说， 你跟韩信无缘😭。
我说求缘，佛说，那你便等上千年😢
在那一千年里，你可知韩信🤕
而韩信却不知有你，你可愿等呐😟？
我答，国服韩信，请战😡。
第一枪！长相思兮长相忆，短相思兮无穷极！
相思！😣
第二枪！相思一夜情多少地角天涯未是长！断肠！😫
眼见为虚，心听为实！
第三枪！盲龙！😵
乾坤一速天下游，月如钩，难别求！
第四枪，风流！😍
书香百味有多少，天下何人配白衣
第五枪，无双！😤
相思游龙万兵手，命若黄泉不回头！
第六枪，白龙！😦
有过痛苦，方知众生痛苦，有过牵挂，了无牵挂！若是修佛先修心，一枪风雪一枪冰
第七枪！忘川！😨
翻云起雾藏杀意，横扫千军几万里
第八枪！鲲鹏！🤭
终是韩信断了枪，也徒留我一人伤，即使这样，那就是
第九枪！
百鬼夜行！👻
天地无情恨多少，夜里哭声泣不长
冤魂不怨为天意，长枪出，君王泣
第十枪！寻仇！👹
上见君王不低头，三军将士长叩首
第十一枪，拜将封侯！🤴
你说此生不负良人，千里共婵娟，怎奈人去楼空似烟云，白发青丝一瞬间，今世轮回为少年，爱过之后知情浓，佳人走，发不留！
第十二枪，抬头！🤯
百万将士在摇旗，将军韩信战无敌
第十三枪，我命由我不由天😡""";
}

class SoftwareSecurity extends StatelessWidget {
  const SoftwareSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetCupertinoApp(
      title: '猫雷とは何ですか？',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: Color.fromRGBO(101, 212, 110, 1),
        brightness: Brightness.dark,
        primaryContrastingColor: Color.fromRGBO(64, 64, 64, 1),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg =
        Image.network('https://img.moegirl.org.cn/common/1/12/Nyaru_hello.png');

    return Material(
      child: Stack(
        children: [
          bg,
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: CupertinoPageScaffold(
              backgroundColor: const Color(0x00ffffff),
              navigationBar: CupertinoNavigationBar(
                middle: Obx(() => AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 300,
                      ),
                      child: Text(
                        ffi_channel_str.value,
                        key: UniqueKey(),
                      ),
                    )),
                trailing: CupertinoButton(
                  onPressed: () {},
                  child: const Icon(CupertinoIcons.add),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                        child: CustomScrollView(
                      slivers: [
                        const SliverPersistentHeader(
                          pinned: true,
                          delegate: PinPinHomeSliverHeaderDelegate(),
                        ),
                        const Text(Constant.meme).sliverBox
                      ],
                    )),
                    Expanded(
                        child: Obx(() => ListView.builder(
                              itemCount: ffi_channel_str_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(ffi_channel_str_list[index]),
                                );
                              },
                            ))),
                  ],
                ).paddingAll(4),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PinPinHomeSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  const PinPinHomeSliverHeaderDelegate();

  static const appBarMaxHeight = 72.0;
  static const appBarMinHeight = 48.0;

  // height from appBarMaxHeight to appBarMinHeight
  double _computeOpacity(double height) {
    return max(0.0, 1.0 - (appBarMaxHeight - height) / 24);
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    const title = Text('文件路径: C://Users/XHZ/wcnm.exe');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        // 1 -> 0
        return SizedBox(
          height: height,
          width: width,
          child: Opacity(
            opacity: _computeOpacity(height),
            child: const FittedBox(
              child: title,
            ),
          ),
        );
      },
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

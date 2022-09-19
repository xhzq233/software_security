import 'package:flutter/material.dart';

class Constant {
  Constant._();

  static const shadow = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 10,
    color: Color.fromRGBO(255, 255, 255, 0.04),
  );

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
  static const grey = Color.fromRGBO(48, 48, 48, 1);
  static const on = Color.fromRGBO(200, 200, 200, 1);
  static const primary = Color.fromRGBO(101, 212, 110, 1);

  static const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.black,
      secondary: grey,
      onSecondary: on,
      error: Colors.red,
      onError: Colors.white,
      background: Colors.black,
      onBackground: on,
      surface: Colors.black,
      onSurface: on);

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    displayMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    displaySmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    headlineLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    headlineMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    headlineSmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    titleLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    titleMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    titleSmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    bodyLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    bodyMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    bodySmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    labelLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    labelMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    labelSmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
  );
}

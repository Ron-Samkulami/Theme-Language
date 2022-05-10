import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:change_theme_language/config/storage_manager.dart';
import 'package:change_theme_language/generated/l10n.dart';

class ThemeModel with ChangeNotifier {
  ///主题颜色 key值
  static const kThemeColorIndex = 'kThemeColorIndex';
  ///暗黑模式 key值
  static const kThemeUserDarkMode = 'kThemeUserDarkMode';
  ///字体 key值
  static const kFontIndex = 'kFontIndex';
  ///字体种类
  static const fontValueList = ['system', 'kuaile'];

  /// 用户选择的明暗模式
  late bool _userDarkMode;
  /// 当前主题颜色
  late MaterialColor _themeColor;
  /// 当前字体索引
  late int _fontIndex;

  ThemeModel() {
    /// 用户选择的明暗模式
    _userDarkMode =
        StorageManager.sharedPreferences.getBool(kThemeUserDarkMode) ?? false;
    /// 获取主题色
    _themeColor = Colors.primaries[
        StorageManager.sharedPreferences.getInt(kThemeColorIndex) ?? 5];
    /// 获取字体
    _fontIndex = StorageManager.sharedPreferences.getInt(kFontIndex) ?? 0;
  }

  int get fontIndex => _fontIndex;

  /// 切换指定色彩主题
  ///
  /// 没有传[brightness]就不改变brightness,color同理
  void switchTheme({bool? userDarkMode, MaterialColor? color}) {
    _userDarkMode = userDarkMode ?? _userDarkMode;
    _themeColor = color ?? _themeColor;
    notifyListeners();
    saveTheme2Storage(_userDarkMode, _themeColor);
  }

  /// 切换到随机主题
  /// 可以指定明暗模式,不指定则保持不变
  void switchRandomTheme({Brightness? brightness}) {
    int colorIndex = Random().nextInt(Colors.primaries.length - 1);
    switchTheme(
      userDarkMode: Random().nextBool(),
      color: Colors.primaries[colorIndex],
    );
  }

  /// 切换字体
  void switchFont(int index) {
    _fontIndex = index;
    switchTheme(userDarkMode:_userDarkMode,color:_themeColor);
    saveFontIndex(index);
  }

  /// 根据主题 明暗 和 颜色 生成对应的主题
  /// [dark]系统的Dark Mode
  ThemeData themeData({bool platformDarkMode = false}) {
    var isDark = platformDarkMode || _userDarkMode;
    Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    var themeColor = _themeColor;
    var accentColor = isDark ? themeColor[700] : _themeColor;
    if (kDebugMode) {
      print('切换主题颜色为：$themeColor');
      print('$accentColor');
    }
    var themeData = ThemeData(
        brightness: brightness,
        primarySwatch: themeColor,
        fontFamily: fontValueList[fontIndex],
    );


    themeData = themeData.copyWith(
      brightness: brightness,
      primaryColor: accentColor,

      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: accentColor,
      ),

      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      toggleableActiveColor: accentColor,
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor?.withOpacity(0.1),
      ),
    );

    return themeData;
  }

  /// 数据持久化到shared preferences
  saveTheme2Storage(bool userDarkMode, MaterialColor themeColor) async {
    var index = Colors.primaries.indexOf(themeColor);
    await Future.wait([
      StorageManager.sharedPreferences
          .setBool(kThemeUserDarkMode, userDarkMode),
      StorageManager.sharedPreferences.setInt(kThemeColorIndex, index)
    ]);
  }

  /// 根据索引获取字体名称,这里牵涉到国际化
  static String fontName(index, context) {
    switch (index) {
      case 0:
        return S.of(context).autoBySystem;
      case 1:
        return S.of(context).fontKuaiLe;
      default:
        return '';
    }
  }

  /// 字体选择持久化
  static saveFontIndex(int index) async {
    await StorageManager.sharedPreferences.setInt(kFontIndex, index);
  }
}

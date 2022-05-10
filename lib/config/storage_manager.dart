import 'dart:io';

import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class StorageManager {

  /// app全局配置 eg:theme
  static late SharedPreferences sharedPreferences;
  /// 临时目录 eg: cookie
  static late Directory temporaryDirectory;
  /// 初始化必备操作 eg:user数据
  static late LocalStorage localStorage;

  static init() async {
    temporaryDirectory = await getTemporaryDirectory();
    sharedPreferences = await SharedPreferences.getInstance();
    localStorage = LocalStorage('LocalStorage');
    await localStorage.ready;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:change_theme_language/config/storage_manager.dart';
import 'package:change_theme_language/home.dart';
import 'package:change_theme_language/provider/locale_model.dart';
import 'package:change_theme_language/provider/theme_model.dart';
import 'package:change_theme_language/generated/l10n.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  runApp(const MyApp());

  // Android状态栏透明 splash为白色,所以调整状态栏文字为黑色
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider(create:(_) => ThemeModel(),),//主题 provider
          ChangeNotifierProvider.value(value: LocaleModel()),//本地语种 provider
        ],
        child: Consumer2<ThemeModel, LocaleModel>(
          builder:
              (BuildContext context, themeModel, localeModel, Widget? child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeModel.themeData(),
              //设置了darkTheme时，会自动监听系统是否开启暗黑模式
              darkTheme: themeModel.themeData(platformDarkMode: true),
              locale: localeModel.locale,
              localizationsDelegates: const [
                S.delegate,//支持语种对应的字段
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: S.delegate.supportedLocales, //支持的语种
              //路由自行配置 flutter自带 或者 fluro
              onGenerateRoute: null,
              home: const Home(),
            );
          },
        ),
      ),
    );
  }
}

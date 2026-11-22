import 'package:material_ui/material_ui.dart';
import 'package:depart/themes/themes.dart';
import 'package:flutter/foundation.dart';

class ParentCustomTheme extends InheritedWidget {
  final CustomThemeState? data;

  const ParentCustomTheme({
    this.data,
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ParentCustomTheme oldWidget) {
    return true;
  }
}

class CustomTheme extends StatefulWidget {
  final Widget child;
  final MyThemeKeys? initialThemeKey;

  const CustomTheme({
    Key? key,
    this.initialThemeKey,
    required this.child,
  }) : super(key: key);

  @override
  CustomThemeState createState() => CustomThemeState();

  static ThemeData? of(BuildContext context) {
    ParentCustomTheme inherited =
        context.dependOnInheritedWidgetOfExactType<ParentCustomTheme>()!;
    return inherited.data!.theme;
  }

  static CustomThemeState? instanceOf(BuildContext context) {
    ParentCustomTheme inherited =
        context.dependOnInheritedWidgetOfExactType<ParentCustomTheme>()!;
    return inherited.data;
  }
}

class CustomThemeState extends State<CustomTheme> {
  ThemeData? _theme;

  ThemeData? get theme => _theme;

  @override
  void initState() {
    _theme = MyThemes.getThemeFromKey(widget.initialThemeKey);
    super.initState();
  }

  void changeTheme(MyThemeKeys themeKey) {
    setState(() {
      _theme = MyThemes.getThemeFromKey(themeKey);
      if (kDebugMode) {
        print("changing theme to $themeKey");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParentCustomTheme(
      data: this,
      child: widget.child,
    );
  }
}

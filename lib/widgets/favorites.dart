import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/foundation.dart';

import 'package:depart/data/data.dart';
import 'package:depart/data/models.dart';
import 'package:depart/themes/dynamic_themes.dart';
import 'package:depart/themes/themes.dart';

class VersionTile extends StatefulWidget {
  const VersionTile({Key? key}) : super(key: key);

  @override
  VersionTileState createState() => VersionTileState();
}

class VersionTileState extends State<VersionTile> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String appName, String appVersion) {
    return ListTile(
      title: Text(title),
      subtitle: Row(
        children: [
          Text(appName.isNotEmpty ? appName : 'Not set'),
          Container(width: 19),
          Text(appVersion.isNotEmpty ? appVersion : 'Not set'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _infoTile(_packageInfo.appName, 'Version :', _packageInfo.version),
          ]),
    );
  }
}

void showFavoritesDialog(
    BuildContext context, StreamController<dynamic> animationCardNotifier) {
  const String favoriteTitle = 'Trajets Favoris';
  showDialog(
      context: context,
      builder: (context) {
        final notifierJourney =
            Provider.of<JourneyNotifier>(context, listen: false);

        return SimpleDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(favoriteTitle),
          children: <Widget>[
            buildOptionTrajetFavoriEnregistre(
              context,
              notifierJourney,
            ),
            buildOptionTrajeFavoriCharge(
              context,
              animationCardNotifier,
            ),
            buildOptionColor(
              context,
              MyThemeKeys.pink,
              MyThemes.pinkTheme as ThemeData,
              "Pink",
            ),
            buildOptionColor(
              context,
              MyThemeKeys.green,
              MyThemes.greenTheme as ThemeData,
              "Green",
            ),
            buildOptionColor(
              context,
              MyThemeKeys.blue,
              MyThemes.blueTheme as ThemeData,
              "Blue",
            ),
            const VersionTile(),
          ],
        );
      });
}

SimpleDialogOption buildOptionColor(
  BuildContext context,
  MyThemeKeys themeKey,
  ThemeData theme,
  String colorString,
) {
  const String themeCharge = 'Nouveau thème appliqué et enregistré !';
  return SimpleDialogOption(
    onPressed: () {
      changeTheme(context, themeKey);
      favoriteSnackbar(context, themeCharge, theme: theme);
      Navigator.pop(context);
    },
    child: ChangeTheme(
      colorString: colorString,
    ),
  );
}

SimpleDialogOption buildOptionTrajeFavoriCharge(
  BuildContext context,
  StreamController animationCardNotifier,
) {
  const String trajetFavoriCharge = 'Destinations favorites chargées';
  const String chargerTrajetFavori = "Charger le trajet favori";
  return SimpleDialogOption(
      onPressed: () {
        loadFavoritesDestination(context, animationCardNotifier);
        favoriteSnackbar(context, trajetFavoriCharge);
        Navigator.pop(context);
      },
      child: const RowDialog(
          text: chargerTrajetFavori, icon: Icons.open_in_browser));
}

Visibility buildOptionTrajetFavoriEnregistre(
  BuildContext context,
  JourneyNotifier notifierJourney,
) {
  const String enregistrerTrajetFavori = 'Enregistrer le trajet favori';
  const String trajetFavoriEnregistre = 'Destinations favorites enregistrées';
  return Visibility(
    visible:
        notifierJourney.departure != null && notifierJourney.arrival != null,
    child: SimpleDialogOption(
      onPressed: () {
        saveDestinations(context);
        favoriteSnackbar(context, trajetFavoriEnregistre);
        Navigator.pop(context);
      },
      child:
          const RowDialog(text: enregistrerTrajetFavori, icon: Icons.save_alt),
    ),
  );
}

class RowDialog extends StatelessWidget {
  const RowDialog({Key? key, this.text, this.icon}) : super(key: key);
  final String? text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(icon),
        const Padding(
          padding: EdgeInsets.all(12),
        ),
        Text(text!),
      ],
    );
  }
}

class ChangeTheme extends StatelessWidget {
  final String colorString;
  const ChangeTheme({
    Key? key,
    required this.colorString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color themeColor = getThemeColor();
    return buildRowChangeTheme(themeColor);
  }

  Color getThemeColor() {
    if (colorString == "Blue") {
      return MyThemes.blueTheme.primaryColor;
    } else if (colorString == "Green") {
      return MyThemes.greenTheme.primaryColor;
    } else {
      return MyThemes.pinkTheme.primaryColor;
    }
  }

  Row buildRowChangeTheme(Color themeColor) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            color: themeColor,
          ),
        ),
        const Padding(padding: EdgeInsets.all(12)),
        Text(colorString),
      ],
    );
  }
}

changeTheme(BuildContext context, MyThemeKeys myThemeKey) {
  CustomTheme.instanceOf(context)!.changeTheme(myThemeKey);
  if (kDebugMode) {
    print(myThemeKey);
  }
  saveTheme(context, myThemeKey);
}

void saveTheme(BuildContext context, MyThemeKeys myThemeKey) async {
  if (kDebugMode) {
    print("AppBar: favorites, save theme");
  }
  final prefs = await SharedPreferences.getInstance();
  String themeString = setThemeString(myThemeKey);
  prefs.setString('myThemeKey', themeString);
}

Future<String> readTheme() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('myThemeKey') ?? "pink";
}

String setThemeString(MyThemeKeys myThemeKey) {
  if (myThemeKey == MyThemeKeys.green) {
    return "GREEN";
  } else if (myThemeKey == MyThemeKeys.blue) {
    return "BLUE";
  } else {
    return "PINK";
  }
}

void favoriteSnackbar(BuildContext context, String text, {ThemeData? theme}) {
  Color backgroundColor =
      (theme == null) ? Theme.of(context).hoverColor : theme.hoverColor;
  Color primaryColor =
      (theme == null) ? Theme.of(context).primaryColor : theme.primaryColor;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: backgroundColor,
    content: Text(text, style: TextStyle(color: primaryColor)),
  ));
}

String getNameOrEmpty(Station? station) {
  if (station != null) {
    return station.name!;
  } else {
    return "";
  }
}

String getIdOrEmpty(Station? station) {
  if (station != null) {
    return station.id!;
  } else {
    return "";
  }
}

void saveDestinations(BuildContext context) async {
  if (kDebugMode) {
    print("AppBar: favorites save destination");
  }
  // obtain shared preferences
  final notifierJourney = Provider.of<JourneyNotifier>(context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  String departureName = getNameOrEmpty(notifierJourney.departure);
  String arrivalName = getNameOrEmpty(notifierJourney.arrival);
  String departureID = getIdOrEmpty(notifierJourney.departure);
  String arrivalID = getIdOrEmpty(notifierJourney.arrival);

  prefs.setString('departure.name', departureName);
  prefs.setString('arrival.name', arrivalName);
  prefs.setString('departure.id', departureID);
  prefs.setString('arrival.id', arrivalID);
  if (kDebugMode) {
    print("ButtonFavorite saved favorites");
  }
}

void loadTheme(
  BuildContext context,
) async {
  final prefs = await SharedPreferences.getInstance();

  String? myThemeString = prefs.getString("myThemeKey");
  if (kDebugMode) {
    print("loadTheme : pref MyThemeKey : $myThemeString");
  }
  MyThemeKeys myThemeKey = setMyThemeKey(myThemeString);
  if (!context.mounted) return;
  changeTheme(context, myThemeKey);
}

MyThemeKeys setMyThemeKey(String? myThemeString) {
  MyThemeKeys myThemeKey;
  if (myThemeString == "GREEN") {
    myThemeKey = MyThemeKeys.green;
  } else if (myThemeString == "BLUE") {
    myThemeKey = MyThemeKeys.blue;
  } else {
    myThemeKey = MyThemeKeys.pink;
  }
  return myThemeKey;
}

void loadFavoritesDestination(BuildContext context,
    StreamController<dynamic> animationCardNotifier) async {
  final prefs = await SharedPreferences.getInstance();
  if (!context.mounted) return;
  final notifierJourney = Provider.of<JourneyNotifier>(context, listen: false);
  final notifierDT = Provider.of<DateTimeNotifier>(context, listen: false);
  final notifierState = Provider.of<AppStateNotifier>(context, listen: false);

  String? departureName = prefs.getString('departure.name');
  String? departureID = prefs.getString('departure.id');
  String? arrivalName = prefs.getString('arrival.name');
  String? arrivalID = prefs.getString('arrival.id');

  if (isLoadPrefsComplete(departureName, arrivalName, departureID, arrivalID)) {
    executeLoadPrefs(
      departureID,
      departureName,
      arrivalID,
      arrivalName,
      notifierJourney,
      animationCardNotifier,
      notifierDT,
      notifierState,
    );
  }
}

void executeLoadPrefs(
    String? departureID,
    String? departureName,
    String? arrivalID,
    String? arrivalName,
    JourneyNotifier notifierJourney,
    StreamController animationCardNotifier,
    DateTimeNotifier notifierDT,
    AppStateNotifier notifierState) {
  Station departureStationPref = Station(
    id: departureID,
    name: departureName,
  );
  Station arrivalStationPref = Station(id: arrivalID, name: arrivalName);
  if (kDebugMode) {
    print("loaded from prefs : departureName $departureName");
    print("loaded from prefs : departureID $departureID");
    print("loaded from prefs : arrivalName $arrivalName");
    print("loaded from prefs : arrivalID $arrivalID");
  }
  notifierJourney.departure = departureStationPref;
  notifierJourney.arrival = arrivalStationPref;
  animationCardNotifier.sink.add(null);
  fetchJourneyWithCurrentSettings(notifierJourney, notifierDT, notifierState);
}

bool isLoadPrefsComplete(String? departureName, String? arrivalName,
    String? departureID, String? arrivalID) {
  return departureName != '' &&
      arrivalName != '' &&
      departureID != '' &&
      arrivalID != '';
}

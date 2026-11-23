import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:depart/themes/themes.dart';
import 'package:depart/utils.dart';
import 'package:depart/data/data.dart';
import 'package:depart/data/models.dart';
import 'package:depart/widgets/favorites.dart';
import 'package:depart/widgets/search.dart';
import 'package:depart/widgets/followed.dart';

class BarWithBackground extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;
  const BarWithBackground(this.animationCardNotifier, {super.key});
  @override
  Widget build(BuildContext context) {
    String switchBackgroundImage(Color color) {
      return pickThemeColor(color);
    }

    final Color backgroundColor = Theme.of(context).primaryColor;
    final String backgroundImage = switchBackgroundImage(backgroundColor);

    return TopBar(
      animationCardNotifier: animationCardNotifier,
      backgroundImage: backgroundImage,
    );
  }

  String pickThemeColor(Color color) {
    if (color == MyThemes.greenTheme.primaryColor) {
      return MyThemes.greenImage;
    } else if (color == MyThemes.blueTheme.primaryColor) {
      return MyThemes.blueImage;
    } else {
      return MyThemes.pinkImage;
    }
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    Key? key,
    required this.animationCardNotifier,
    required String backgroundImage,
  }) : _backgroundImage = backgroundImage,
       super(key: key);

  final StreamController animationCardNotifier;
  final String _backgroundImage;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: ButtonTitle(animationCardNotifier),
      elevation: 100.0,
      actions: [
        ButtonFollowedTrains(key, animationCardNotifier),
        ButtonSearchTrain(animationCardNotifier),
        ButtonFavorite(animationCardNotifier: animationCardNotifier),
      ],
      flexibleSpace: SizedBox(
        height: 187.20,
        width: 2000,
        child: Image(image: AssetImage(_backgroundImage), fit: BoxFit.cover),
      ),
    );
  }
}

// class ButtonFollowedTrains extends StatelessWidget {
//   final StreamController<dynamic> animationCardNotifier;

//   ButtonFollowedTrains(this.animationCardNotifier, {super.key});
//   final prefs = SharedPreferences.getInstance();
//   @override
//   Widget build(BuildContext context) {
//     var bla = await prefs.getStringList("followedJourney");
//     return Visibility(
//       visible: bla != null && !bla.isNotEmpty,
//       child: InkWell(
//           onTap: () {
//             print("pressed follow");
//             showFollowedJourney(context, animationCardNotifier);
//           },
//           onLongPress: () {
//             print("clear shared prefs");
//             clearSharedPrefs();
//           },
//           child: Ink(
//             child: const Icon(Icons.follow_the_signs, size: 30),
//           )),
//     );
//   }
// }

class ButtonFollowedTrains extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;

  const ButtonFollowedTrains(Key? key, this.animationCardNotifier)
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    final notifierFollow = Provider.of<FollowNotifier>(context, listen: true);

    SharedPreferences.getInstance().then((prefs) {
      final followedJourneys = prefs.getStringList("followedJourney");
      if (kDebugMode) {
        print("followed journeys:\n $followedJourneys");
      }
      if (followedJourneys != null && followedJourneys.isNotEmpty) {
        notifierFollow.setHasFollowedJourney();
      }
    });

    return Visibility(
      visible: notifierFollow.getHasFollowedJourneys,
      child: InkWell(
        onTap: () {
          if (kDebugMode) {
            print("pressed follow");
          }
          showFollowedJourney(context, animationCardNotifier);
        },
        onLongPress: () {
          if (kDebugMode) {
            print("clear shared prefs");
          }
          clearSharedPrefs();
        },
        child: Ink(child: const Icon(Icons.follow_the_signs, size: 30)),
      ),
    );
  }
}

class ScaleUpButton extends StatefulWidget {
  final Widget child;
  final Function onPressed;
  final double scaleUp;

  const ScaleUpButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.scaleUp = 1.2,
  });

  @override
  ScaleUpButtonState createState() => ScaleUpButtonState();
}

class ScaleUpButtonState extends State<ScaleUpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          _controller.reverse();
        });
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: widget.scaleUp,
        ).animate(_controller),
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.blue,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
          ),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ButtonSearchTrain extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;
  const ButtonSearchTrain(this.animationCardNotifier, {super.key});
  @override
  Widget build(BuildContext context) {
    final JourneyNotifier notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    final AppStateNotifier notifierState = Provider.of<AppStateNotifier>(
      context,
    );
    final DateTimeNotifier notifierDT = Provider.of<DateTimeNotifier>(
      context,
      listen: false,
    );
    return buildIconButtonSearchTrain(
      notifierJourney,
      context,
      notifierDT,
      notifierState,
    );
  }

  IconButton buildIconButtonSearchTrain(
    JourneyNotifier notifierJourney,
    BuildContext context,
    DateTimeNotifier notifierDT,
    AppStateNotifier notifierState,
  ) {
    return IconButton(
      onPressed: () {
        if (notifierJourney.journeys != null) {
          notifierJourney.fetchJourneysFromUrl("curr", context);
        } else {
          fetchJourneyWithCurrentSettings(
            notifierJourney,
            notifierDT,
            notifierState,
          );
        }
        animationCardNotifier.sink.add(null);
      },
      icon: const Icon(Icons.train, size: 30),
    );
  }
}

class ButtonFavorite extends StatelessWidget {
  const ButtonFavorite({Key? key, required this.animationCardNotifier})
    : super(key: key);

  final StreamController animationCardNotifier;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(Icons.favorite, size: 30),
          onPressed: () {
            showFavoritesDialog(context, animationCardNotifier);
          },
        );
      },
    );
  }
}

class ButtonTitle extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;
  final double size;
  const ButtonTitle(this.animationCardNotifier, {this.size = 50, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    final notifierDT = Provider.of<DateTimeNotifier>(context, listen: false);
    final notifierState = Provider.of<AppStateNotifier>(context);
    return buildTextButtonMainTitle(
      notifierJourney,
      context,
      notifierDT,
      notifierState,
    );
  }

  TextButton buildTextButtonMainTitle(
    JourneyNotifier notifierJourney,
    BuildContext context,
    DateTimeNotifier notifierDT,
    AppStateNotifier notifierState,
  ) {
    return TextButton(
      onPressed: () {
        if (notifierJourney.journeys != null) {
          notifierJourney.fetchJourneysFromUrl("curr", context);
        } else {
          fetchJourneyWithCurrentSettings(
            notifierJourney,
            notifierDT,
            notifierState,
          );
        }
        animationCardNotifier.sink.add(null);
      },
      child: const Text("Départ", style: styleTextWhiteBig),
    );
  }
}

class Origin extends StatefulWidget {
  const Origin({super.key});

  @override
  OriginState createState() => OriginState();
}

class OriginState extends State<Origin> {
  String? originNamePrefs = "Départ";
  String? originIdPrefs = "";
  Station? originStationPref;

  @override
  void initState() {
    super.initState();
    _loadOrigin();
  }

  String? getOriginNamePrefs(SharedPreferences prefs) {
    if (prefs.getString('departure.name') == null) {
      originNamePrefs = "Départ";
    } else {
      originNamePrefs = prefs.getString('departure.name');
    }
    return originNamePrefs;
  }

  void _loadOrigin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);

    setState(() {
      originNamePrefs = getOriginNamePrefs(prefs);
      originIdPrefs = prefs.getString('departure.id');
      if (originIdPrefs != null) {
        originStationPref = Station(id: originIdPrefs, name: originNamePrefs);
        notifier.departure = originStationPref;
      }
      if (kDebugMode) {
        print("Origin _ state loadOrigin : $originNamePrefs");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: true);
    String? originString;
    originString = notifier.departure != null
        ? notifier.departure!.name
        : originNamePrefs;
    originString = (originString == null) ? "Depuis" : originString;
    context.watch<JourneyNotifier>();
    return Material(
      color: Theme.of(context).primaryColor,
      child: InkWell(
        child: OriginText(originString: originString),
        onTap: () {
          if (kDebugMode) {
            print("Origin");
          }
          notifier.searchType = SearchType.origin;
          showPlacesSearch(context).then((place) {
            notifier.departure = place;
            notifier.fetchJourneys(
              searchDateTime: '',
              requestType: "departure",
            );
          });
        },
      ),
    );
  }
}

class OriginText extends StatelessWidget {
  const OriginText({Key? key, required this.originString}) : super(key: key);

  final String? originString;

  @override
  Widget build(BuildContext context) {
    return EmbossedText(
      originString!,
      height: null,
      width: double.infinity,
      padTop: 20,
      padLeft: 20,
      padRight: 20,
    );
  }
}

class Destination extends StatefulWidget {
  const Destination({super.key});

  @override
  DestinationState createState() => DestinationState();
}

class DestinationState extends State<Destination> {
  String? arrivalNamePrefs = "Vers";
  String? arrivalIdPrefs = "";
  Station? arrivalStationPref;
  @override
  void initState() {
    super.initState();
    _loadDestination();
  }

  void _loadDestination() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    final notifierDT = Provider.of<DateTimeNotifier>(context, listen: false);
    final notifierState = Provider.of<AppStateNotifier>(context, listen: false);
    setState(() {
      arrivalNamePrefs = (prefs.getString('arrival.name') != null)
          ? prefs.getString('arrival.name')
          : "Vers";

      arrivalIdPrefs = prefs.getString('arrival.id');

      if (arrivalIdPrefs != null) {
        arrivalStationPref = Station(
          id: arrivalIdPrefs,
          name: arrivalNamePrefs,
        );
        notifierJourney.arrival = arrivalStationPref;
      }
      if (prefs.getString('arrival.name') != null) {
        if (kDebugMode) {
          print("departure _ state loadDestination : $arrivalNamePrefs");
        }
        fetchJourneyWithCurrentSettings(
          notifierJourney,
          notifierDT,
          notifierState,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: true);
    String? arrivalString;
    arrivalString = (notifier.arrival != null)
        ? notifier.arrival!.name
        : arrivalNamePrefs;
    arrivalString = (arrivalString == null) ? "Vers" : arrivalString;
    context.watch<JourneyNotifier>();
    return Material(
      color: Theme.of(context).primaryColor,
      child: InkWell(
        child: ArrivalText(arrivalString: arrivalString),
        onTap: () {
          arrivalOnTap(notifier, context);
        },
      ),
    );
  }

  void arrivalOnTap(JourneyNotifier notifier, BuildContext context) {
    if (kDebugMode) {
      print("Destination");
    }
    notifier.searchType = SearchType.destination;
    showPlacesSearch(context).then((place) {
      notifier.arrival = place;
      notifier.fetchJourneys(searchDateTime: '', requestType: "arrival");
    });
  }
}

class ArrivalText extends StatelessWidget {
  const ArrivalText({Key? key, required this.arrivalString}) : super(key: key);

  final String? arrivalString;

  @override
  Widget build(BuildContext context) {
    return EmbossedText(
      arrivalString!,
      height: null,
      width: double.infinity,
      padLeft: 20,
      padRight: 20,
    );
  }
}

class EmbossedText extends StatelessWidget {
  const EmbossedText(
    this.text, {
    super.key,
    this.padBottom = 20,
    this.padTop = 0,
    this.padLeft = 20,
    this.padRight = 20,
    this.height = 60,
    this.width = 170.0,
    this.color = Colors.white,
  });
  final String text;
  final double padTop;
  final double padBottom;
  final double padLeft;
  final double padRight;
  final double? height;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: padLeft,
        right: padRight,
        bottom: padBottom,
        top: padTop,
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: MaterialPadText(text: text, color: color),
      ),
    );
  }
}

class MaterialPadText extends StatelessWidget {
  const MaterialPadText({Key? key, required this.text, required this.color})
    : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      color: Theme.of(context).primaryColor,
      child: PadText(text: text, color: color),
    );
  }
}

class PadText extends StatelessWidget {
  const PadText({Key? key, required this.text, required this.color})
    : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}

class ThirdRow extends StatelessWidget {
  final List<Widget> widgets;
  const ThirdRow(this.widgets, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: SizedBox(
        width: double.infinity,
        child: MaterialPadButtonsRow(widgets: widgets),
      ),
    );
  }
}

class MaterialPadButtonsRow extends StatelessWidget {
  const MaterialPadButtonsRow({Key? key, required this.widgets})
    : super(key: key);

  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      color: Theme.of(context).primaryColor,
      child: PaddButtonsRow(widgets: widgets),
    );
  }
}

class PaddButtonsRow extends StatelessWidget {
  const PaddButtonsRow({Key? key, required this.widgets}) : super(key: key);

  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widgets,
      ),
    );
  }
}

class SwitchArrivalDeparture extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;
  const SwitchArrivalDeparture(this.animationCardNotifier, {super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(
      builder: (context, notifierState, _) => Consumer<DateTimeNotifier>(
        builder: (context, notifierDT, _) => IconButton(
          icon: const Icon(Icons.compare_arrows),
          onPressed: () {
            onPressSwitchArrivalDeparture(context, notifierDT, notifierState);
          },
        ),
      ),
    );
  }

  void onPressSwitchArrivalDeparture(
    BuildContext context,
    DateTimeNotifier notifierDT,
    AppStateNotifier notifierState,
  ) {
    final notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    Station? dep = notifierJourney.departure;
    notifierJourney.departure = notifierJourney.arrival;
    notifierJourney.arrival = dep;
    fetchJourneyWithCurrentSettings(notifierJourney, notifierDT, notifierState);
    animationCardNotifier.sink.add(null);
  }
}

class SearchTypeSwitcher extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;
  const SearchTypeSwitcher(this.animationCardNotifier, {super.key});
  @override
  Widget build(BuildContext context) {
    final notifierState = Provider.of<AppStateNotifier>(context);
    final notifierDT = Provider.of<DateTimeNotifier>(context, listen: false);
    final notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    const String partirApres = "Partir après";
    const String arriverAvant = "Arriver avant";
    bool status = notifierState.getSearchDeparture;
    bool visible = notifierDT.arrivalTime != null;
    List<Color> colorsPartirArriver = setColorsPartirArriver(status);
    Color colorPartir = colorsPartirArriver[0];
    Color colorArriver = colorsPartirArriver[1];

    return VisibilitySearchTypeSwitcher(
      visible: visible,
      partirApres: partirApres,
      colorPartir: colorPartir,
      arriverAvant: arriverAvant,
      colorArriver: colorArriver,
      animationCardNotifier: animationCardNotifier,
      notifierState: notifierState,
      notifierJourney: notifierJourney,
      notifierDT: notifierDT,
    );
  }

  List<Color> setColorsPartirArriver(bool status) {
    Color colorPartir = Colors.white;
    Color colorArriver = Colors.white54;
    if (status) {
      colorPartir = Colors.white;
      colorArriver = Colors.white54;
    } else {
      colorPartir = Colors.white54;
      colorArriver = Colors.white;
    }
    return [colorPartir, colorArriver];
  }
}

class VisibilitySearchTypeSwitcher extends StatelessWidget {
  const VisibilitySearchTypeSwitcher({
    Key? key,
    required this.visible,
    required this.partirApres,
    required this.colorPartir,
    required this.arriverAvant,
    required this.colorArriver,
    required this.animationCardNotifier,
    required this.notifierState,
    required this.notifierJourney,
    required this.notifierDT,
  }) : super(key: key);

  final bool visible;
  final String partirApres;
  final Color colorPartir;
  final String arriverAvant;
  final Color colorArriver;
  final StreamController animationCardNotifier;
  final AppStateNotifier notifierState;
  final JourneyNotifier notifierJourney;
  final DateTimeNotifier notifierDT;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: InkWell(
        child: PaddingColumnPartirArriverAvantApres(
          partirApres: partirApres,
          colorPartir: colorPartir,
          arriverAvant: arriverAvant,
          colorArriver: colorArriver,
        ),
        onTap: () {
          if (kDebugMode) {
            print("SearchTypeSwitcher");
          }
          animationCardNotifier.sink.add(null);
          notifierState.switchSearchType();
          fetchJourneyWithCurrentSettings(
            notifierJourney,
            notifierDT,
            notifierState,
          );
        },
      ),
    );
  }
}

class PaddingColumnPartirArriverAvantApres extends StatelessWidget {
  const PaddingColumnPartirArriverAvantApres({
    Key? key,
    required this.partirApres,
    required this.colorPartir,
    required this.arriverAvant,
    required this.colorArriver,
  }) : super(key: key);

  final String partirApres;
  final Color colorPartir;
  final String arriverAvant;
  final Color colorArriver;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(partirApres, style: TextStyle(color: colorPartir)),
          Text(arriverAvant, style: TextStyle(color: colorArriver)),
        ],
      ),
    );
  }
}

class ArrivalTimePicker extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;
  const ArrivalTimePicker(this.animationCardNotifier, {super.key});

  void onPressArrivalTimePicker(
    BuildContext context,
    DateTimeNotifier notifierDT,
    JourneyNotifier notifierJourney,
    AppStateNotifier notifierState,
  ) {
    if (kDebugMode) {
      print("ArrivalTime");
    }
    readTheme().then((colorString) {
      var currentTheme = MyThemes.getThemeFromString(colorString);
      showTimePicker(
        context: context,
        builder: (context, child) => Theme(data: currentTheme, child: child!),
        initialTime: TimeOfDay.now(),
      ).then((TimeOfDay? tod) {
        if (tod != null) {
          notifierDT.arrivalTime = tod;
          DateTime today = DateTime.now();

          showDatePicker(
            context: context,
            firstDate: DateTime(today.year - 1, today.month, today.day),
            initialDate: today,
            lastDate: DateTime(today.year + 1, today.month, today.day),
            builder: (context, child) => Theme(
              data: currentTheme.copyWith(
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: currentTheme.scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                ),
              ),
              child: child!,
            ),
          ).then((DateTime? dt) {
            if (kDebugMode) {
              print("ArrivalTimePicker picked :$dt");
            }
            notifierDT.arrivalDate = dt;
            animationCardNotifier.sink.add(null);
            fetchJourneyWithCurrentSettings(
              notifierJourney,
              notifierDT,
              notifierState,
            );
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifierDT = Provider.of<DateTimeNotifier>(context, listen: false);
    final notifierState = Provider.of<AppStateNotifier>(context);
    final notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    String displayedDT = setDisplayedDT(notifierDT);
    if (kDebugMode) {
      print("ArrivalTimePicker displayed : $displayedDT");
    }

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        highlightColor: Theme.of(context).primaryColor,
        buttonTheme: const ButtonThemeData(
          textTheme: ButtonTextTheme.accent,
          buttonColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Theme.of(context).hoverColor,
          surface: Theme.of(context).primaryColor,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Theme.of(context).focusColor,
        ),
      ),
      child: Builder(
        builder: (context) => InkWell(
          child: textOrIconDateTime(notifierDT, displayedDT),
          onTap: () {
            onPressArrivalTimePicker(
              context,
              notifierDT,
              notifierJourney,
              notifierState,
            );
          },
        ),
      ),
    );
  }

  StatelessWidget textOrIconDateTime(
    DateTimeNotifier notifierDT,
    String displayedDT,
  ) {
    if (notifierDT.arrivalDate == null) {
      return const Icon(Icons.access_time, size: 30);
    } else {
      return Text(displayedDT);
    }
  }

  String setDisplayedDT(DateTimeNotifier notifierDT) {
    String displayedDT;
    if (notifierDT.arrivalDate != null) {
      displayedDT = dateTimeSearchFormater(notifierDT.arrivalDate!);
    } else {
      displayedDT = "ERREUR";
    }
    return displayedDT;
  }
}

class ResetTimePicker extends StatelessWidget {
  final StreamController<dynamic> animationCardNotifier;
  const ResetTimePicker(this.animationCardNotifier, {super.key});
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<DateTimeNotifier>(context, listen: false);
    var visible = notifier.arrivalDate != null;
    return Consumer<AppStateNotifier>(
      builder: (context, notifierState, _) => Consumer<DateTimeNotifier>(
        builder: (context, notifierDT, _) => Visibility(
          visible: visible,
          child: InkWell(
            child: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                onPressResetTimePicker(
                  notifierDT,
                  context,
                  notifierState,
                  visible,
                  notifier,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void onPressResetTimePicker(
    DateTimeNotifier notifierDT,
    BuildContext context,
    AppStateNotifier notifierState,
    bool visible,
    DateTimeNotifier notifier,
  ) {
    notifierDT.resetAllDates();
    JourneyNotifier notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    fetchJourneyWithCurrentSettings(notifierJourney, notifierDT, notifierState);
    visible = notifier.arrivalDate != null;
    animationCardNotifier.sink.add(null);
    notifierState.setSearchDeparture();
  }
}

class ButtonMap extends StatelessWidget {
  final Journey? journey;
  const ButtonMap(this.journey, {super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.map),
      onPressed: () {
        Navigator.pushNamed(context, '/map', arguments: journey);
      },
    );
  }
}

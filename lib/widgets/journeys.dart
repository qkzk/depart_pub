import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

import 'package:depart/data/follow.dart' as follow;
import 'package:depart/data/data.dart' as data;
import 'package:depart/utils.dart';
import 'package:depart/data/models.dart';
import 'package:depart/widgets/widgets.dart';

class FadeJourneyPanel extends StatefulWidget {
  final Stream shouldTriggerChange;
  final Function() notifyParent;
  const FadeJourneyPanel({
    Key? key,
    required this.shouldTriggerChange,
    required this.notifyParent,
  }) : super(key: key);

  @override
  FadeJourneyPanelState createState() => FadeJourneyPanelState();
}

class FadeJourneyPanelState extends State<FadeJourneyPanel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Animation? animation;
  late StreamSubscription streamSubscription;
  final GlobalKey<JourneyPanelState> _key = GlobalKey();
  FadeJourneyPanelState();
  refresh() {
    widget.notifyParent();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    streamSubscription = widget.shouldTriggerChange.listen((_) => someMethod());
  }

  @override
  didUpdateWidget(FadeJourneyPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerChange != oldWidget.shouldTriggerChange) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerChange.listen(
        (_) => someMethod(),
      );
    }
  }

  void someMethod() {
    if (kDebugMode) {
      print('Fade ! received');
    }
    animateRefresh();
    widget.notifyParent();
    setState(() {});
  }

  void animateRefresh() {
    if (kDebugMode) {
      print(
        "Fade animation..............................................................................................",
      );
    }
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      animationBehavior: AnimationBehavior.normal,
    );
    animation =
        Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 1.0, curve: Curves.easeOutExpo),
            ),
            // _controller
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            }
          })
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JourneyPanel(
      key: _key,
      shouldTriggerChange: widget.shouldTriggerChange,
      notifyParent: someMethod,
    );
  }
}

class JourneyPanel extends StatefulWidget {
  final Stream? shouldTriggerChange;
  final Function() notifyParent;
  const JourneyPanel({
    Key? key,
    required this.shouldTriggerChange,
    required this.notifyParent,
  }) : super(key: key);

  @override
  JourneyPanelState createState() => JourneyPanelState(
    // shouldTriggerChange: shouldTriggerChange, notifyParent: notifyParent
  );
}

class JourneyPanelState extends State<JourneyPanel> {
  JourneyPanelState();
  refresh() {
    final JourneyNotifier journeyNotifier = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    final String resultRecherche = (journeyNotifier.journeys != null)
        ? "Chargement des trajets"
        : "Aucun trajet trouvé";
    final int dur = (journeyNotifier.journeys != null) ? 500 : 1500;
    widget.notifyParent();
    setState(() {});
    final snackBar = SnackBar(
      duration: Duration(milliseconds: dur),
      backgroundColor: Theme.of(context).hoverColor,
      content: Text(
        resultRecherche,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JourneyNotifier>(
      builder: (context, notifier, _) {
        if (notifier.journeys != null) {
          notifier.journeys!.printConsole();
          if (kDebugMode) {
            print("_JourneyPanelState");
          }
          return columnJourneyTiles(notifier);
        }
        return const ContainerWithTrainEmptyResult();
      },
    );
  }

  Column columnJourneyTiles(JourneyNotifier notifier) {
    return Column(
      children: notifier.journeys!.journeyList!
          .map(
            (s) => JourneyTile(
              key: UniqueKey(),
              notifyParent: refresh,
              shouldTriggerChange: widget.shouldTriggerChange,
              journey: s,
            ),
          )
          .toList(),
    );
  }
}

class ContainerWithTrainEmptyResult extends StatelessWidget {
  const ContainerWithTrainEmptyResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Opacity(opacity: 0.2, child: Icon(Icons.train, size: 200)),
    );
  }
}

class JourneyTile extends StatefulWidget {
  final Stream? shouldTriggerChange;
  final data.Journey? journey;
  final Function()? notifyParent;
  const JourneyTile({
    Key? key,
    this.shouldTriggerChange,
    this.journey,
    this.notifyParent,
  }) : super(key: key);
  @override
  JourneyTileState createState() => JourneyTileState();
}

class JourneyTileState extends State<JourneyTile>
    with TickerProviderStateMixin {
  JourneyTileState();
  final GlobalKey<CardPanelState> _key = GlobalKey();

  bool visibilitySection = false;
  Animation<double>? animation;
  late AnimationController controller;
  late StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    streamSubscription = widget.shouldTriggerChange!.listen(
      (_) => someMethod(),
    );
  }

  @override
  didUpdateWidget(JourneyTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerChange != oldWidget.shouldTriggerChange) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerChange!.listen(
        (_) => someMethod(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  void animateRefresh() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation =
        Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(
              parent: controller,
              curve: const Interval(0.0, 1.0, curve: Curves.easeOutExpo),
            ),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              controller.reverse();
            }
          })
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
    controller.forward();
    if (kDebugMode) {
      print("journeytilestate animate refresh ${widget.journey!.departureDT}");
    }
  }

  void someMethod() {
    if (kDebugMode) {
      print('STREAMED FROM BUTTON TRAIN');
    }
    widget.notifyParent!();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("_JourneyTileState");
      print("${widget.journey!.departureDT}");
      print("_JourneyTileState");
    }
    return buildConsumer();
  }

  Consumer<JourneyNotifier> buildConsumer() {
    return Consumer<JourneyNotifier>(
      builder: (context, notifierJourney, _) {
        void animateSwipe({required bool left}) {
          String futureUrl = (left) ? "prev" : "next";
          notifierJourney.fetchJourneysFromUrl(futureUrl, context);
          someMethod();
        }

        return GestureDetector(
          onTap: () {
            if (kDebugMode) {
              print(
                "JourneyTile : onTap, visibilitySection $visibilitySection",
              );
            }
            animateRefresh();
            setState(() {});
            Future.delayed(const Duration(milliseconds: 750), () {
              // Here you can write your code
              setState(() {
                // Here you can write your code for open new view
                visibilitySection = !visibilitySection;
              });
            });
          },
          child: Draggable(
            onDragEnd: (drag) {
              if (drag.offset.dx > 0) {
                animateSwipe(left: false);
              } else if (drag.offset.dx < 0) {
                animateSwipe(left: true);
              }
            },
            childWhenDragging: Container(),
            feedback: buildCardPanel(notifierJourney),
            child: buildCardPanel(notifierJourney),
          ),
        );
      },
    );
  }

  CardPanel buildCardPanel(JourneyNotifier notifierJourney) {
    return CardPanel(
      key: _key,
      animation: animation,
      journey: widget.journey,
      visibilitySection: visibilitySection,
      notifierJourney: notifierJourney,
    );
  }
}

class CardPanel extends StatefulWidget {
  const CardPanel({
    Key? key,
    required this.animation,
    required this.journey,
    required this.visibilitySection,
    required this.notifierJourney,
  }) : super(key: key);

  final Animation<double>? animation;
  final data.Journey? journey;
  final bool visibilitySection;
  final JourneyNotifier notifierJourney;

  @override
  CardPanelState createState() => CardPanelState();
}

class CardPanelState extends State<CardPanel> {
  data.Journey? journey;
  @override
  void initState() {
    super.initState();
    journey = widget.journey;
  }

  @override
  void didUpdateWidget(CardPanel oldWidget) {
    if (oldWidget.journey != widget.journey) {
      journey = widget.journey;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      // color: Theme.of(context).primaryColor,
      color: Theme.of(context).primaryColor,
      //color: Color(0xFFFF0000),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      semanticContainer: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.none,
      surfaceTintColor: Colors.transparent,
      child: buildCardContent(),
    );
  }

  Padding buildCardContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCardTopRow(),
          buildCardSecondRow(),
          buildCardThirdRow(),
        ],
      ),
    );
  }

  Visibility buildCardThirdRow() {
    return Visibility(
      visible: widget.visibilitySection,
      child: SectionColumn(widget.journey),
    );
  }

  Visibility buildCardSecondRow() {
    return Visibility(
      visible: !widget.visibilitySection,
      child: Column(
        children: <Widget>[
          const Padding(padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FollowButton(widget.journey),
              ScheduleButton(journey: journey),
              ButtonMap(widget.journey),
              PlaceTransfers(widget.journey),
            ],
          ),
        ],
      ),
    );
  }

  Visibility buildCardTopRow() {
    return Visibility(
      visible: !widget.visibilitySection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PlaceDeparture(widget.journey),
          PlaceDisruptionStart(widget.notifierJourney),
          const Padding(padding: EdgeInsets.all(8)),
          PlaceArrival(widget.journey),
          PlaceDisruptionEnd(widget.notifierJourney),
          const Padding(padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
          buildRowCardTimeRelated(),
        ],
      ),
    );
  }

  Row buildRowCardTimeRelated() {
    return Row(
      children: <Widget>[
        PlaceDuration(widget.journey),
        const Padding(padding: EdgeInsets.all(8)),
        PlaceToday(widget.journey),
        PlaceChrono(
          notifierJourney: widget.notifierJourney,
          journey: widget.journey,
        ),
        const Padding(padding: EdgeInsets.all(8)),
      ],
    );
  }
}

// class FollowButton extends StatelessWidget {
//   const FollowButton(this.journey, {super.key});
//   final data.Journey? journey;

//   @override
//   Widget build(BuildContext context) {
//     return buildIconButtonFollow();
//   }

//   IconButton buildIconButtonFollow() {
//     return IconButton(
//       onPressed: () {
//         data.FollowedJourney followedJourney = journey!.toFollowed();
//         String journeyString = followedJourney.encode();

//         SharedPreferences.getInstance().then(((prefs) {
//           var followedStringList = prefs.getStringList("followedJourney") ?? [];
//           followedStringList.add(journeyString);
//           prefs.setStringList("followedJourney", followedStringList);
//         }));

//         var link = journey?.linkThisJourney;
//         print("pressed follow, link: $link");
//         Workmanager().registerOneOffTask(
//           "1",
//           follow.watchoutFollow,
//           inputData: <String, dynamic>{
//             "journeyString": journeyString,
//           },
//         );
//       },
//       icon: const Icon(Icons.push_pin_outlined, size: 30),
//     );
//   }
// }

class FollowButton extends StatefulWidget {
  const FollowButton(this.journey, {super.key});
  final data.Journey? journey;

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
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
    final nofifierFollow = Provider.of<FollowNotifier>(context);
    return GestureDetector(
      onTap: () {
        nofifierFollow.setHasFollowedJourney();
        _controller.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          _controller.reverse();
        });
        data.FollowedJourney followedJourney = widget.journey!.toFollowed();
        String journeyString = followedJourney.encode();

        SharedPreferences.getInstance().then(((prefs) {
          var followedStringList = prefs.getStringList("followedJourney") ?? [];
          followedStringList.add(journeyString);
          prefs.setStringList("followedJourney", followedStringList);
        }));

        var link = widget.journey?.linkThisJourney;
        if (kDebugMode) {
          print("pressed follow, link: $link");
        }
        Workmanager().registerOneOffTask(
          "1",
          follow.watchoutFollow,
          inputData: <String, dynamic>{"journeyString": journeyString},
        );
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 3.0).animate(_controller),
        child: Icon(
          Icons.push_pin_outlined,
          size: 30 + _controller.value * 25.0,
        ),
      ),
    );
  }
}

class PlaceDestination extends StatelessWidget {
  const PlaceDestination(
    this.journey,
    this.destDatetime,
    this.destText, {
    super.key,
  });
  final data.Journey? journey;
  final DateTime destDatetime;
  final String? destText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PlaceName(
            prettyTime(destDatetime),
            color: Colors.white,
            fontSize: 22,
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
          PlaceName(destText, color: Colors.white54, wrap: 25),
        ],
      ),
    );
  }
}

class PlaceDeparture extends StatelessWidget {
  const PlaceDeparture(this.journey, {super.key});
  final data.Journey? journey;

  @override
  Widget build(BuildContext context) {
    return PlaceDestination(journey, journey!.departureDT!, journey!.fromName);
  }
}

class PlaceArrival extends StatelessWidget {
  const PlaceArrival(this.journey, {super.key});
  final data.Journey? journey;

  @override
  Widget build(BuildContext context) {
    return PlaceDestination(journey, journey!.arrivalDT!, journey!.toName);
  }
}

class PlaceChrono extends StatefulWidget {
  final data.Journey? journey;
  final JourneyNotifier? notifierJourney;
  const PlaceChrono({super.key, this.notifierJourney, this.journey});

  @override
  PlaceChronoState createState() => PlaceChronoState();
}

class PlaceChronoState extends State<PlaceChrono> {
  PlaceChronoState();

  late bool _visible;
  Duration? _chronoDeparture;
  late Duration _chronoArrival;
  String _displayedChrono = '';

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _getTime() {
    setState(() {
      _chronoArrival = widget.journey!.arrivalDT!.difference(DateTime.now());
      _chronoDeparture = widget.journey!.departureDT!.difference(
        DateTime.now(),
      );
      _displayedChrono = _formatChrono(_chronoDeparture, _chronoArrival);
      _visible =
          dateWidgetFormater(widget.journey!.arrivalDT!) == "Aujourd'hui";
    });
  }

  String _formatChrono(Duration? chronoDeparture, Duration chronoArrival) {
    // si le trian est déjà parti on renvoie une chaine vide
    if (chronoArrival.isNegative) {
      return '';
    }
    // on choisit quel chrono afficher
    Duration chrono = (chronoDeparture!.isNegative)
        ? chronoArrival
        : chronoDeparture;
    int days = chrono.inDays.abs();
    int hours = chrono.inHours.abs();
    int min = chrono.inMinutes.abs();
    // selon les cas on adapte le texte
    return _chronoTextFormater(chronoDeparture, days, hours, min);
  }

  String _chronoTextFormater(
    Duration chronoDeparture,
    int days,
    int hours,
    int min,
  ) {
    String text = (chronoDeparture.isNegative) ? "Arrivée : " : "Départ : ";
    if (days > 0) {
      text = "$days jours, ";
    }
    if (hours > 0) {
      text = "$text${hours % 24} heures, ";
    }
    if (min > 0) {
      text = "$text${min % 60} min";
    } else {
      text = (chronoDeparture.isNegative)
          ? "Arrivée imminente"
          : "Départ en cours";
    }
    return text;
  }

  late Timer timer;
  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void initState() {
    _chronoDeparture = widget.journey!.departureDT!.difference(DateTime.now());
    _chronoArrival = widget.journey!.arrivalDT!.difference(DateTime.now());
    _displayedChrono = _formatChrono(_chronoDeparture, _chronoArrival);
    _visible = false;
    startTimer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visible,
      child: PlaceName(_displayedChrono, wrap: 26, fontSize: 16),
    );
  }
}

class PlaceToday extends StatelessWidget {
  const PlaceToday(this.journey, {super.key});
  final data.Journey? journey;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: dateWidgetFormater(journey!.arrivalDT!) != "Aujourd'hui",
      child: PlaceName(
        dateWidgetFormater(journey!.arrivalDT!),
        color: Colors.white54,
      ),
    );
  }
}

class PlaceDuration extends StatelessWidget {
  const PlaceDuration(this.journey, {super.key});
  final data.Journey? journey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.timer, color: Colors.white54),
          PlaceName(" ${strDuration(journey!.duration!)}"),
        ],
      ),
    );
  }
}

class PlaceTransfers extends StatelessWidget {
  const PlaceTransfers(this.journey, {super.key});
  final data.Journey? journey;

  @override
  Widget build(BuildContext context) {
    if (journey!.transferNumber != 0) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: buildRowTransfer(),
      );
    } else {
      return const SizedBox(height: 0.0, width: 0.0);
    }
  }

  Row buildRowTransfer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PlaceName("Transferts : ", color: Colors.white54, fontSize: 16),
        PlaceName(journey!.transferNumber.toString()),
      ],
    );
  }
}

class PlaceDisruptionStart extends StatelessWidget {
  final JourneyNotifier notifierJourney;
  const PlaceDisruptionStart(this.notifierJourney, {super.key});

  @override
  Widget build(BuildContext context) {
    data.Journeys journey = notifierJourney.journeys!;

    if (journey.disruption!.tripCanceled! ||
        journey.disruption!.isDisruptionStartDisplayable()) {
      var disruptionText = [PlaceName(journey.disruption!.motifStart())];
      return PlaceDisruptionText(disruptionText: disruptionText);
    }
    return const SizedBox(height: 0.0, width: 0.0);
  }
}

class PlaceDisruptionText extends StatelessWidget {
  const PlaceDisruptionText({Key? key, required this.disruptionText})
    : super(key: key);

  final List<Widget> disruptionText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        children: disruptionText,
      ),
    );
  }
}

class PlaceDisruptionEnd extends StatelessWidget {
  const PlaceDisruptionEnd(this.notifierJourney, {super.key});
  final JourneyNotifier notifierJourney;

  @override
  Widget build(BuildContext context) {
    final data.Journeys journey = notifierJourney.journeys!;

    if (journey.disruption!.isDisruptionEndDisplayable()) {
      return PlaceDisruptionText(
        disruptionText: [PlaceName(journey.disruption!.motifEnd())],
      );
    }
    return Container();
  }
}

class DisruptionEndText extends StatelessWidget {
  const DisruptionEndText({Key? key, required this.disruptionText})
    : super(key: key);

  final List<Widget> disruptionText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        children: disruptionText,
      ),
    );
  }
}

class PlaceDisruptions extends StatelessWidget {
  const PlaceDisruptions(this.journey, {super.key});
  final data.Journeys journey;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
        "DISRUPTIONS journey.disruptionNumber ${journey.disruption!.disruptionNumber}",
      );
      print(journey.disruption!.endDisrupted);
      print(journey.disruption!.causeDisruptionStart);
      print(journey.disruption!.causeDisruptionEnd);
      print(journey.disruption!.delayStart);
      print(journey.disruption!.delayEnd);
    }
    if ((journey.disruption!.disruptionNumber != 0)) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: buildColumnPlaceDisruption(),
      );
    } else {
      return const SizedBox(height: 0.0, width: 0.0);
    }
  }

  Column buildColumnPlaceDisruption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildRowFirstelementPlaceDisruption(),
        DisruptionFrom(journey: journey),
        DisruptionTo(journey: journey),
      ],
    );
  }

  Row buildRowFirstelementPlaceDisruption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PlaceName(journey.disruption!.disruptionNumber.toString()),
        const PlaceName(" problème(s)", color: Colors.white54),
      ],
    );
  }
}

class DisruptionTo extends StatelessWidget {
  const DisruptionTo({Key? key, required this.journey}) : super(key: key);

  final data.Journeys journey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PlaceName(
          "Arrivée : ${journey.disruption!.causeDisruptionEnd}, retard ${journey.disruption!.delayEnd}",
        ),
      ],
    );
  }
}

class DisruptionFrom extends StatelessWidget {
  const DisruptionFrom({Key? key, required this.journey}) : super(key: key);

  final data.Journeys journey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PlaceName(
          "Départ : ${journey.disruption!.causeDisruptionStart}, retard ${journey.disruption!.delayStart}",
        ),
      ],
    );
  }
}

class PlaceName extends StatelessWidget {
  const PlaceName(
    this.name, {
    super.key,
    this.color = Colors.white,
    this.fontSize = 18,
    this.wrap = 32,
  });
  final Color color;
  final double fontSize;
  final String? name;
  final int wrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      wrapLongText(name!, wrap),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class SectionColumn extends StatefulWidget {
  const SectionColumn(this.journey, {super.key});
  final data.Journey? journey;
  @override
  SectionColumnState createState() => SectionColumnState();
}

class SectionColumnState extends State<SectionColumn> {
  SectionColumnState();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(8)),
        ...[for (var sect in widget.journey!.sectionList!) Leg(sect)],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: childrenColumnState(),
        ),
      ],
    );
  }

  List<Widget> childrenColumnState() {
    return <Widget>[
      ScheduleButton(journey: widget.journey),
      PlaceName(widget.journey!.sectionList!.last.toStation!.name),
      ButtonMap(widget.journey),
    ];
  }
}

class ScheduleButton extends StatelessWidget {
  const ScheduleButton({Key? key, required this.journey}) : super(key: key);

  final data.Journey? journey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.list),
      onPressed: () {
        Navigator.pushNamed(context, '/schedule', arguments: journey);
      },
    );
  }
}

class Leg extends StatefulWidget {
  final data.Section section;
  const Leg(this.section, {super.key});
  @override
  LegState createState() => LegState();
}

class LegState extends State<Leg> {
  LegState();
  bool sectionVisible = false;
  @override
  Widget build(BuildContext context) {
    void setVisible() {
      sectionVisible = !sectionVisible;
      if (kDebugMode) {
        print(sectionVisible);
      }
    }

    return GestureDetector(
      child: Column(children: childrenVisibilityFrom()),
      onTap: () {
        setState(setVisible);
      },
    );
  }

  List<Widget> childrenVisibilityFrom() {
    return [
      PlaceName('${widget.section.from!.name}'),
      RowDepartureDetail(section: widget.section),
      VisibilityDepartureDetail(
        sectionVisible: sectionVisible,
        section: widget.section,
      ),
    ];
  }
}

class VisibilityDepartureDetail extends StatelessWidget {
  const VisibilityDepartureDetail({
    Key? key,
    required this.sectionVisible,
    required this.section,
  }) : super(key: key);

  final bool sectionVisible;
  final data.Section section;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: sectionVisible,
      child: Column(children: childrenDepartureDetail()),
    );
  }

  List<Widget> childrenDepartureDetail() {
    return <Widget>[
      TableInfoSection(section: section),
      const Padding(padding: EdgeInsets.all(5.0)),
      const Text("Arrêts :"),
      const Padding(padding: EdgeInsets.all(5.0)),
      StopTable(section),
    ];
  }
}

class RowDepartureDetail extends StatelessWidget {
  const RowDepartureDetail({Key? key, required this.section}) : super(key: key);

  final data.Section section;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        PlaceName(prettyTime(section.from!.departureTime!), fontSize: 16),
        const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.train)),
        PlaceName(prettyTime(section.toStation!.departureTime!), fontSize: 16),
      ],
    );
  }
}

class TableInfoSection extends StatelessWidget {
  const TableInfoSection({Key? key, required this.section}) : super(key: key);

  final data.Section section;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        rowDetail("Durée : ", strDuration(section.duration!, long: true)),
        rowDetail("Direction", section.displayInformation!.direction!),
        rowDetail("Ligne : ", section.displayInformation!.label!),
        rowDetail(
          "${section.displayInformation!.commercialMode}",
          "n° : ${section.displayInformation!.headsign}",
        ),
      ],
    );
  }

  TableRow rowDetail(String textKey, String textValue) {
    var textStyle54 = const TextStyle(color: Colors.white54);
    var edgeInsets4 = const EdgeInsets.all(4);
    return TableRow(
      children: [
        Text(textKey, style: textStyle54),
        Padding(padding: edgeInsets4),
        Text(textValue),
      ],
    );
  }
}

class StopTable extends StatelessWidget {
  const StopTable(this.section, {super.key});
  final data.Section section;

  @override
  Widget build(BuildContext context) {
    double height = section.stops!.stopNumbers! * 19.0;
    return SizedBox(
      height: height,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          ...[for (var stop in section.stops!.stops!) buildTableRow(stop)],
        ],
      ),
    );
  }

  TableRow buildTableRow(data.Station stop) {
    return TableRow(
      children: [
        Text(DateFormat(formatTODAPIWidget).format(stop.departureTime!)),
        const Padding(padding: EdgeInsets.all(6)),
        Text(
          wrapLongText(stop.name!, 40),
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }
}

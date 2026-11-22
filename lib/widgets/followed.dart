import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:depart/data/models.dart';
import 'package:depart/data/data.dart';

const String followedTitle = "Followed journey";

// clear sharedPrefs if any bug happens
Future<bool> clearSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.clear();
}

void showFollowedJourney(BuildContext context,
    StreamController<dynamic> animationCardNotifier) async {
  final notifierJourney = Provider.of<JourneyNotifier>(context, listen: false);
  final notifierDT = Provider.of<DateTimeNotifier>(context, listen: false);
  final notifierState = Provider.of<AppStateNotifier>(context, listen: false);
  final notifierFollow = Provider.of<FollowNotifier>(context, listen: false);
  var prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  if (!context.mounted) return;
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          final widgets = createFollowedJourneyWidget(
            context,
            animationCardNotifier,
            notifierJourney,
            notifierDT,
            notifierState,
            notifierFollow,
            setState,
            prefs,
          );
          return SimpleDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(followedTitle),
            children: widgets,
          );
        });
      });
}

List<Widget>? createFollowedJourneyWidget(
  BuildContext context,
  StreamController animationCardNotifier,
  JourneyNotifier notifierJourney,
  DateTimeNotifier notifierDT,
  AppStateNotifier notifierState,
  FollowNotifier notifierFollow,
  StateSetter setState,
  SharedPreferences prefs,
) {
  List<String>? journeyStringList = prefs.getStringList("followedJourney");
  // print("createFollowedJourneyWidget $journeyStringList");
  List<FollowedJourney> journeys = (journeyStringList != null)
      ? journeyStringList.map((item) => FollowedJourney.decode(item)).toList()
      : [];
  List<FollowedWidget>? widgets = journeys
      .map((followedJourney) => FollowedWidget(
            followedJourney: followedJourney,
            notifierJourney: notifierJourney,
            notifierDT: notifierDT,
            notifierState: notifierState,
            notifierFollow: notifierFollow,
            animationCardNotifier: animationCardNotifier,
            setState: setState,
          ))
      .toList();
  return widgets;
}

class FollowedWidget extends StatelessWidget {
  final FollowedJourney? followedJourney;
  final JourneyNotifier notifierJourney;
  final DateTimeNotifier notifierDT;
  final AppStateNotifier notifierState;
  final FollowNotifier notifierFollow;
  final StreamController<dynamic> animationCardNotifier;
  final StateSetter setState;

  const FollowedWidget({
    Key? key,
    required this.followedJourney,
    required this.notifierJourney,
    required this.notifierState,
    required this.notifierDT,
    required this.animationCardNotifier,
    required this.setState,
    required this.notifierFollow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildClicableText(context),
          IconButton(
            onPressed: () {
              remove();
              SharedPreferences.getInstance().then((prefs) {
                List<String>? journeyStringList =
                    prefs.getStringList("followedJourney");
                if (journeyStringList == null || journeyStringList.isEmpty) {
                  notifierFollow.unsetHasFollowedJourney();
                }
              });
            },
            icon: const Icon(Icons.cancel),
          )
        ],
      ),
    );
  }

  void remove() {
    SharedPreferences.getInstance().then((prefs) {
      List<String>? journeyStringList = prefs.getStringList("followedJourney");
      journeyStringList
          ?.removeWhere((element) => element == followedJourney?.encode());
      prefs.setStringList("followedJourney", journeyStringList!);
      setState(() {});
    });
  }

  Widget buildClicableText(BuildContext context) {
    return InkWell(
      onTap: () {
        if (kDebugMode) {
          print("clicked followed journey $this");
        }
        fetchThisFollowedJourney(
          notifierJourney,
          // notifierDT,
          // notifierState,
          followedJourney!,
          context,
        );
        animationCardNotifier.sink.add(null);
      },
      child: Text(followedJourney!.format()),
    );
  }
}

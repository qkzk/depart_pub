import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:depart/data/models.dart' as models;
import 'package:depart/data/api.dart' as api;
import 'package:depart/data/data.dart' as data;
import 'package:depart/main.dart' as main;

const clicFollow = "clicFollow";
const watchoutFollow = "watchoutFollow";

@pragma('vm:entry-point')
void callBackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case clicFollow:
        final journeyString = inputData?["journeyString"];
        await notifyIfDisrupted(journeyString);
        break;
      case watchoutFollow:
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        final journeys = prefs.getStringList("followedJourney");
        if (journeys == null || journeys.isEmpty) {
          break;
        }
        await notifyAllDisrupted(journeys);
        break;
    }
    return Future.value(true);
  });
}

Future<void> notifyAllDisrupted(List<String> journeys) async {
  for (var journeyString in journeys) {
    await notifyIfDisrupted(journeyString);
  }
}

Future<void> notifyIfDisrupted(String journeyString) async {
  if (journeyString.contains("☢️")) {
    return;
  }
  final disruptionMotif = await getDisruptionMotif(journeyString);
  if (disruptionMotif != "") {
    await notifyDisruption(journeyString, disruptionMotif);
    await updateThisJourneyString(journeyString);
  }
}

Future<void> updateThisJourneyString(String journeyString) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  var journeys = prefs.getStringList("followedJourney");
  final index = journeys?.indexOf(journeyString);
  if (index != null && index != -1) {
    var strings = journeyString.split('#');
    strings[4] = "☢️";
    journeyString = strings.join("#");
    journeys![index] = journeyString;
    // print("updateThisJourneyString ${journeys[index]}");
    await prefs.setStringList("followedJourney", journeys);
    // print(
    //     "updateThisJourneyString $result, ${prefs.getStringList("followedJourney")}");
  }
}

Future<bool> hasDisruption(String journeyString) async {
  final strings = journeyString.split("#");
  if (strings.length < 4) {
    return false;
  }
  final link = strings[3];
  return fetchForDisruption(link);
}

Future<String> getDisruptionMotif(String journeyString) async {
  final strings = journeyString.split("#");
  final link = strings[3];
  final fetched = api.fetchData(link);
  final body = (await fetched)?[0];
  final jsonContent = json.decode(body);
  List<dynamic> jsonDisruptions = jsonContent["disruptions"];
  if (jsonDisruptions.isNotEmpty) {
    return data.DisruptionInfos.fromJson(jsonContent).motifStart();
  }
  return "";
}

Future<bool> fetchForDisruption(String link) async {
  List<dynamic>? fetched = await api.fetchData(link);
  String body = fetched?[0];
  return parseBodyForDisruption(body);
}

bool parseBodyForDisruption(String body) {
  final jsonContent = json.decode(body);
  final jsonDisruptions = jsonContent["disruptions"];
  if (jsonDisruptions.length > 0) {
    var disruptionInfos = data.DisruptionInfos.fromJson(jsonContent);
    return disruptionInfos.hasAny();
  }
  return false;
}

Future<void> notifyDisruption(String journeyString, String motif) async {
  final data.FollowedJourney journey = data.FollowedJourney.decode(
    journeyString,
  );
  final String title = "Retard: ${journey.format()}";
  final String body = "Motif: $motif";
  await notifier(title, body, journeyString);
}

void onSelectNotification(String? payload) async {
  if (payload != null) {
    fetchThisClickedJourney(payload);
  }
}

void notificationResponseWTF(NotificationResponse notification) async {
  if (notification.payload != null) {
    fetchThisClickedJourney(notification.payload!);
  }
}

void onDidReceiveNotificationResponse(
  int id,
  String? title,
  String? body,
  String? payload,
) async {
  if (payload != null) {
    fetchThisClickedJourney(payload);
  }
}

void fetchThisClickedJourney(String journeyString) {
  final data.FollowedJourney followedJourney = data.FollowedJourney.decode(
    journeyString,
  );
  final BuildContext context =
      main.NavigationService.navigatorKey.currentContext!;
  final models.JourneyNotifier notifierJourney =
      Provider.of<models.JourneyNotifier>(context, listen: false);
  notifierJourney.fetchJourneysSpecificUrl(followedJourney.link!, context);
}

Future<void> notifier(String title, String body, String journeyString) async {
  await main.localNotification.show(
    id: 0,
    title: title,
    body: body,
    // main.platformChannelSpecifics,
    payload: journeyString,
  );
  return Future.value();
}

// Remove all followed trains with departure time older than a day.
// Non async version since we call it from [main].
void clearOldFollowed() {
  SharedPreferences.getInstance().then((prefs) {
    final List<String>? journeys = prefs.getStringList("followedJourney");
    if (journeys == null || journeys.isEmpty) {
      return;
    }
    journeys.removeWhere((journeyString) => tooOld(journeyString));
    prefs.setStringList("followedJourney", journeys);
  });
}

// True if the string encodes a train with departure time older than a day.
bool tooOld(String journeyString) {
  final List<String> splitted = journeyString.split("#");
  final String dtString = splitted[2];
  final DateTime dt = DateTime.parse(dtString);
  final DateTime now = DateTime.now();
  final int deltaDays = now.difference(dt).inDays;
  return deltaDays > 0;
}

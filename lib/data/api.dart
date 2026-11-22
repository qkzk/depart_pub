import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import 'package:depart/data/data.dart';
import 'package:depart/data/schedules.dart';
import 'package:depart/utils.dart';
import 'package:depart/auth/secrets.dart';

String urlNavitiaJourney =
    formatURLNavitiaJourney('', '', ''); // empty string : Lille, Haz, now

Future<Journeys?> fetchJourney(
  String? stopAreaStart,
  String? stopAreaStop,
  String departureString, {
  String requestType = '',
  String? givenURL = '',
}) async {
  // si on ne fournit pas de précision on part "après telle heure"
  // sinon avant telle heure...
  if (kDebugMode) {
    print("API fetchJourney $requestType");
  }

  String? url = setUrl(
    givenURL,
    requestType,
    stopAreaStart,
    stopAreaStop,
    departureString,
  );
  final body = await fetchData(url!);
  if (body != null) {
    if (kDebugMode) {
      print(body);
    }
  }
  return setReturnContent(body);
}

Journeys? setReturnContent(List<dynamic>? body) {
  if (body == null) {
    if (kDebugMode) {
      print("body is null");
    }
    return null;
  } else {
    try {
      return Journeys.fromJson(json.decode(body[0]), body[1]);
    } catch (e) {
      if (kDebugMode) {
        print("setReturnContent raised error $e");
        print("body: $body");
      }
      return null;
    }
  }
}

String? setUrl(
  String? givenURL,
  String requestType,
  String? stopAreaStart,
  String? stopAreaStop,
  String departureString,
) {
  String? url;
  if (givenURL != '') {
    // pour les cas où l'url est déjà donné
    url = givenURL;
    if (kDebugMode) {
      print("fetchJourney $url");
    }
  } else {
    requestType = (requestType == '') ? "departure" : requestType;
    url = formatURLNavitiaJourney(stopAreaStart, stopAreaStop, departureString,
        requestType: requestType);
  }
  return url;
}

Future<List<Station>?> fetchStationList(String fromStation) async {
  final String url = formatURLNavitiaStop(fromStation);
  final body = await fetchData(url);
  if (body == null) {
    return null;
  }
  final decodedBody = json.decode(body[0]);
  if (!decodedBody.containsKey('places')) {
    return null;
  } else {
    var list = decodedBody['places'] as List;
    return list.map<Station>((p) => Station.fromJson(p)).toList();
  }
}

Future<Schedule?> fetchSchedule(String url) async {
  final body = await fetchData(url);
  if (body == null) {
    return null;
  }
  return Schedule.fromJson(json.decode(body[0]));
}

/// Fetches data from a url over http
/// returns null if 200 is not returned
/// Throws a HttpException if 200 is not returned
Future<List?> fetchData(String url) async {
  try {
    if (kDebugMode) {
      print("fetchData: $url");
    }

    // url = "https://api.sncf.com/v1/coverage/sncf/journeys?from=stop_area:OCE:SA:87286005&to=stop_area:OCE:SA:87474007&datetime_represents=arrival&datetime=20191110T224500";
    final res = await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: navitiaToken});
    if (kDebugMode) {
      print("fetchData: got $res");
    }
    if (res.statusCode != 200) {
      if (kDebugMode) {
        print(
            'fetchData: Error ${res.statusCode}: $url ########################\n#######################\n####################');
      }
      return null;
    }
    if (kDebugMode) {
      print("fetchData: 200 OK");
    }
    return [res.body, url];
  } on OSError {
    if (kDebugMode) {
      print(
          "fetchData: SocketException - is the device connected to internet ?");
    }
    return null;
  }
}

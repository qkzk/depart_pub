import 'package:depart/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

/* DATA TYPES */

/// data type for Station from JSON
class Station {
  final String? name;
  final String? id;
  final DateTime? departureTime;
  final LatLng? latLng;

  Station({this.name, this.id, this.departureTime, this.latLng});
  // Station({this.name, this.id, this.departureTime});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      name: json['name'],
      id: json['id'],
    );
  }

  void printConsole() {
    if (kDebugMode) {
      print("name :          $name");
      print("id :            $id");
      if (departureTime != null) {
        print("departureTime : $departureTime");
      }
    }
  }
}

class Journeys {
  final List<Journey>? journeyList;
  final Url? links;
  final DisruptionInfos? disruption;

  Journeys({
    this.journeyList,
    this.links,
    this.disruption,
  });

  factory Journeys.fromJson(Map<String, dynamic> json, String url) {
    if (kDebugMode) {
      print("Journeys.fromJson");
    }
    DisruptionInfos disruption = DisruptionInfos.fromJson(json);
    int nbJourney = json['journeys'].length;
    if (kDebugMode) {
      print(nbJourney);
    }
    Journey tempJourney;
    List<Journey> extractJourneys(List<dynamic>? json) {
      List<Journey> journeyList = [];
      for (var k = 0; k < nbJourney; k++) {
        tempJourney = Journey.fromJson(json![k]);
        journeyList.add(tempJourney);
      }
      return journeyList;
    }

    List<Journey> journeys = extractJourneys(json['journeys']);
    return Journeys(
      links: Url.fromJson(json["links"], url),
      journeyList: journeys,
      disruption: disruption,
    );
  }

  // print all attributes to console
  void printConsole() {
    if (kDebugMode) {
      print('toName             ${journeyList![0].toName}');
      print('fromName           ${journeyList![0].fromName}');
    }
  }
}

class Url {
  final String? first;
  final String? next;
  final String? curr;
  final String? prev;
  final String? last;
  Url({this.first, this.next, this.curr, this.prev, this.last});

  factory Url.fromJson(List<dynamic>? json, String url) {
    return Url(
      next: json![0]['href'],
      prev: json[1]['href'],
      curr: url,
      first: json[2]['href'],
      last: json[3]['href'],
    );
  }
}

class Journey {
  final int? duration;
  final String? stringArrivalDT;
  final String? stringDepartureDT;
  final DateTime? departureDT;
  final DateTime? arrivalDT;
  final String? fromName;
  final String? fromId;
  final String? toName;
  final String? toId;
  final int? transferNumber;
  final List<Section>? sectionList;
  final String? linkSameJourneySchedules;
  final String? linkThisJourney;

  Journey({
    this.duration,
    this.stringArrivalDT,
    this.stringDepartureDT,
    this.departureDT,
    this.arrivalDT,
    this.fromName,
    this.toName,
    this.fromId,
    this.toId,
    this.transferNumber,
    this.sectionList,
    this.linkSameJourneySchedules,
    this.linkThisJourney,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    String stringDepartureDT = json['departure_date_time'];
    String stringArrivalDT = json['arrival_date_time'];
    int? nbSections = json["sections"].length;
    int? duration = json['duration'];
    DateTime departureDT = DateTime.parse(stringDepartureDT);
    DateTime arrivalDT = DateTime.parse(stringArrivalDT);
    String? fromName = json["sections"][0]["from"]["name"];
    String? toName = json["sections"][nbSections! - 1]["to"]["name"];
    String? fromId = json["sections"][0]["from"]["id"];
    String? toId = json["sections"][nbSections - 1]["to"]["id"];
    String linkSameJourneySchedules = json["links"][0]["href"];
    linkSameJourneySchedules = formatJourneySchedule(linkSameJourneySchedules);
    String linkThisJourney = json["links"][1]["href"];

    if (kDebugMode) {
      print("link this journey: $linkThisJourney");
    }

    Section tempSection;
    List<Section> extractSections(List<dynamic>? json) {
      List<Section> sectionsList = [];
      for (var k = 0; k < nbSections; k++) {
        try {
          tempSection = Section.fromJson(json![k]);
        } catch (e) {
          if (kDebugMode) {
            print("parsing Section raised an error");
          }
          continue;
        }
        sectionsList.add(tempSection);
      }
      return sectionsList;
    }

    List<Section> sections = extractSections(json["sections"]);

    return Journey(
      duration: duration,
      stringDepartureDT: stringDepartureDT,
      stringArrivalDT: stringArrivalDT,
      departureDT: departureDT,
      arrivalDT: arrivalDT,
      fromName: fromName,
      fromId: fromId,
      toName: toName,
      toId: toId,
      transferNumber: json["nb_transfers"],
      sectionList: sections,
      linkSameJourneySchedules: linkSameJourneySchedules,
      linkThisJourney: linkThisJourney,
    );
  }

  /// print all attributes to console
  void printConsole() {
    if (kDebugMode) {
      print('link SameJourneySchedules    $linkSameJourneySchedules');
      print('duration           $duration');
      print('stringDepartureDT  $stringDepartureDT');
      print('stringArrivalDT    $stringArrivalDT');
      print('departureDT        $departureDT');
      print('arrivalDT          $arrivalDT');
      print('toName             $toName');
      print('fromName           $fromName');
      print('transferNumber     $transferNumber');
      print("Correspondances (section)");
      for (var k = 0; k < sectionList!.length; k++) {
        sectionList![k].from!.printConsole();
        sectionList![k].toStation!.printConsole();
      }
    }
  }

  FollowedJourney toFollowed() {
    return FollowedJourney(
      from: fromName,
      to: toName,
      departure: stringDepartureDT,
      link: linkThisJourney,
      knownDisruption: "no",
    );
  }
}

class Section {
  final Station? from;
  final Station? toStation;
  final StopPoints? stops;
  final DisplayInformation? displayInformation;
  final int? duration;
  Section({
    this.from,
    this.duration,
    this.toStation,
    this.stops,
    this.displayInformation,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    String? fromName = json["from"]["name"];
    String? fromId = json["from"]["id"];
    String? toName = json["to"]["name"];
    String? toId = json["to"]["id"];
    int? duration = json["duration"];
    DateTime? arrivalDT = DateTime.parse(json["base_arrival_date_time"]);
    DateTime? departureDT = DateTime.parse(json["base_departure_date_time"]);

    return Section(
      from: Station(
        name: fromName,
        id: fromId,
        departureTime: departureDT,
      ),
      toStation: Station(
        name: toName,
        id: toId,
        departureTime: arrivalDT,
      ),
      stops: StopPoints.fromJson(json),
      displayInformation: DisplayInformation.fromJson(json),
      duration: duration,
    );
  }
}

class DisplayInformation {
  final String? commercialMode;
  final String? direction;
  final String? label;
  final String? headsign;
  DisplayInformation({
    this.commercialMode,
    this.direction,
    this.label,
    this.headsign,
  });
  factory DisplayInformation.fromJson(Map<String, dynamic> json) {
    return DisplayInformation(
      commercialMode: json["display_informations"]["commercial_mode"],
      direction: json["display_informations"]["direction"],
      label: json["display_informations"]["label"],
      headsign: json["display_informations"]["headsign"],
    );
  }
}

class StopPoints {
  final int? stopNumbers;
  final List<Station>? stops;
  StopPoints({
    this.stopNumbers,
    this.stops,
  });

  factory StopPoints.fromJson(Map<String, dynamic> json) {
    int? number = json["stop_date_times"].length;

    List<Station> buildStopStationList(int? number, List? jsonsdt) {
      List<Station> stops = [];
      for (var k = 0; k < number!; k++) {
        stops.add(Station(
          name: jsonsdt![k]["stop_point"]["label"],
          id: jsonsdt[k]["stop_point"]["id"],
          departureTime: DateTime.parse(jsonsdt[k]["arrival_date_time"]),
          latLng: LatLng(
            double.parse(jsonsdt[k]["stop_point"]["coord"]["lat"]),
            double.parse(jsonsdt[k]["stop_point"]["coord"]["lon"]),
          ),
        ));
      }
      return stops;
    }

    List<Station> extractStops(List<dynamic>? jsonsdt) {
      List<Station> stops = buildStopStationList(number, jsonsdt);
      return stops;
    }

    return StopPoints(
      stopNumbers: number,
      stops: extractStops(json["stop_date_times"]),
    );
  }
}

class Disruption {
  final String? status;
  final bool? tripCanceled;
  final String? name;
  final String? effect;
  final String? message;
  final DateTime? updatedAt;
  final DateTime? begin;
  final DateTime? end;
  final int? impactedStopsNumber;
  final List<ImpactedStop>? impactedList;

  Disruption({
    this.status,
    this.tripCanceled,
    this.name,
    this.effect,
    this.message,
    this.updatedAt,
    this.begin,
    this.end,
    this.impactedStopsNumber,
    this.impactedList,
  });

  factory Disruption.fromJson(Map<String, dynamic> json) {
    int impactedStopsNumber =
        (json["impacted_objects"][0]["impacted_stops"] != null)
            ? json["impacted_objects"][0]["impacted_stops"].length
            : 0;
    List<ImpactedStop> impactedList = [];
    for (var k = 0; k < impactedStopsNumber; k++) {
      impactedList.add(ImpactedStop.fromJson(
          json["impacted_objects"][0]["impacted_stops"][k]));
    }
    if (json["severity"]["name"] == "trip canceled") {
      if (kDebugMode) {
        print(
            "Disruption >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>trip candeled !");
      }
    }
    return Disruption(
      status: json["status"],
      name: json["severity"]["name"],
      effect: json["severity"]["effect"],
      tripCanceled: json["severity"]["name"] == "trip canceled",
      message: (json["messages"] != null) ? json["messages"][0]["text"] : null,
      updatedAt: DateTime.parse(json["updated_at"]),
      begin: DateTime.parse(json["application_periods"][0]["begin"]),
      end: DateTime.parse(json["application_periods"][0]["end"]),
      impactedStopsNumber: impactedStopsNumber,
      impactedList: impactedList,
    );
  }
}

/// from json["disruptions"][index]["impacted_objects"][0]["impacted_stops"]
class ImpactedStop {
  final String? amendedArrivaltime;
  final String? name;
  final String? id;
  final String? cause;
  final String? amendedDepartureTime;
  final String? baseArrivalTime;
  final String? baseDepartureTime;
  final String? arrivalStatus;
  final String? departureStatus;
  final String? stopTimeEffect;
  final bool? isDetour;

  ImpactedStop({
    this.amendedArrivaltime,
    this.name,
    this.id,
    this.cause,
    this.amendedDepartureTime,
    this.baseArrivalTime,
    this.baseDepartureTime,
    this.arrivalStatus,
    this.departureStatus,
    this.stopTimeEffect,
    this.isDetour,
  });

  /// json["disruption"][index]["impacted_objects"][0]["impacted_stops"]
  factory ImpactedStop.fromJson(Map<String, dynamic> json) {
    dynamic name;
    dynamic id;
    try {
      name = json["stop_area"]["name"];
      id = json["stop_area"]["id"];
    } catch (e) {
      name = json["stop_point"]["name"];
      id = json["stop_point"]["id"];
    }
    return ImpactedStop(
      amendedArrivaltime: json["amended_arrival_time"],
      name: name,
      cause: json["cause"],
      id: id,
      amendedDepartureTime: json["amended_departure_time"],
      baseArrivalTime: json["base_arrival_time"],
      baseDepartureTime: json["base_departure_time"],
      arrivalStatus: json["arrival_status"],
      departureStatus: json["departure_status"],
      stopTimeEffect: json["stop_time_effect"],
      isDetour: json["is_detour"],
    );
  }
}

class DisruptionInfos {
  final int? disruptionNumber;
  final bool? startDisrupted;
  final bool? endDisrupted;
  final String? causeDisruptionStart;
  final String? causeDisruptionEnd;
  final int? delayStart;
  final int? delayEnd;
  final bool? tripCanceled;
  final String? messageDisruption;
  final List<Disruption>? list;

  DisruptionInfos({
    this.disruptionNumber,
    this.startDisrupted,
    this.endDisrupted,
    this.causeDisruptionStart,
    this.causeDisruptionEnd,
    this.delayStart,
    this.delayEnd,
    this.tripCanceled,
    this.messageDisruption,
    this.list,
  });

  factory DisruptionInfos.fromJson(Map<String, dynamic> json) {
    bool tripCanceled = false;

    String? messageDiruption;
    String stringDepartureDT = json['journeys'][0]['departure_date_time'];
    String stringArrivalDT = json['journeys'][0]['arrival_date_time'];

    DateTime departureDT = DateTime.parse(stringDepartureDT);
    DateTime arrivalDT = DateTime.parse(stringArrivalDT);

    List<Disruption> disruptions = [];

    int disruptionNumber = json['disruptions'].length;
    for (var i = 0; i < disruptionNumber; i++) {
      disruptions.add(Disruption.fromJson(json['disruptions'][i]));
    }

    List? checkDisruptionStart(int disruptionNumber, String? fromId) {
      for (Disruption dis in disruptions) {
        if (dis.tripCanceled!) {
          tripCanceled = true;
          messageDiruption = dis.message;
        }
        for (ImpactedStop stop in dis.impactedList!) {
          if (stop.id == fromId) {
            bool affectedStart = true;
            String amendedStart = stop.amendedDepartureTime!;
            int delayStart = calculateDelay(amendedStart, departureDT);
            return [affectedStart, delayStart, stop.cause];
          }
        }
      }
      return null;
    }

    List? checkDisruptionEnd(int disruptionNumber, String? toId) {
      for (Disruption dis in disruptions) {
        for (ImpactedStop stop in dis.impactedList!) {
          if (stop.id == toId) {
            bool affectedEnd = true;
            String amendedEnd = stop.amendedArrivaltime!;
            int delayEnd = calculateDelay(amendedEnd, arrivalDT);
            return [affectedEnd, delayEnd, stop.cause];
          }
        }
      }
      return null;
    }

    List? affectedStart;
    List? affectedEnd;
    List? la = [];
    List? le = [];
    int? nbSections = json['journeys'][0]["sections"].length;
    if (kDebugMode) {
      print("nbSections: $nbSections");
    }

    String? fromId = json['journeys'][0]["sections"][0]["to"]["id"];
    String? toId = json['journeys'][0]["sections"][nbSections! - 1]["to"]["id"];
    for (var i = 0; i < disruptionNumber; i++) {
      la = checkDisruptionStart(disruptionNumber, fromId);
      if (la != null) {
        affectedStart = la;
      }
      le = checkDisruptionEnd(disruptionNumber, toId);
      if (le != null) {
        affectedEnd = le;
      }
    }
    return DisruptionInfos(
      messageDisruption: messageDiruption,
      disruptionNumber: disruptionNumber,
      list: disruptions,
      startDisrupted: (affectedStart != null) ? true : false,
      endDisrupted: (affectedEnd != null) ? true : false,
      causeDisruptionStart: (affectedStart != null) ? affectedStart[2] : null,
      causeDisruptionEnd: (affectedEnd != null) ? affectedEnd[2] : null,
      delayStart: (affectedStart != null) ? affectedStart[1] : null,
      delayEnd: (affectedEnd != null) ? affectedEnd[1] : null,
      tripCanceled: tripCanceled,
    );
  }

  // true iff there's any disruption for this journey.
  bool hasAny() {
    return disruptionNumber != 0;
  }

  String motifStart() {
    if (tripCanceled!) {
      if (kDebugMode) {
        print(
            ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>DisruptionInfos : trip canceled!");
      }
      return "Supprimé : $messageDisruption";
    }
    var str = "Retard : ";
    str += "$delayStart min";
    if (causeDisruptionStart != null && causeDisruptionStart != "") {
      str += " ${causeDisruptionStart!}";
    }
    return str;
  }

  String motifEnd() {
    var str = "Retard : $delayEnd min";
    if (isDisrurptionEndCauseKnown()) {
      str += " : $causeDisruptionEnd";
    }
    return str;
  }

  bool isDisruptionStartDisplayable() {
    return (disruptionNumber != 0 && startDisrupted! && delayStart != 0);
  }

  bool isDisrurptionEndCauseKnown() {
    return causeDisruptionEnd != null && causeDisruptionEnd != "";
  }

  bool isDisruptionEndDisplayable() {
    return (disruptionNumber != 0 && endDisrupted! && delayEnd != 0);
  }
}

class FollowedJourney {
  final String? from;
  final String? to;
  final String? departure;
  final String? link;
  final String? knownDisruption;

  FollowedJourney({
    this.from,
    this.to,
    this.departure,
    this.link,
    this.knownDisruption,
  });

  factory FollowedJourney.decode(String journeyString) {
    // print("decode $journeyString");
    var strings = journeyString.split("#");

    return FollowedJourney(
      from: strings[0],
      to: strings[1],
      departure: strings[2],
      link: strings[3],
      knownDisruption: strings[4],
    );
  }

  String encode() {
    return [from, to, departure, link, knownDisruption].join("#");
  }

  DateTime departureToDT() {
    return DateTime.parse(departure!);
  }

  bool isDisrupted() {
    return knownDisruption != null && knownDisruption != "no";
  }

  String format() {
    String str = isDisrupted() ? "${wrapLongText(knownDisruption!, 3)} " : "";
    return "$str${wrapLongText(from!, 10)} → ${wrapLongText(to!, 10)} @ ${prettyTime(departureToDT())}";
  }
}

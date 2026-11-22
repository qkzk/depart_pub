import 'package:depart/data/data.dart';

class Schedule {
  List<Journey> journeys;
  Schedule({required this.journeys});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    List<Journey> journeys = [];
    for (final journeyElt in json["journeys"]) {
      Journey journey = Journey.fromJson(journeyElt);
      journeys.add(journey);
    }
    return Schedule(
      journeys: journeys,
    );
  }
}

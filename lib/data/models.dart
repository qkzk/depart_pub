import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';

import 'package:depart/data/data.dart';
import 'package:depart/data/schedules.dart';
import 'package:depart/data/api.dart' as api;
import 'package:depart/utils.dart';

/// Journey data
class JourneyNotifier with ChangeNotifier {
  int counterCall = 0;

  // Depature data
  Station? _departure;
  Station? get departure => _departure;
  set departure(Station? place) {
    _departure = place;
    // _fetchJourneys();
    notifyListeners();
  }

  // Arrival data
  Station? _arrival;
  Station? get arrival => _arrival;
  set arrival(Station? place) {
    _arrival = place;
    notifyListeners();
  }

  // Journey data
  Journeys? _journeys;
  Journeys? get journeys => _journeys;

  void fetchJourneys(
      {String? searchDateTime,
      String requestType = 'departure',
      BuildContext? context}) async {
    if (_departure != null &&
        _arrival != null &&
        _departure!.id != null &&
        _arrival!.id != null) {
      // où sont les date / time
      searchDateTime = (searchDateTime != null) ? searchDateTime : '';
      _journeys = await api.fetchJourney(
          _departure!.id, _arrival!.id, searchDateTime,
          requestType: requestType);
      if (_journeys == null) {
        if (kDebugMode) {
          print("fetchJourneys No result from api !");
        }
      } else {
        notifyListeners();
      }
    }
  }

  void fetchJourneysFromUrl(String typeURL, BuildContext context) async {
    /// Les données courantes (url etc.) sont dans _journey
    if (_departure != null && _arrival != null) {
      final mapTagUrl = {
        "first": _journeys!.links!.first,
        "prev": _journeys!.links!.prev,
        "curr": _journeys!.links!.curr,
        "next": _journeys!.links!.next,
        "last": _journeys!.links!.last,
      };

      String? retrievedURL = mapTagUrl[typeURL];
      if (kDebugMode) {
        print("fetchJourneysFromUrl $retrievedURL");
      }
      _journeys = await api.fetchJourney('', '', '', givenURL: retrievedURL);
      if (_journeys == null) {
        if (kDebugMode) {
          print("fetchJourneysFromUrl No result from api !");
        }
      } else {
        notifyListeners();
      }
    }
  }

  void fetchJourneysSpecificUrl(String url, BuildContext context) async {
    /// Les données courantes (url etc.) sont dans _journey
    _journeys = await api.fetchJourney('', '', '', givenURL: url);
    if (_journeys == null) {
      if (kDebugMode) {
        print("fetchJourneysSpecificUrl No result from api !");
      }
    } else {
      setDepartureArrival();
      notifyListeners();
    }
  }

  void setDepartureArrival() {
    final Journey? journey = _journeys!.journeyList?[0];
    _departure = Station(name: journey?.fromName, id: journey?.fromId);
    _arrival = Station(name: journey?.toName, id: journey?.toId);
  }

  // Search results data
  List<Station>? _placeSearchResults;
  List<Station>? get searchResults => _placeSearchResults;
  Future<List<Station>?> searchPlaces(String query) async {
    _placeSearchResults = await _loadLocations(query, searchType);
    return _placeSearchResults;
  }

  // Search type
  SearchType? searchType;
}

class ScheduleNotifier with ChangeNotifier {
  Schedule? _schedule;
  Schedule? get schedule => _schedule;
  set schedule(Schedule? schedule) {
    _schedule = schedule;
    notifyListeners();
  }

  void setScheduleFromJourney(Journey journey) async {
    String url = journey.linkSameJourneySchedules!;
    _schedule = await api.fetchSchedule(url);
  }
}

class FollowNotifier with ChangeNotifier {
  bool _hasFollowedJourneys = false;
  bool get getHasFollowedJourneys => _hasFollowedJourneys;

  void setHasFollowedJourney() {
    _hasFollowedJourneys = true;
    notifyListeners();
  }

  void unsetHasFollowedJourney() {
    _hasFollowedJourneys = false;
    notifyListeners();
  }
}

enum SearchType { origin, destination }

/// departure  ou arrival : on ne connait pas l'url complète
/// given_url : on utilise l'url fournie
enum JourneySearchType { departure, arrival, givenUrl }

/// App state
class AppStateNotifier with ChangeNotifier {
  // searchType : departure / arrival
  bool _searchDeparture = true;
  bool get getSearchDeparture => _searchDeparture;

  void switchSearchType() {
    _searchDeparture = !_searchDeparture;
    notifyListeners();
  }

  void setSearchArrival() {
    _searchDeparture = false;
    notifyListeners();
  }

  void setSearchDeparture() {
    _searchDeparture = true;
    notifyListeners();
  }
}

class DateTimeNotifier with ChangeNotifier {
  TimeOfDay? _atm;
  DateTime? _adt;

  TimeOfDay? get arrivalTime {
    // print("DTN arrivalTime: get - _stm: $_atm");
    return _atm;
  }

  set arrivalTime(TimeOfDay? tod) {
    // print("DTN arrivalTime: set - tod: $tod, _atm: $_atm");
    _atm = tod;
    notifyListeners();
  }

  DateTime? get arrivalDate {
    // print("DTN arrivalDate: get - _adt: $_adt");
    return _adt;
  }

  set arrivalDate(DateTime? dt) {
    // print("DTN arrivalTime: set - tod: $dt, _atm: $_atm");
    _adt = (dt != null && _atm != null)
        ? DateTime(dt.year, dt.month, dt.day, _atm!.hour, _atm!.minute)
        : null;
    notifyListeners();
  }

  /// Reset all the dates
  /// Called when stations are changed
  void resetAllDates() {
    // _stm = null;
    _atm = null;
    // _sdt = null;
    _adt = null;
  }
}

/// Manage loading locations
Future<List<Station>?> _loadLocations(String query, SearchType? locationType) =>
    api.fetchStationList(query);

void fetchJourneyWithCurrentSettings(
  JourneyNotifier notifierJourney,
  DateTimeNotifier notifierDT,
  AppStateNotifier notifierState,
) {
  String searchTime;
  String searchType;
  bool searchStatus;
  DateTime? aDT;
  if (isJourneyComplete(notifierJourney)) {
    /// on a déjà fait une recherche et on relance la même recherche
    /// OU
    /// on n'a pas encore fait de recherche mais on a des stations de départ et d'arrivée
    searchTime = '';
    aDT = notifierDT.arrivalDate;
    searchStatus = notifierState.getSearchDeparture;
    searchType = setSearchType(searchStatus);
    searchTime = dateAPIFormater(aDT);
    if (kDebugMode) {
      print("fetch current settings _searchType : $searchType");
      print("fetchJourneyWithCurrentSettings : fetchJourneys()");
    }
    notifierJourney.fetchJourneys(
        searchDateTime: searchTime, requestType: searchType);
  }
}

void fetchThisFollowedJourney(
  JourneyNotifier notifierJourney,
  // DateTimeNotifier notifierDT,
  // AppStateNotifier notifierState,
  FollowedJourney followedJourney,
  BuildContext context,
) {
  notifierJourney.fetchJourneysSpecificUrl(followedJourney.link!, context);
}

String setSearchType(bool searchStatus) {
  if (searchStatus) {
    return "departure";
  } else {
    return "arrival";
  }
}

bool isJourneyComplete(JourneyNotifier notifierJourney) {
  return (notifierJourney.journeys != null &&
          notifierJourney.journeys!.journeyList![0].fromName != null &&
          notifierJourney.journeys!.journeyList![0].toName != null) ||
      (notifierJourney.departure != null && notifierJourney.departure != null);
}

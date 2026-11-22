import 'package:intl/intl.dart';

const String stopHaz = "stop_area:OCE:SA:87286302";
const String stopLille = "stop_area:OCE:SA:87286005";
const String formatAPIDT = "yyyyMMddTHHmm00";
const String formatDTAPIWidget = "EEEEE d MMMM yyyy";
const String formatTODAPIWidget = "HH:mm";
const String formatSmallDateWidget = "d/M";
const String formatDTSearchWidget = "HH:mm\ndd MM yyyy";

String prettyTime(DateTime dt) {
  return DateFormat(formatTODAPIWidget).format(dt);
}

String smallDate(DateTime dt) {
  return DateFormat(formatSmallDateWidget).format(dt);
}

String dateWidgetFormater(DateTime dt) {
  final DateTime now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    return "Aujourd'hui";
  } else {
    return DateFormat(formatDTAPIWidget, "fr").format(dt);
  }
}

String dateAPIFormater(DateTime? dt) {
  // parse a date to be inserted in API call
  dt = (dt != null) ? dt : DateTime.now();
  return DateFormat(formatAPIDT).format(dt);
}

String dateTimeSearchFormater(DateTime dt) {
  return DateFormat(formatDTSearchWidget).format(dt);
}

/// renvoie une url de journey avec Lille Hazebrouck par défaut, avec l'heure courante par défaut
/// lui passer des string vides pour provoquer les modes par défaut
String formatURLNavitiaJourney(
    String? stopAreaStart, String? stopAreaStop, String? departureString,
    {String requestType = "departure"}) {
  const String urlJourneys =
      "https://api.sncf.com/v1/coverage/sncf/journeys?from=";

  // Pour implémenter les différents types de recherche
  final String urlEnd = "&datetime_represents=$requestType&datetime=";

  stopAreaStart = (stopAreaStart == '') ? stopLille : stopAreaStart;
  stopAreaStop = (stopAreaStop == '') ? stopHaz : stopAreaStop;
  departureString = (departureString == '')
      ? dateAPIFormater(DateTime.now())
      : departureString;

  return "$urlJourneys${stopAreaStart!}&to=${stopAreaStop!}$urlEnd${departureString!}";
}

String formatURLNavitiaStop(String fromStation) {
  return "https://api.sncf.com/v1/coverage/sncf/places?q=$fromStation&type%5B%5D=stop_area&";
  // "&type%5B%5D=line&type%5B%5D=stop_area&";
}

String strDuration(int duration, {bool long = false}) {
  String uniteMinute = long ? " minutes" : "m";
  String uniteMinuteLong = long ? " minutes " : "";
  String uniteHeure = long ? " heures " : "h";
  Duration dur = Duration(seconds: duration);
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(dur.inMinutes.remainder(60));
  if (dur.inHours > 0) {
    return "${dur.inHours}$uniteHeure $twoDigitMinutes$uniteMinuteLong";
  } else {
    return "$twoDigitMinutes $uniteMinute";
  }
}

/// For disruptions.
/// Return the delay in minutes between amended (String formated as HHmm00) and the real time.
/// Always return a non negative value.
int calculateDelay(String amended, DateTime real) {
  // amended = "170400";
  int aHours = int.parse(amended.substring(0, 2));
  int aMins = int.parse(amended.substring(2, 4));
  int diffMin = ((real.hour - aHours) * 60 + real.minute - aMins).abs();
  return diffMin;
}

/// wrap a long text to a fixed width
String wrapLongText(String text, int long) {
  return text.length < long ? text : text.substring(0, long);
}

String formatJourneySchedule(String url) {
  // url = "https://api.sncf.com/v1/coverage/sncf/journeys?first_section_mode%5B%5D=walking&direct_path=none&to=stop_area%3AOCE%3ASA%3A87286302&datetime_represents=departure&is_journey_schedules=True&datetime=20191123T122700&last_section_mode%5B%5D=walking&min_nb_journeys=5&min_nb_transfers=0&allowed_id%5B%5D=stop_point%3AOCE%3ASP%3ATrainTER-87286302&allowed_id%5B%5D=stop_point%3AOCE%3ASP%3ATrainTER-87286005&from=stop_area%3AOCE%3ASA%3A87286005";
  List<String> splitted = url.split("&");

  // _splitted = [
  //   "https://api.sncf.com/v1/coverage/sncf/journeys?first_section_mode%5B%5D=walking",
  //   "direct_path=none",
  //   "to=stop_area%3AOCE%3ASA%3A87286302",
  //   "datetime_represents=departure",
  //   "is_journey_schedules=True",
  //   "datetime=20191123T122700",
  //   "last_section_mode%5B%5D=walking",
  //   "min_nb_journeys=5",
  //   "min_nb_transfers=0",
  //   "allowed_id%5B%5D=stop_point%3AOCE%3ASP%3ATrainTER-87286302",
  //   "allowed_id%5B%5D=stop_point%3AOCE%3ASP%3ATrainTER-87286005",
  //   "from=stop_area%3AOCE%3ASA%3A87286005",
  // ];

  for (var i = 0; i < splitted.length; i++) {
    if (splitted[i].contains("min_nb_journeys=")) {
      splitted[i] = "min_nb_journeys=40";
    } else if (splitted[i].contains("datetime=2")) {
      splitted[i] = "${splitted[i].substring(0, 18)}000000";
    }
  }
  url = splitted.join("&");
  return url;
}

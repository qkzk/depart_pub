import 'package:depart/data/schedules.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:depart/data/api.dart';
import 'package:depart/data/data.dart';
import 'package:depart/data/models.dart';
import 'package:depart/utils.dart';

class ScheduleRoute extends StatefulWidget {
  const ScheduleRoute({super.key});

  @override
  ScheduleRouteState createState() => ScheduleRouteState();
}

class ScheduleRouteState extends State<ScheduleRoute> {
  @override
  Widget build(BuildContext context) {
    final Journey journey =
        ModalRoute.of(context)!.settings.arguments as Journey;
    return ScheduleRouteWidget(journey: journey);
  }
}

class ScheduleRouteWidget extends StatelessWidget {
  const ScheduleRouteWidget({
    Key? key,
    required this.journey,
  }) : super(key: key);

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Schedule?>(
        future: fetchSchedule(journey.linkSameJourneySchedules!),
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            final List<Journey> journeys = snapshot.data!.journeys;
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                title: const Text("Horaires pour ce trajet"),
              ),
              body: ScheduleRouteBodyWidget(journeys: journeys),
            );
          } else {
            return const NoResultShowTrainIcon();
          }
        });
  }
}

class ScheduleRouteBodyWidget extends StatelessWidget {
  const ScheduleRouteBodyWidget({
    Key? key,
    required List<Journey> journeys,
  })  : _journeys = journeys,
        super(key: key);

  final List<Journey> _journeys;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        itemCount: _journeys.length,
        itemBuilder: (context, index) {
          return JourneySchedule(_journeys[index], index, _journeys);
        },
      ),
    );
  }
}

class NoResultShowTrainIcon extends StatelessWidget {
  const NoResultShowTrainIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: const Center(
        child: Opacity(
          opacity: 0.2,
          child: Icon(
            Icons.train,
            size: 200,
          ),
        ),
      ),
    );
  }
}

class JourneySchedule extends StatefulWidget {
  final Journey journey;
  final int index;
  final List<Journey> journeys;
  const JourneySchedule(this.journey, this.index, this.journeys, {super.key});
  @override
  JourneyScheduleState createState() => JourneyScheduleState();
}

class JourneyScheduleState extends State<JourneySchedule> {
  JourneyScheduleState();
  @override
  Widget build(BuildContext context) {
    final notifierJourney =
        Provider.of<JourneyNotifier>(context, listen: false);
    final DateTime dt = widget.journey.departureDT!;
    final bool visible = widget.index == 0 ||
        (widget.index != 0 &&
            widget.journeys[widget.index - 1].departureDT!.day != dt.day);
    final String day = DateFormat(formatDTAPIWidget, "fr").format(dt);
    return Column(
      children: <Widget>[
        TopRowDay(visible: visible, day: day),
        buildCardIconAndDetails(context, notifierJourney),
      ],
    );
  }

  Card buildCardIconAndDetails(
      BuildContext context, JourneyNotifier notifierJourney) {
    return Card(
      elevation: 8,
      color: Theme.of(context).primaryColor,
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      semanticContainer: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.none,
      surfaceTintColor: Colors.transparent,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          child: Row(
            children: buildChildrenIconAndDetails(notifierJourney),
          )),
    );
  }

  List<Widget> buildChildrenIconAndDetails(JourneyNotifier notifierJourney) {
    return <Widget>[
      IconBackMain(journey: widget.journey, notifierJourney: notifierJourney),
      TableJourney(journey: widget.journey),
    ];
  }
}

class TopRowDay extends StatelessWidget {
  const TopRowDay({
    Key? key,
    required this.visible,
    required this.day,
  }) : super(key: key);

  final bool visible;
  final String day;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          day,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}

class IconBackMain extends StatelessWidget {
  const IconBackMain({
    Key? key,
    required this.journey,
    required this.notifierJourney,
  }) : super(key: key);

  final Journey journey;
  final JourneyNotifier notifierJourney;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          final url = formatURLNavitiaJourney(
              journey.sectionList!.first.from!.id,
              journey.sectionList!.last.toStation!.id,
              journey.stringDepartureDT);
          notifierJourney.fetchJourneysSpecificUrl(url, context);
          Navigator.pop(context);
        },
        icon: const Icon(Icons.train),
        iconSize: 30);
  }
}

class TableJourney extends StatelessWidget {
  const TableJourney({
    Key? key,
    required this.journey,
  }) : super(key: key);

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        buildTableRow(
          smallDate(journey.departureDT!),
          journey.departureDT!,
          journey.fromName!,
        ),
        buildTableRow(
          strDuration(journey.duration!),
          journey.arrivalDT!,
          journey.toName!,
        ),
      ],
    );
  }

  TableRow buildTableRow(
      String textDurationDate, DateTime datetime, String textDest) {
    const TextStyle styleTextAlpha =
        TextStyle(fontSize: 16, color: Colors.white54);
    const TextStyle styleTextWhite =
        TextStyle(fontSize: 16, color: Colors.white);

    return TableRow(children: [
      Text(textDurationDate, style: styleTextAlpha),
      const Padding(padding: EdgeInsets.all(8)),
      Text(prettyTime(datetime), style: styleTextWhite),
      const Padding(padding: EdgeInsets.all(8)),
      Text(wrapLongText(textDest, 19), style: styleTextAlpha),
    ]);
  }
}

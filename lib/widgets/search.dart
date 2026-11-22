import 'package:material_ui/material_ui.dart';

import 'package:provider/provider.dart';

import 'package:depart/data/models.dart';
import 'package:depart/data/data.dart';

Future<Station?> showPlacesSearch(BuildContext context) async =>
    await showSearch<Station?>(
      context: context,
      delegate: PlacesSearchDelegate(),
    );

class PlacesSearchDelegate extends SearchDelegate<Station?> {
  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    final notifierDatetimes =
        Provider.of<DateTimeNotifier>(context, listen: false);
    return FutureBuilder(
        future: notifier.searchPlaces(query),
        builder: (context, AsyncSnapshot<List<Station>?> snapshot) {
          return buildResultMethod(snapshot, context, notifierDatetimes);
        });
  }

  StatelessWidget buildResultMethod(
    AsyncSnapshot<List<Station>?> snapshot,
    BuildContext context,
    DateTimeNotifier notifierDatetimes,
  ) {
    if (snapshot.hasData) {
      return buildResultData(context, snapshot, notifierDatetimes);
    } else if (snapshot.hasError) {
      return buildResultError(context, snapshot);
    } else {
      return const ResultNoData();
    }
  }

  Container buildResultError(
      BuildContext context, AsyncSnapshot<List<Station>?> snapshot) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Text(
          '${snapshot.error}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Container buildResultData(
      BuildContext context,
      AsyncSnapshot<List<Station>?> snapshot,
      DateTimeNotifier notifierDatetimes) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: ListView(
        children: snapshot.data!
            .map(
              (p) => PlaceTile(
                place: p,
                onTap: () {
                  notifierDatetimes.resetAllDates();
                  return close(context, p);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    final notifierDatetimes =
        Provider.of<DateTimeNotifier>(context, listen: false);
    if (query.length > 1) {
      return FutureBuilder(
          future: notifier.searchPlaces(query),
          builder: (context, AsyncSnapshot<List<Station>?> snapshot) {
            return buildSuggestionMethod(snapshot, context, notifierDatetimes);
          });
    } else {
      return const EmptyBackground();
    }
  }

  StatelessWidget buildSuggestionMethod(
    AsyncSnapshot<List<Station>?> snapshot,
    BuildContext context,
    DateTimeNotifier notifierDatetimes,
  ) {
    if (snapshot.hasData) {
      return buildSuggestionData(context, snapshot, notifierDatetimes);
    } else if (snapshot.hasError) {
      return buildSuggestionError(context, snapshot);
    } else {
      return const SuggestionNoData();
    }
  }

  Container buildSuggestionError(
      BuildContext context, AsyncSnapshot<List<Station>?> snapshot) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Text(
          '${snapshot.error}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Container buildSuggestionData(
      BuildContext context,
      AsyncSnapshot<List<Station>?> snapshot,
      DateTimeNotifier notifierDatetimes) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: ListView(
        children: snapshot.data!
            .map(
              (p) => PlaceTile(
                place: p,
                onTap: () {
                  notifierDatetimes.resetAllDates();
                  return close(context, p);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class EmptyBackground extends StatelessWidget {
  const EmptyBackground({
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
            )),
      ),
    );
  }
}

class SuggestionNoData extends StatelessWidget {
  const SuggestionNoData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        // child: CircularProgressIndicator(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildSuggestionNoData(),
        ),
      ),
    );
  }

  List<Widget> buildSuggestionNoData() {
    return <Widget>[
      const Icon(
        Icons.sentiment_dissatisfied,
        size: 80,
      ),
      const Text(
        "Aucun résultat",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ];
  }
}

class ResultNoData extends StatelessWidget {
  const ResultNoData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Tile depicting a place
class PlaceTile extends StatelessWidget {
  const PlaceTile({super.key, this.place, this.onTap});
  final Station? place;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(place!.name!),
      leading: const Icon(Icons.train),
      onTap: onTap,
    );
  }
}

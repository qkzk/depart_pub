import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:depart/map.dart' as map;
import 'package:depart/data/follow.dart' as follow;
import 'package:depart/data/models.dart';
import 'package:depart/widgets/journeys.dart';
import 'package:depart/widgets/favorites.dart';
import 'package:depart/widgets/schedules.dart';
import 'package:depart/widgets/widgets.dart';
import 'package:depart/themes/dynamic_themes.dart';
import 'package:depart/themes/themes.dart';

const bool debugMode = kDebugMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // leave this here for debugging purpose
  // await clearSharedPrefs();

  follow.clearOldFollowed();

  // localNotification.initialize(initializationSettings,
  // onSelectNotification: follow.onSelectNotification
  //    onDidReceiveNotificationResponse: follow.notificationResponseWTF);

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await localNotification.getNotificationAppLaunchDetails();

  final String? payload =
      notificationAppLaunchDetails!.notificationResponse?.payload;

  initalizeWorkmanager();

  runApp(
    CustomTheme(initialThemeKey: MyThemeKeys.blue, child: DepartApp(payload)),
  );
}

final FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '1',
      'depart',
      channelDescription: 'depart channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      ledColor: Color(0xff813961),
      ledOffMs: 1000,
      ledOnMs: 1000,
      enableLights: true,
    );

const NotificationDetails platformChannelSpecifics = NotificationDetails(
  android: androidPlatformChannelSpecifics,
);

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
);

void initalizeWorkmanager() {
  Workmanager().initialize(follow.callBackDispatcher, isInDebugMode: debugMode);
  Workmanager().registerPeriodicTask(
    "2",
    follow.watchoutFollow,
    frequency: const Duration(minutes: 15),
  );
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class DepartApp extends StatefulWidget {
  const DepartApp(this.payload, {Key? key}) : super(key: key);
  final String? payload;

  @override
  createState() => DepartAppState();
}

class DepartAppState extends State<DepartApp> {
  DepartAppState();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sharedPreferences) {
      setState(() {
        loadTheme(context);
      });
    });
  }

  final animationCardNotifier = StreamController.broadcast();

  @override
  void dispose() {
    animationCardNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JourneyNotifier()),
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
        ChangeNotifierProvider(create: (_) => DateTimeNotifier()),
        ChangeNotifierProvider(create: (_) => ScheduleNotifier()),
        ChangeNotifierProvider(create: (_) => FollowNotifier()),
      ],
      child: buildMainMaterialApp(context),
    );
  }

  MaterialApp buildMainMaterialApp(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr')],
      title: "Départ",
      initialRoute: '/',
      routes: {
        '/': (context) =>
            DepartTransportPage(animationCardNotifier, widget.payload),
        '/map': (context) => const map.MapRoute(),
        '/schedule': (context) => const ScheduleRoute(),
      },
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.of(context),
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class DepartTransportPage extends StatefulWidget {
  final String? payload;
  final StreamController<dynamic> animationCardNotifier;
  const DepartTransportPage(
    this.animationCardNotifier,
    this.payload, {
    super.key,
  });
  @override
  createState() => DepartTransportPageState();
}

const String havePayload = "havePayload";

class DepartTransportPageState extends State<DepartTransportPage> {
  DepartTransportPageState();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sharedPreferences) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTimeNotifier notifierDT = Provider.of<DateTimeNotifier>(
      context,
      listen: false,
    );
    refresh() {
      setState(() {
        notifierDT = Provider.of<DateTimeNotifier>(context, listen: false);
      });
    }

    AppStateNotifier notifierState = Provider.of<AppStateNotifier>(context);
    JourneyNotifier notifierJourney = Provider.of<JourneyNotifier>(
      context,
      listen: false,
    );
    loadOnceFromPayload();

    return RefreshIndicator(
      backgroundColor: Theme.of(context).hoverColor,
      onRefresh: () async {
        widget.animationCardNotifier.sink.add(null);
        fetchJourneyWithCurrentSettings(
          notifierJourney,
          notifierDT,
          notifierState,
        );
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).primaryColor,
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 125,
              floating: true,
              pinned: true,
              flexibleSpace: BarWithBackground(widget.animationCardNotifier),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: buildMainView(refresh),
            ),
          ],
        ),
      ),
    );
  }

  void loadOnceFromPayload() {
    if (widget.payload != null) {
      SharedPreferences.getInstance().then((prefs) {
        bool? usedPayload = prefs.getBool(havePayload);

        if (usedPayload != null && !usedPayload) {
          follow.onSelectNotification(widget.payload);
          prefs.setBool(havePayload, true);
        } else {
          prefs.setBool(havePayload, false);
        }
      });
    }
  }

  SingleChildScrollView buildMainView(Function() refresh) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Origin(),
          const Destination(),
          ThirdRow([
            SwitchArrivalDeparture(widget.animationCardNotifier),
            SearchTypeSwitcher(widget.animationCardNotifier),
            ArrivalTimePicker(widget.animationCardNotifier),
            ResetTimePicker(widget.animationCardNotifier),
          ]),
          FadeJourneyPanel(
            shouldTriggerChange: widget.animationCardNotifier.stream,
            notifyParent: refresh,
          ),
        ],
      ),
    );
  }
}

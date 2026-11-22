import 'dart:async';
import 'dart:math';

// imported as ui to prevent conflict between ui.Image and the Image widget
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:depart/utils.dart';
import 'package:depart/data/data.dart';

class MapRoute extends StatefulWidget {
  const MapRoute({super.key});

  @override
  MapRouteState createState() => MapRouteState();
}

class MapRouteState extends State<MapRoute> {
  final Map<String?, Marker> _markers = {};
  final Map<String?, Polyline> _polylines = {};
  final LatLng _center = const LatLng(47.2, 2.0);

  @override
  Widget build(BuildContext context) {
    final Journey? journey =
        ModalRoute.of(context)!.settings.arguments as Journey?;

    Future<void> onMapCreated(GoogleMapController controller) async {
      BitmapDescriptor iconMarkerStart =
          await _bitmapDescriptorFromSvgAsset(context, 'assets/train-24px.svg');
      if (!context.mounted) return;
      BitmapDescriptor iconMarkerStep = await _bitmapDescriptorFromSvgAsset(
          context, 'assets/crop_square-24px.svg');
      if (!context.mounted) return;
      BitmapDescriptor iconMarkerArrival =
          await _bitmapDescriptorFromSvgAsset(context, 'assets/add-24px.svg');
      if (!context.mounted) return;
      BitmapDescriptor iconMarkerDestination =
          await _bitmapDescriptorFromSvgAsset(
              context, 'assets/beenhere-24px.svg');
      String? info;

      setState(() {
        _markers.clear();
        int indexSection = 0;
        buildSectionList(journey, info, iconMarkerStart, indexSection,
            iconMarkerDestination, iconMarkerArrival, iconMarkerStep, context);

        LatLngBounds bounds = getBounds(_markers.values.toList());
        controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 30.0));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte du trajet"),
      ),
      body: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 6.0),
        markers: _markers.values.toSet(),
        polylines: _polylines.values.toSet(),
      ),
    );
  }

  void buildSectionList(
      Journey? journey,
      String? info,
      BitmapDescriptor iconMarkerStart,
      int indexSection,
      BitmapDescriptor iconMarkerDestination,
      BitmapDescriptor iconMarkerArrival,
      BitmapDescriptor iconMarkerStep,
      BuildContext context) {
    List<Section> sectionList = journey!.sectionList!;
    for (final section in sectionList) {
      // correspondances
      List<Marker> sectionMarkers = [];
      int indexStop = 0;
      for (final station in section.stops!.stops!) {
        // arrêts
        BitmapDescriptor bitmapDescriptor;
        info = null;

        if (indexStop == 0) {
          bitmapDescriptor = iconMarkerStart;
          info = "Départ";
        } else if (indexStop == section.stops!.stops!.length - 1) {
          if (indexSection == sectionList.length - 1) {
            bitmapDescriptor = iconMarkerDestination;
            info = "Arrivée";
          } else {
            bitmapDescriptor = iconMarkerArrival;
            info = "Correspondance";
          }
        } else {
          bitmapDescriptor = iconMarkerStep;
        }

        final Marker marker = makeMaker(station, bitmapDescriptor, info: info);
        sectionMarkers.add(marker);
        _markers[station.name] = marker;
        if (kDebugMode) {
          print(
              "_onMapCreated    markerId : ${marker.markerId}, lat ${marker.position.latitude}, lon ${marker.position.longitude}");
        }
        indexStop++;
      }
      String rand = _randomString(3);
      _polylines[section.from!.name] = polylineMaker(
        [for (Station station in section.stops!.stops!) station.latLng!],
        section.from!.name! + rand,
        Theme.of(context).primaryColor,
      );
      indexSection++;
    }
  }
}

Polyline polylineMaker(
    List<LatLng> points, String polylineId, Color lineColor) {
  return Polyline(
    width: 6,
    startCap: Cap.roundCap,
    endCap: Cap.squareCap,
    geodesic: true,
    color: lineColor,
    polylineId: PolylineId(polylineId),
    points: points,
  );
}

Marker makeMaker(Station station, BitmapDescriptor bitmapImage,
    {String? info}) {
  return Marker(
    anchor: const Offset(0.5, 0.5),
    icon: bitmapImage,
    markerId: MarkerId(station.name!),
    position: station.latLng!,
    infoWindow: InfoWindow(
      title: station.name,
      snippet: (info == null)
          ? prettyTime(station.departureTime!)
          : "$info - ${prettyTime(station.departureTime!)}",
    ),
  );
}

String _randomString(int length) {
  var rand = Random();
  var codeUnits = List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });
  return String.fromCharCodes(codeUnits);
}

Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
    BuildContext context, String assetName) async {
  // Read SVG file as String
  String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
  // Create DrawableRoot from SVG String
  // DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, null);
  // DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, "");
  final PictureInfo pictureInfo =
      await vg.loadPicture(SvgStringLoader(svgString), null);

  // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here

  MediaQueryData? queryData =
      (!context.mounted) ? null : MediaQuery.of(context);
  double devicePixelRatio =
      (queryData == null) ? 1.0 : queryData.devicePixelRatio;
  double width =
      (24 * devicePixelRatio); // where 32 is your SVG's original width
  double height = (24 * devicePixelRatio); // same thing

  int widthInt = width.round();
  int heightInt = height.round();

  // Convert to ui.Picture
  // ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

  // Convert to ui.Image. toImage() takes width and height as parameters
  // you need to find the best size to suit your needs and take into account the
  // screen DPI
  // ui.Image image = await picture.toImage(widthInt, heightInt);
  ui.Image image = await pictureInfo.picture.toImage(widthInt, heightInt);
  ByteData? bytes = await (image.toByteData(format: ui.ImageByteFormat.png));
  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

LatLngBounds getBounds(List<Marker> markers) {
  var lngs = markers.map<double>((m) => m.position.longitude).toList();
  var lats = markers.map<double>((m) => m.position.latitude).toList();

  double topMost = lngs.reduce(max);
  double leftMost = lats.reduce(min);
  double rightMost = lats.reduce(max);
  double bottomMost = lngs.reduce(min);

  LatLngBounds bounds = LatLngBounds(
    northeast: LatLng(rightMost, topMost),
    southwest: LatLng(leftMost, bottomMost),
  );

  return bounds;
}

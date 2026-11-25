# TODO

- [ ] BUG: wrong splash screen : https://pub.dev/packages/flutter_native_splash
    - [x] installed flutter native splash
    - [ ] needs to be configured
- [x] FIX: swap crash - can't reproduce
- [x] FIX: aller/retour button crash - can't reproduce
- [x] FIX: card with times wrong colors
- [x] FIX: time & date : wrong background colors
- [x] FIX: setting a time & date crash - can't reproduce
- [x] FIX: train button crash - can't reproduce
- [x] FIX: followed journey display crash
- [ ] BUG: horaires pour le trajet : pixel overflow
- [ ] BUG: map won't load

    - [ ] wrong name in android certificates : depart vs depart_pub

```log
I/mple.depart_pub(13560): AssetManager2(0x73e38c68d438) locale list changing from [] to [en-US]
I/mple.depart_pub(13560): AssetManager2(0x73e38c68dd98) locale list changing from [] to [en-US]
I/GoogleMapController(13560): No TextureView found. Likely using the LEGACY renderer.
E/GoogleMapController(13560): Cannot enable MyLocation layer as location permissions are not granted
I/bb      (13560): Successfully registered with Phenotype.
E/Google Maps Android API(13560): Authorization failure.  Please see https://developers.google.com/maps/documentation/android-api/start for how to correctly set up the map.
E/Google Maps Android API(13560): In the Google Developer Console (https://console.developers.google.com)
E/Google Maps Android API(13560): Ensure that the "Google Maps Android API v2" is enabled.
E/Google Maps Android API(13560): Ensure that the following Android Key exists:
E/Google Maps Android API(13560): 	API Key: "xxx"
E/Google Maps Android API(13560): 	Android Application (<cert_fingerprint>;<package_name>): xxx;com.example.depart_pub
6
W/HWUI    (13560): Image decoding logging dropped!
I/flutter (13560): _onMapCreated    markerId : MarkerId(Hazebrouck (Hazebrouck)), lat 50.724924, lon 2.541463
I/flutter (13560): _onMapCreated    markerId : MarkerId(Bailleul (Bailleul)), lat 50.729167, lon 2.734485
I/flutter (13560): _onMapCreated    markerId : MarkerId(Steenwerck (Bailleul)), lat 50.712787, lon 2.786562
I/flutter (13560): _onMapCreated    markerId : MarkerId(Nieppe (Nieppe)), lat 50.696864, lon 2.829106
I/flutter (13560): _onMapCreated    markerId : MarkerId(Armentières (Armentières)), lat 50.680848, lon 2.87768
I/flutter (13560): _onMapCreated    markerId : MarkerId(Lille Flandres (Lille)), lat 50.636577, lon 3.06987
21
W/HWUI    (13560): Image decoding logging dropped!
W/DynamiteModule(13560): Local module descriptor class for com.google.android.gms.googlecertificates not found.
I/DynamiteModule(13560): Considering local module com.google.android.gms.googlecertificates:0 and remote module com.google.android.gms.googlecertificates:7
I/DynamiteModule(13560): Selected remote version of com.google.android.gms.googlecertificates, version >= 7
I/mple.depart_pub(13560): AssetManager2(0x73e38c683b18) locale list changing from [] to [en-US]
I/mple.depart_pub(13560): AssetManager2(0x73e38c695a98) locale list changing from [] to [en-US]
I/PhClient(13560): Unable to retrieve flag snapshot for com.google.android.libraries.consentverifier#com.example.depart_pub, using defaults.
I/PhClient(13560): Unable to retrieve flag snapshot for com.google.android.gms.clearcut_client#com.example.depart_pub, using defaults.
Application finished.

Exited.
```